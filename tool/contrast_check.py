#!/usr/bin/env python3
"""WCAG contrast gate for every declared token pairing, in both modes."""

from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import token_model as tm


def check() -> int:
    tokens = tm.load_tokens()
    errors = tm.validate(tokens)
    if errors:
        for error in errors:
            print("TOKEN FAIL: %s" % error)
        return 1

    thresholds = tokens["contrast"]["thresholds"]
    failures: list[str] = []
    checked = 0

    for pairing in tokens["contrast"]["pairings"]:
        token = pairing["token"]
        kind = pairing["kind"]
        minimum = thresholds[kind]
        for mode in ("light", "dark"):
            foreground, alpha = tm.resolve(tokens, token, mode)
            for surface in pairing["surfaces"]:
                background, background_alpha = tm.resolve(tokens, surface, mode)
                base = tm.core_hex(tokens, tokens["color"]["semantic"][mode]["Surface/Primary"]) if background_alpha < 0.999 else background
                painted = tm.composite(background, background_alpha, base)
                painted_foreground = tm.composite(foreground, alpha, painted)
                ratio = tm.contrast_ratio(painted_foreground, painted)
                checked += 1
                status = "ok" if ratio >= minimum else "FAIL"
                if ratio < minimum:
                    failures.append(
                        "%s on %s (%s) is %.2f:1, needs %.1f:1 [%s]"
                        % (token, surface, mode, ratio, minimum, kind)
                    )
                print("%-4s %-22s on %-30s %-5s %.2f:1 (min %.1f)" % (status, token, surface, mode, ratio, minimum))

    for gradient in tokens["contrast"]["gradients"]:
        minimum = thresholds[gradient["kind"]]
        background = tm.core_hex(tokens, gradient["background"])
        for stop in gradient["stops"]:
            ratio = tm.contrast_ratio(stop, background)
            checked += 1
            if ratio < minimum:
                failures.append("%s stop %s on %s is %.2f:1, needs %.1f:1" % (gradient["name"], stop, background, ratio, minimum))
            print("%-4s gradient %-16s stop %-9s %.2f:1 (min %.1f)" % ("ok" if ratio >= minimum else "FAIL", gradient["name"], stop, ratio, minimum))

    print("\nChecked %d pairings." % checked)
    if failures:
        print("\nCONTRAST CHECK FAILED (%d):" % len(failures))
        for failure in failures:
            print("  - %s" % failure)
        return 1
    print("CONTRAST CHECK PASSED: every declared text, icon and border pairing meets WCAG AA.")
    return 0


if __name__ == "__main__":
    sys.exit(check())
