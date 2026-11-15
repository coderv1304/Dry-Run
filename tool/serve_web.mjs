#!/usr/bin/env node
// A tiny production-like static server for app/build/web.
//
// It exists so we can measure the built app the way a real host would serve it:
//   * brotli or gzip for compressible files,
//   * the cache and security headers from app/web/_headers,
//   * the SPA rewrite from app/web/_redirects.
//
// Usage: node tool/serve_web.mjs [port] [root]
// Default: port 8080, root app/build/web.

import { createServer } from 'node:http';
import { existsSync, readFileSync, statSync } from 'node:fs';
import { extname, join, normalize, resolve } from 'node:path';
import { brotliCompressSync, gzipSync } from 'node:zlib';

const PORT = Number(process.argv[2] || 8080);
const ROOT = resolve(process.argv[3] || 'app/build/web');

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.wasm': 'application/wasm',
  '.css': 'text/css; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.txt': 'text/plain; charset=utf-8',
  '.map': 'application/json; charset=utf-8',
};

const COMPRESSIBLE = new Set([
  '.html', '.js', '.mjs', '.json', '.css', '.svg', '.txt', '.map', '.wasm',
]);

/// Parses the Netlify-style _headers file into a list of { pattern, headers }.
function readHeaderRules() {
  const path = join(ROOT, '_headers');
  if (!existsSync(path)) {
    return [];
  }
  const rules = [];
  let current = null;
  for (const raw of readFileSync(path, 'utf8').split(/\r?\n/)) {
    const line = raw.trim();
    if (!line || line.startsWith('#')) {
      continue;
    }
    if (!line.includes(':') && (line.startsWith('/') || line.startsWith('*'))) {
      current = { pattern: line, headers: [] };
      rules.push(current);
      continue;
    }
    const index = line.indexOf(':');
    if (current && index > 0) {
      current.headers.push([line.slice(0, index).trim(), line.slice(index + 1).trim()]);
    }
  }
  return rules;
}

function matches(pattern, pathname) {
  if (pattern === '/*' || pattern === '*') {
    return true;
  }
  if (pattern.endsWith('/*')) {
    return pathname.startsWith(pattern.slice(0, -1));
  }
  return pathname === pattern;
}

const headerRules = readHeaderRules();

function headersFor(pathname) {
  const result = [];
  for (const rule of headerRules) {
    if (matches(rule.pattern, pathname)) {
      result.push(...rule.headers);
    }
  }
  return result;
}

const cache = new Map();

function compressed(file, encoding) {
  const key = `${file}:${encoding}`;
  const hit = cache.get(key);
  if (hit) {
    return hit;
  }
  const raw = readFileSync(file);
  const body = encoding === 'br' ? brotliCompressSync(raw) : gzipSync(raw);
  cache.set(key, body);
  return body;
}

function safePath(pathname) {
  const decoded = decodeURIComponent(pathname.split('?')[0]);
  const candidate = normalize(join(ROOT, decoded));
  return candidate.startsWith(ROOT) ? candidate : null;
}

const server = createServer((request, response) => {
  const url = request.url || '/';
  let pathname = url.split('?')[0];
  let file = safePath(pathname);

  // SPA rewrite: an unknown path is served the app shell.
  if (!file || !existsSync(file) || statSync(file).isDirectory()) {
    pathname = '/index.html';
    file = join(ROOT, 'index.html');
  }

  if (!existsSync(file)) {
    response.writeHead(404, { 'Content-Type': 'text/plain' });
    response.end('Not found');
    return;
  }

  const ext = extname(file).toLowerCase();
  const accept = String(request.headers['accept-encoding'] || '');
  const headers = {
    'Content-Type': MIME[ext] || 'application/octet-stream',
    Vary: 'Accept-Encoding',
  };
  for (const [name, value] of headersFor(pathname)) {
    headers[name] = value;
  }

  let body = readFileSync(file);
  if (COMPRESSIBLE.has(ext) && body.length > 1024) {
    if (accept.includes('br')) {
      body = compressed(file, 'br');
      headers['Content-Encoding'] = 'br';
    } else if (accept.includes('gzip')) {
      body = compressed(file, 'gz');
      headers['Content-Encoding'] = 'gzip';
    }
  }

  headers['Content-Length'] = String(body.length);
  response.writeHead(200, headers);
  if (request.method === 'HEAD') {
    response.end();
    return;
  }
  response.end(body);
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`Dry Run web build served from ${ROOT} at http://127.0.0.1:${PORT}/`);
});
