#!/usr/bin/env node
// Measures throttled web startup for docs/PERF.md.
//
// Usage:
//   python -m http.server 8080 --directory app/build/web
//   node tool/measure_web_perf.mjs http://127.0.0.1:8080/
//
// It drives a separate headless Chrome over the DevTools protocol with 4x CPU
// throttling and a 4G profile, then reports first paint, first Flutter frame,
// first home heading, and transfer size. No dependencies beyond Node 22.

import { spawn } from 'node:child_process';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const CHROME =
  process.env.CHROME_PATH ||
  'C:/Program Files/Google/Chrome/Application/chrome.exe';
const URL = process.argv[2] || 'http://127.0.0.1:8080/';
const RUNS = Number(process.argv[3] || 3);
const DEBUG_PORT = 9333;

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function waitFor(fn, timeoutMs, label) {
  const started = Date.now();
  for (;;) {
    try {
      const value = await fn();
      if (value) {
        return value;
      }
    } catch {
      // keep waiting
    }
    if (Date.now() - started > timeoutMs) {
      throw new Error(`Timed out waiting for ${label}`);
    }
    await sleep(100);
  }
}

class Cdp {
  constructor(socket) {
    this.socket = socket;
    this.next = 0;
    this.pending = new Map();
    this.events = [];
    socket.addEventListener('message', (event) => {
      const message = JSON.parse(event.data);
      if (message.id) {
        const resolver = this.pending.get(message.id);
        this.pending.delete(message.id);
        if (resolver) {
          resolver(message);
        }
      } else {
        this.events.push(message);
      }
    });
  }

  send(method, params = {}) {
    const id = ++this.next;
    return new Promise((resolve) => {
      this.pending.set(id, resolve);
      this.socket.send(JSON.stringify({ id, method, params }));
    });
  }

  async evaluate(expression) {
    const response = await this.send('Runtime.evaluate', {
      expression,
      returnByValue: true,
      awaitPromise: true,
    });
    return response.result?.result?.value;
  }
}

function openSocket(url) {
  return new Promise((resolve, reject) => {
    const socket = new WebSocket(url);
    socket.addEventListener('open', () => resolve(socket));
    socket.addEventListener('error', reject);
  });
}

