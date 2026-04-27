import json
import os
import shlex
from pathlib import Path

from kittens.tui.handler import result_handler

STATE = Path(os.path.expanduser("~/.local/state/kitty"))
STACK = STATE / "closed_windows.json"
FLAG = Path("/tmp/kitty_restore_inflight")


def main(args):
    pass


def _is_shell(cmd):
    if not cmd:
        return True
    base = os.path.basename(cmd[0]).lstrip("-")
    return base in ("ssh", "zsh", "bash", "fish", "sh", "tmux", "screen")


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    if not STACK.exists():
        return
    stack = json.loads(STACK.read_text() or "[]")
    if not stack:
        return
    entry = stack.pop()
    STACK.write_text(json.dumps(stack))

    cwd = entry.get("cwd") or "~"
    title = entry.get("title", "")
    cmd = entry.get("cmd") or []
    hist = entry.get("hist") or ""

    keep = {e.get("hist") for e in stack}
    keep.add(hist)
    for p in STATE.glob("hist_*.txt"):
        if str(p) not in keep:
            p.unlink(missing_ok=True)

    launch_args = ["launch", "--cwd=" + cwd]
    if title:
        launch_args.append("--window-title=" + title)

    if hist and Path(hist).exists():
        rm = "rm -f " + shlex.quote(hist)
        if _is_shell(cmd):
            wrapper = cmd[0]
            inner = (
                "cat " + shlex.quote(hist) + "; " + rm + "; exec " + shlex.quote(cmd[0])
            )
        else:
            wrapper = "sh"
            run = " ".join(shlex.quote(c) for c in cmd)
            inner = "cat " + shlex.quote(hist) + "; " + rm + "; exec " + run
        launch_args += [wrapper, "-c", inner]
    elif not _is_shell(cmd):
        launch_args += ["--hold", *cmd]

    FLAG.touch()
    boss.call_remote_control(None, ("close-window", "--match", "state:focused"))
    boss.call_remote_control(None, tuple(launch_args))
