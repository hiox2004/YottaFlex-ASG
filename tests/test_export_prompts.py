import importlib.util
import json
from pathlib import Path

import pytest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "export_prompts.py"
spec = importlib.util.spec_from_file_location("export_prompts", SCRIPT)
ep = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ep)


def user(ts, content, **extra):
    return {
        "type": "user",
        "timestamp": ts,
        "message": {"role": "user", "content": content},
        **extra,
    }


def write_jsonl(path, records):
    path.write_text("\n".join(json.dumps(r) for r in records) + "\n", encoding="utf-8")


@pytest.fixture
def source(tmp_path):
    src = tmp_path / "transcripts"
    (src / "aaaa1111" / "subagents").mkdir(parents=True)
    write_jsonl(
        src / "aaaa1111.jsonl",
        [
            user(
                "2026-10-30T06:00:00Z",
                "build the thing in C:\\Users\\alice\\Desktop\\proj",
                origin="human",
            ),
            user(
                "2026-10-30T06:01:00Z",
                [{"type": "tool_result", "content": "SECRET OUTPUT"}],
                sourceToolAssistantUUID="x",
            ),
            user("2026-10-30T06:02:00Z", "injected context", isMeta=True),
            user(
                "2026-10-30T06:03:00Z",
                "<task-notification>done</task-notification>",
                origin="task-notification",
            ),
            user(
                "2026-10-30T06:04:00Z",
                [
                    {
                        "type": "text",
                        "text": "<system-reminder>userEmail alice@example.com</system-reminder>",
                    },
                    {
                        "type": "text",
                        "text": "please read this\n```python\nprint(1)\n```\ntoken ghp_abcdefghijklmnopqrstuvwxyz0123",
                    },
                    {
                        "type": "document",
                        "title": "Brief.pdf",
                        "source": {"type": "base64", "data": "AAAA"},
                    },
                ],
                origin="human",
            ),
            user(
                "2026-10-30T06:05:00Z",
                "<command-name>/loop</command-name><command-args>keep going</command-args>",
            ),
            user("2026-10-30T06:06:00Z", "<local-command-stdout>Set model</local-command-stdout>"),
            {
                "type": "assistant",
                "timestamp": "2026-10-30T06:07:00Z",
                "message": {
                    "model": "claude-test-1",
                    "content": [
                        {
                            "type": "tool_use",
                            "name": "WebFetch",
                            "input": {"url": "https://x.test", "prompt": "summarise for bob@x.com"},
                        }
                    ],
                },
            },
        ],
    )
    sub = src / "aaaa1111" / "subagents"
    write_jsonl(
        sub / "agent-a1.jsonl",
        [
            user("2026-10-30T06:08:00Z", "review the design"),
            user("2026-10-30T06:09:00Z", "later", sourceToolAssistantUUID="y"),
        ],
    )
    (sub / "agent-a1.meta.json").write_text(
        json.dumps(
            {"agentType": "general-purpose", "model": "opus", "description": "design review"}
        ),
        encoding="utf-8",
    )
    return src


def test_filters_keep_only_what_the_user_submitted(source, tmp_path):
    out = tmp_path / "out"
    result = ep.export(source, out)
    text = (out / "session-1.md").read_text(encoding="utf-8")
    assert result["user_prompts"] == 3 and result["sessions"] == 1
    assert (
        "SECRET OUTPUT" not in text
        and "injected context" not in text
        and "task-notification" not in text
    )
    assert "Set model" not in text
    assert "(command) /loop keep going" in text
    assert "[attached document: Brief.pdf]" in text and "AAAA" not in text
    assert "claude-test-1" in text