async function runOnce(profileDir) {
  const chrome = spawn(CHROME, [
    '--headless=new',
    '--no-first-run',
    '--no-default-browser-check',
    '--disable-extensions',
    '--disable-background-networking',
    `--user-data-dir=${profileDir}`,
    `--remote-debugging-port=${DEBUG_PORT}`,
    'about:blank',
  ]);

  try {
    await waitFor(
      async () => {
        const response = await fetch(`http://127.0.0.1:${DEBUG_PORT}/json/version`);
        return response.ok;
      },
      20000,
      'Chrome DevTools',
    );

    const target = await fetch(
      `http://127.0.0.1:${DEBUG_PORT}/json/new?about:blank`,
      { method: 'PUT' },
    ).then((response) => response.json());
    const socket = await openSocket(target.webSocketDebuggerUrl);
    const cdp = new Cdp(socket);

    await cdp.send('Page.enable');
    await cdp.send('Runtime.enable');
    await cdp.send('Network.enable');
    await cdp.send('Network.setCacheDisabled', { cacheDisabled: true });
    if (!process.env.DR_NO_THROTTLE) {
      await cdp.send('Network.emulateNetworkConditions', {
        offline: false,
        latency: 150,
        downloadThroughput: (1.6 * 1024 * 1024) / 8,
        uploadThroughput: (750 * 1024) / 8,
        connectionType: 'cellular4g',
      });
      await cdp.send('Emulation.setCPUThrottlingRate', { rate: 4 });
    }

    await cdp.send('Page.addScriptToEvaluateOnNewDocument', {
      source: `
        window.__dr = { start: performance.now(), frame: 0, home: 0 };
        const watch = () => {
          const pane = document.querySelector('flt-glass-pane');
          if (pane && pane.shadowRoot && pane.shadowRoot.querySelector('flt-scene-host')) {
            if (!window.__dr.frame) { window.__dr.frame = performance.now(); }
          }
          const semantics = document.querySelector('flt-semantics');
          if (semantics && semantics.textContent && semantics.textContent.includes('Practice a digital arrest')) {
            if (!window.__dr.home) { window.__dr.home = performance.now(); }
          }
          if (!window.__dr.home) { requestAnimationFrame(watch); }
        };
        requestAnimationFrame(watch);
        const enable = setInterval(() => {
          const placeholder = document.querySelector('flt-semantics-placeholder');
          if (placeholder) {
            placeholder.click();
            clearInterval(enable);
          }
        }, 200);
      `,
    });

    await cdp.send('Page.navigate', { url: URL });

    const frame = await waitFor(
      () => cdp.evaluate('window.__dr && window.__dr.frame ? window.__dr.frame : 0'),
      90000,
      'first Flutter frame',
    );
    const home = await waitFor(
      () => cdp.evaluate('window.__dr && window.__dr.home ? window.__dr.home : 0'),
      90000,
      'home heading',
    );
    const metrics = await cdp.evaluate(`
      (() => {
        const paints = Object.fromEntries(
          performance.getEntriesByType('paint').map((entry) => [entry.name, entry.startTime])
        );
        const nav = performance.getEntriesByType('navigation')[0];
        const resources = performance.getEntriesByType('resource');
        return {
          firstPaint: paints['first-paint'] || null,
          firstContentfulPaint: paints['first-contentful-paint'] || null,
          domContentLoaded: nav ? nav.domContentLoadedEventEnd : null,
          loadEventEnd: nav ? nav.loadEventEnd : null,
          transferBytes: resources.reduce((sum, entry) => sum + (entry.transferSize || 0), 0),
          decodedBytes: resources.reduce((sum, entry) => sum + (entry.decodedBodySize || 0), 0),
        };
      })()
    `);

    socket.close();
    return {
      firstPaint: metrics.firstPaint,
      firstContentfulPaint: metrics.firstContentfulPaint,
      firstFlutterFrame: frame,
      firstHomeHeading: home,
      domContentLoaded: metrics.domContentLoaded,
      loadEventEnd: metrics.loadEventEnd,
      transferBytes: metrics.transferBytes,
      decodedBytes: metrics.decodedBytes,
    };
  } finally {
    chrome.kill();
    await sleep(300);
  }
}

function median(values) {
  const sorted = [...values].sort((a, b) => a - b);
  return sorted[Math.floor(sorted.length / 2)];
}

const runs = [];
for (let index = 0; index < RUNS; index += 1) {
  const profileDir = mkdtempSync(join(tmpdir(), 'dryrun-perf-'));
  try {
    const result = await runOnce(profileDir);
    runs.push(result);
    console.log(`run ${index + 1}:`, JSON.stringify(result));
  } finally {
    rmSync(profileDir, { recursive: true, force: true });
  }
}

const summary = {
  runs: runs.length,
  firstContentfulPaintMs: Math.round(
    median(runs.map((run) => run.firstContentfulPaint || 0)),
  ),
  firstFlutterFrameMs: Math.round(
    median(runs.map((run) => run.firstFlutterFrame || 0)),
  ),
  firstHomeHeadingMs: Math.round(
    median(runs.map((run) => run.firstHomeHeading || 0)),
  ),
  domContentLoadedMs: Math.round(
    median(runs.map((run) => run.domContentLoaded || 0)),
  ),
  loadEventEndMs: Math.round(median(runs.map((run) => run.loadEventEnd || 0))),
  transferKiB: Math.round(median(runs.map((run) => run.transferBytes)) / 1024),
  decodedMiB: Number(
    (median(runs.map((run) => run.decodedBytes)) / (1024 * 1024)).toFixed(2),
  ),
};
console.log('SUMMARY', JSON.stringify(summary, null, 2));
