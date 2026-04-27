import fcntl
import json
import os
import time
from pathlib import Path

STATE = Path(os.path.expanduser("~/.local/state/kitty"))
STACK = STATE / "closed_windows.json"
FLAG = Path("/tmp/kitty_restore_inflight")


def on_load(boss, data):
    STATE.mkdir(parents=True, exist_ok=True)


def on_close(boss, window, data):
    if FLAG.exists():
        FLAG.unlink()
        return
    try:
        cwd = window.cwd_of_child or ""
        cmd = window.child.foreground_cmdline or []
        title = window.title
    except Exception:
        return
    if not cwd and not cmd:
        return

    ts = time.time()
    hist_path = ""
    try:
        hist = window.as_text(as_ansi=True, add_history=True)
        if hist:
            hist = hist.rstrip("\n") + "\n"
            p = STATE / f"hist_{int(ts * 1000)}.txt"
            p.write_text(hist[-200000:])
            hist_path = str(p)
    except Exception:
        pass

    entry = {"cwd": cwd, "cmd": cmd, "title": title, "ts": ts, "hist": hist_path}
    STATE.mkdir(parents=True, exist_ok=True)
    with open(STACK, "a+") as f:
        fcntl.flock(f, fcntl.LOCK_EX)
        f.seek(0)
        try:
            stack = json.loads(f.read() or "[]")
        except json.JSONDecodeError:
            stack = []
        stack.append(entry)
        stack[:] = stack[-20:]
        f.seek(0)
        f.truncate()
        f.write(json.dumps(stack))
        fcntl.flock(f, fcntl.LOCK_UN)