def test_redaction_and_secret_scan(source, tmp_path):
    out = tmp_path / "out"
    result = ep.export(source, out)
    everything = "".join(p.read_text(encoding="utf-8") for p in out.glob("*.md"))
    assert "alice" not in everything and "C:\\Users\\<user>\\Desktop\\proj" in everything
    assert "alice@example.com" not in everything and "bob@x.com" not in everything
    assert "ghp_abcdef" not in everything and "<token>" in everything
    assert result["findings"] == []
    assert ep.leftovers("see C:\\Users\\carol\\x and ghp_abcdefghijklmnopqrstuvwxyz0123") != []


def test_code_fences_inside_a_prompt_do_not_break_the_block(source, tmp_path):
    out = tmp_path / "out"
    ep.export(source, out)
    text = (out / "session-1.md").read_text(encoding="utf-8")
    assert "````text" in text  # outer fence is longer than the inner ``` fence


def test_subagent_and_helper_prompts(source, tmp_path):
    out = tmp_path / "out"
    result = ep.export(source, out)
    text = (out / "subagent-and-helper-prompts.md").read_text(encoding="utf-8")
    assert result["subagent_prompts"] == 1 and result["webfetch_prompts"] == 1
    assert (
        "general-purpose on opus (design review)" in text
        and "review the design" in text
        and "later" not in text
    )
    assert "summarise for <email>" in text and "https://x.test" in text


def test_index_lists_every_session_and_is_deterministic(source, tmp_path):
    ep.export(source, tmp_path / "a")
    ep.export(source, tmp_path / "b")
    index = (tmp_path / "a" / "README.md").read_text(encoding="utf-8")
    assert "session-1.md" in index and "aaaa1111" in index
    for name in ("README.md", "session-1.md", "subagent-and-helper-prompts.md"):
        assert (tmp_path / "a" / name).read_bytes() == (tmp_path / "b" / name).read_bytes()


def test_missing_transcripts_is_a_clear_error(tmp_path, monkeypatch):
    monkeypatch.setattr(ep.Path, "home", classmethod(lambda cls: tmp_path))
    with pytest.raises(SystemExit, match="no Claude Code transcripts"):
        ep.find_source(tmp_path / "nowhere")


def test_rebuild_refuses_to_shrink_committed_history(source, tmp_path):
    out = tmp_path / "out"
    ep.export(source, out)
    kept = [
        json.loads(line)
        for line in (source / "aaaa1111.jsonl").read_text(encoding="utf-8").splitlines()
    ][:1]
    write_jsonl(
        source / "aaaa1111.jsonl", kept
    )  # transcript trimmed: only the first prompt is left
    before = (out / "session-1.md").read_bytes()
    with pytest.raises(SystemExit, match="fewer prompts"):
        ep.export(source, out)
    assert (out / "session-1.md").read_bytes() == before  # nothing was overwritten
    ep.export(source, out, force=True)
    assert "user prompts: 1" in (out / "session-1.md").read_text(encoding="utf-8")


def test_rebuild_refuses_when_a_session_disappears_and_allows_growth(source, tmp_path):
    out = tmp_path / "out"
    ep.export(source, out)
    records = [
        json.loads(line)
        for line in (source / "aaaa1111.jsonl").read_text(encoding="utf-8").splitlines()
    ]
    records.append(user("2026-10-30T07:00:00Z", "one more prompt", origin="human"))
    write_jsonl(source / "aaaa1111.jsonl", records)
    assert ep.export(source, out)["user_prompts"] == 4  # growth is fine
    (source / "aaaa1111.jsonl").unlink()
    write_jsonl(source / "bbbb2222.jsonl", [user("2026-10-30T08:00:00Z", "other", origin="human")])
    with pytest.raises(SystemExit, match="aaaa1111: 4 -> 0"):
        ep.export(source, out)


def test_project_slug_username_is_redacted():
    text = ep.redact("see temp/claude/c--Users-alice-Desktop-Proj/x")
    assert "alice" not in text and "c--Users-<user>-Desktop-Proj" in text
    assert ep.leftovers("c--Users-alice-Desktop-Proj") != []
