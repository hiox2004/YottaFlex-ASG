"""Export the prompt history of this project from Claude Code transcripts as readable, redacted markdown.

Captured: every prompt typed or pasted by the user (slash commands included) in every session of this project, the prompts
Claude sent to subagents, and the prompts Claude passed to helper models through WebFetch.
Not captured: AI responses (optional per the submission FAQ), tool results, and harness-injected context blocks
(system reminders, IDE notices). User text is kept verbatim except for the redactions below.
Redacted: the local OS username in file paths, e-mail addresses and common secret/token patterns.

Usage: python scripts/export_prompts.py [--source DIR] [--out DIR]
Re-run it before the final push so the history is current. Exit code 1 if a secret-like pattern is still found in the output.
"""

import argparse
import json
import re
import sys
from pathlib import Path

REDACTIONS = [
    (re.compile(r"(?i)(?<=[\\/]users[\\/])[^\\/\s\"'<>|:*?]+"), "<user>"),
    (
        re.compile(r"(?i)(?<=-users-)[a-z0-9_.]+(?=-)"),
        "<user>",
    ),  # Claude Code project slugs: c--Users-name-Desktop-...
    (re.compile(r"[\w.+-]+@[\w-]+\.[\w.-]+"), "<email>"),
    (re.compile(r"\bgh[pousr]_[A-Za-z0-9]{20,}"), "<token>"),
    (re.compile(r"\bgithub_pat_[A-Za-z0-9_]{20,}"), "<token>"),
    (re.compile(r"\bsk-[A-Za-z0-9_-]{20,}"), "<token>"),
    (re.compile(r"\bAKIA[0-9A-Z]{16}\b"), "<token>"),
    (re.compile(r"\bxox[abprs]-[A-Za-z0-9-]{10,}"), "<token>"),
    (re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----"), "<private-key>"),
]
STRIP = [
    re.compile(r"<system-reminder>.*?</system-reminder>", re.DOTALL),
    re.compile(r"<ide_[a-z_]+>.*?</ide_[a-z_]+>", re.DOTALL),
    re.compile(
        r"<local-command-(?:caveat|stdout)>.*?</local-command-(?:caveat|stdout)>", re.DOTALL
    ),
]
LEFTOVER = [p for p, _ in REDACTIONS[1:]] + [re.compile(r"(?i)[\\/]users[\\/](?!<user>)[^\\/\s]+")]


def redact(text: str) -> str:
    for pattern, replacement in REDACTIONS:
        text = pattern.sub(replacement, text)
    return text


def clean(text: str) -> str:
    for pattern in STRIP:
        text = pattern.sub("", text)
    return text.strip()


def _kind(record: dict):
    origin = record.get("origin")
    return origin.get("kind") if isinstance(origin, dict) else origin


def is_human_prompt(record: dict) -> bool:
    if (
        record.get("type") != "user"
        or record.get("sourceToolAssistantUUID")
        or record.get("isMeta")
    ):
        return False
    return _kind(record) in (None, "human")


def prompt_text(record: dict) -> str:
    content = record["message"]["content"]
    if isinstance(content, str):
        text = content
    else:
        parts = []
        for block in content:
            if block.get("type") == "text":
                parts.append(block["text"])
            elif block.get("type") == "document":
                parts.append(
                    f"[attached document: {block.get('title') or block.get('name') or 'unnamed'}]"
                )
            elif block.get("type") == "image":
                parts.append("[attached image]")
        text = "\n".join(parts)
    text = clean(text)
    command = re.search(r"<command-name>(.*?)</command-name>", text, re.DOTALL)
    if command:
        args = re.search(r"<command-args>(.*?)</command-args>", text, re.DOTALL)
        text = f"(command) {command.group(1).strip()}" + (
            f" {args.group(1).strip()}" if args and args.group(1).strip() else ""
        )
    return redact(text)


def _fence(text: str) -> str:
    longest = max((len(m) for m in re.findall(r"`+", text)), default=0)
    return "`" * max(3, longest + 1)


def _block(text: str) -> str:
    fence = _fence(text)
    return f"{fence}text\n{text}\n{fence}\n"


def _records(path: Path):
    for line in path.read_text(encoding="utf-8").splitlines():
        try:
            yield json.loads(line)
        except ValueError:
            continue


def session_prompts(path: Path) -> dict:
    prompts, models, started, ended = [], set(), None, None
    for r in _records(path):
        started = started or r.get("timestamp")
        ended = r.get("timestamp") or ended
        if (
            r.get("type") == "assistant"
            and isinstance(r.get("message"), dict)
            and r["message"].get("model")
        ):
            models.add(r["message"]["model"])
        if is_human_prompt(r):
            text = prompt_text(r)
            if text:
                prompts.append((r["timestamp"], text))
    return {"prompts": prompts, "models": sorted(models), "started": started, "ended": ended}


def helper_prompts(path: Path) -> list[tuple[str, str, str]]:
    """Prompts Claude passed to helper models via WebFetch: (timestamp, url, prompt)."""
    out = []
    for r in _records(path):
        if r.get("type") == "assistant" and isinstance(r["message"].get("content"), list):
            for b in r["message"]["content"]:
                if b.get("type") == "tool_use" and b.get("name") == "WebFetch":
                    out.append(
                        (
                            r["timestamp"],
                            redact(b["input"].get("url", "")),
                            redact(b["input"].get("prompt", "")),
                        )
                    )
    return out


def subagent_prompts(session_dir: Path) -> list[dict]:
    out = []
    for jsonl in (
        sorted((session_dir / "subagents").glob("agent-*.jsonl"))
        if (session_dir / "subagents").is_dir()
        else []
    ):
        meta_path = jsonl.with_suffix(".meta.json")
        meta = json.loads(meta_path.read_text(encoding="utf-8")) if meta_path.exists() else {}
        for r in _records(jsonl):
            if r.get("type") == "user" and not r.get("sourceToolAssistantUUID"):
                content = r["message"]["content"]
                text = (
                    content
                    if isinstance(content, str)
                    else "\n".join(b.get("text", "") for b in content if b.get("type") == "text")
                )
                out.append({"time": r["timestamp"], "meta": meta, "prompt": redact(clean(text))})
                break
    return sorted(out, key=lambda x: x["time"])


def find_source(cwd: Path) -> Path:
    slug = re.sub(r"[^A-Za-z0-9]", "-", str(cwd)).lower()
    root = Path.home() / ".claude" / "projects"
    for d in root.iterdir() if root.is_dir() else []:
        if d.name.lower() == slug:
            return d
    raise SystemExit(f"no Claude Code transcripts found for {cwd} under {root}; pass --source")


def leftovers(text: str) -> list[str]:
    return [
        m.group(0)
        for p in LEFTOVER
        for m in p.finditer(text)
        if m.group(0) not in ("<user>", "<email>")
    ]


def previous_counts(out: Path) -> dict[str, int]:
    """Session id (8 chars) -> user prompts recorded in an existing export."""
    counts = {}
    for f in out.glob("session-*.md"):
        text = f.read_text(encoding="utf-8")
        sid = re.search(r"^# Session \d+ \((\w+)\)", text, re.MULTILINE)
        n = re.search(r"user prompts: (\d+)", text)
        if sid and n:
            counts[sid.group(1)] = int(n.group(1))
    return counts


def check_not_shrinking(previous: dict[str, int], current: dict[str, int], force: bool) -> None:
    """The export rebuilds everything from local transcripts; never let that silently replace committed history with less."""
    lost = {s: (n, current.get(s, 0)) for s, n in previous.items() if current.get(s, 0) < n}
    if lost and not force:
        detail = ", ".join(f"{s}: {old} -> {new}" for s, (old, new) in sorted(lost.items()))
        raise SystemExit(
            f"refusing to overwrite the existing history with fewer prompts ({detail}); "
            "the transcripts may have been trimmed. Re-run with --force only if that is intended."
        )


def export(source: Path, out: Path, force: bool = False) -> dict:
    out.mkdir(parents=True, exist_ok=True)
    sessions = sorted(
        source.glob("*.jsonl"), key=lambda p: next(_records(p)).get("timestamp") or ""
    )
    current = {p.stem[:8]: len(session_prompts(p)["prompts"]) for p in sessions}
    check_not_shrinking(previous_counts(out), current, force)
    rows, findings, helpers, subs = [], [], [], []
    for n, path in enumerate(sessions, start=1):
        data = session_prompts(path)
        name = f"session-{n}.md"
        lines = [
            f"# Session {n} ({path.stem[:8]})",
            "",
            f"UTC {data['started']} to {data['ended']} | models used: {', '.join(data['models']) or 'unknown'} | user prompts: {len(data['prompts'])}",
            "",
            "Prompts typed or pasted by the user, in order. Repeated `/loop` entries are scheduled re-runs of the same prompt.",
            "",
        ]
        for i, (ts, text) in enumerate(data["prompts"], start=1):
            lines += [f"## {i}. {ts}", "", _block(text)]
        body = "\n".join(lines)
        findings += leftovers(body)
        (out / name).write_text(body, encoding="utf-8", newline="\n")
        first = data["prompts"][0][1].replace("\n", " ")[:90] if data["prompts"] else ""
        agents = subagent_prompts(source / path.stem)
        subs += [(n, a) for a in agents]
        helpers += [(n, *h) for h in helper_prompts(path)]
        rows.append((name, path.stem[:8], data, len(agents), first))
    extra = [
        "# Prompts sent to subagents and helper models",
        "",
        "Prompts Claude wrote and sent to other models on the user's behalf.",
        "",
    ]
    extra += ["## Subagents", ""]
    for n, a in subs:
        m = a["meta"]
        extra += [
            f"### Session {n}, {a['time']}: {m.get('agentType', '?')} on {m.get('model', 'default')} ({m.get('description', '')})",
            "",
            _block(a["prompt"]),
        ]
    extra += ["## WebFetch helper-model prompts", ""]
    for n, ts, url, prompt in helpers:
        extra += [f"### Session {n}, {ts}: {url}", "", _block(prompt)]
    body = "\n".join(extra)
    findings += leftovers(body)
    (out / "subagent-and-helper-prompts.md").write_text(body, encoding="utf-8", newline="\n")
    index = [
        "# Prompt history index",
        "",
        "Generated by `scripts/export_prompts.py` from the Claude Code transcripts of this project. See `../README.md` for scope, redactions and limits.",
        "",
        "| File | Session | Started (UTC) | Ended (UTC) | User prompts | Subagent prompts | Models | First prompt |",
        "|---|---|---|---|---|---|---|---|",
    ]
    for name, sid, d, n_agents, first in rows:
        index.append(
            f"| [{name}]({name}) | {sid} | {d['started']} | {d['ended']} | {len(d['prompts'])} | {n_agents} | {', '.join(d['models'])} | {redact(first).replace('|', '/')} |"
        )
    index.append(
        f"| [subagent-and-helper-prompts.md](subagent-and-helper-prompts.md) | all | | | | {len(subs)} subagents, {len(helpers)} WebFetch | | prompts Claude sent to other models |"
    )
    (out / "README.md").write_text("\n".join(index) + "\n", encoding="utf-8", newline="\n")
    return {
        "sessions": len(rows),
        "user_prompts": sum(len(r[2]["prompts"]) for r in rows),
        "subagent_prompts": len(subs),
        "webfetch_prompts": len(helpers),
        "findings": findings,
    }


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument(
        "--source",
        type=Path,
        help="Claude Code project transcript directory (default: found from the current directory)",
    )
    parser.add_argument("--out", type=Path, default=Path("ai-transparency/prompt-history"))
    parser.add_argument(
        "--force",
        action="store_true",
        help="overwrite even if the new export has fewer prompts than the existing one",
    )
    args = parser.parse_args(argv)
    result = export(args.source or find_source(Path.cwd()), args.out, force=args.force)
    print(
        f"sessions {result['sessions']} | user prompts {result['user_prompts']} | subagent prompts {result['subagent_prompts']} "
        f"| WebFetch prompts {result['webfetch_prompts']} | secret-like leftovers {len(result['findings'])}"
    )
    return 1 if result["findings"] else 0


if __name__ == "__main__":
    sys.exit(main())
