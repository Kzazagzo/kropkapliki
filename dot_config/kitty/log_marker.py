#!/usr/bin/env python
# Kitty marker: always-on highlighting of log levels and docker/systemd states.
# Enabled via `watcher log_marker.py` in kitty.conf: kitty.conf has no option to
# set a marker, so the watcher arms it on every new window.
# Colors are limited to 3 by kitty (mark1/mark2/mark3 in kitty.conf).

import re

BAD = 1     # errors, dead containers, 4xx/5xx, non-zero exits
WARN = 2    # warnings, transitional states, 3xx, skipped
GOOD = 3    # success, healthy, 2xx, exit 0

# Ordered: the first pattern that matches at a position wins, so the specific
# ones (exit 0, HTTP codes) must come before the bare keyword lists.
HTTP = (r'(?:HTTP/[\d.]+"?\s+|HTTP\s+|(?:status|status_code|code|rc|response)[=:]\s*'
        r'|\s-\s|->\s*|\[)')
EXIT = r'\bexit(?:ed)?(?:code)?\b(?:\s+with)?(?:\s+(?:status|code))?\s*[=:]?\s*\(?'

PATTERNS = (
    (GOOD, EXIT + r'0\b\)?'),
    (BAD, EXIT + r'\d+\)?'),
    (BAD, r'\bnon-zero\b'),
    # HTTP status classes, Firefox-style: 1xx/2xx fine, 3xx redirect, 4xx/5xx bad
    (GOOD, HTTP + r'[12]\d\d\b\]?'),
    (WARN, HTTP + r'3\d\d\b\]?'),
    (BAD, HTTP + r'[45]\d\d\b\]?'),
    (BAD, r'[✗✘✖]'),
    (GOOD, r'[✓✔]'),
    (BAD, r'\b(?:error|errors|err|fatal|critical|crit|panic|failed|failure|fail|exception|traceback|denied|refused|timeout|timed\s+out|unhealthy|dead|oomkilled|crashloopbackoff|down)\b'),
    (WARN, r'\b(?:warn|warning|warnings|deprecated|retrying|restarting|pending|starting|created|paused|degraded|slow|skipped|skip|xfail|masked|disabled|inactive)\b'),
    (GOOD, r'\b(?:ok|okay|success|succeeded|done|ready|healthy|running|up|active|started|listening|connected|passed|pass|enabled|loaded)\b'),
)

PAT = re.compile('|'.join(f'(?P<g{i}>{p})' for i, (_, p) in enumerate(PATTERNS)), re.IGNORECASE)
COLORS = {f'g{i}': c for i, (c, _) in enumerate(PATTERNS)}


def marker(text):
    for m in PAT.finditer(text):
        yield m.start(), m.end() - 1, COLORS[m.lastgroup]


# --- watcher side: arm the marker once per window ---
# ponytail: on_resize is the earliest per-window event kitty offers a watcher
_armed = set()


def on_resize(boss, window, data):
    if window.id not in _armed:
        _armed.add(window.id)
        window.set_marker(['function', 'log_marker.py'])


if __name__ == '__main__':
    # ponytail: one runnable check, run with `python log_marker.py`
    def colors(text):
        return [c for _, _, c in marker(text)]

    def hit(text):
        return [(text[a:b + 1], c) for a, b, c in marker(text)]

    assert hit('container unhealthy, was healthy') == [('unhealthy', BAD), ('healthy', GOOD)]
    assert colors('ERROR: warn later, OK') == [BAD, WARN, GOOD]
    assert list(marker('nothing here')) == []
    assert colors('Exited (0) 2 minutes ago') == [GOOD]
    assert colors('Exited (137) ago') == [BAD]
    assert colors('exit status 1') == [BAD]
    assert colors('process exited with code 0') == [GOOD]
    assert colors('"GET / HTTP/1.1" 200') == [GOOD]
    assert colors('HTTP/1.1 503 x') == [BAD]
    assert colors('status=301') == [WARN]
    assert colors('HTTP 101 switching') == [GOOD]
    assert colors('GET /x -> 404') == [BAD]
    assert colors('resp [204] code=418 rc:500') == [GOOD, BAD, BAD]
    assert colors('port :8404 up') == [GOOD]  # bare numbers are not HTTP codes
    assert colors('✓ 12 passed, ✗ 1 failed') == [GOOD, GOOD, BAD, BAD]
    print('ok')
