#!/usr/bin/env python3
"""Stream a chat completion from ds4-server and report measured decode tok/s (no guessing)."""
import json, sys, time, urllib.request
prompt = sys.argv[1] if len(sys.argv) > 1 else "Write a Python function that parses an ISO-8601 date string and returns a datetime, with docstring and 3 example usages."
think = "--think" in sys.argv
payload = {"model": "deepseek-v4-flash", "stream": True, "stream_options": {"include_usage": True},
           "messages": [{"role": "user", "content": prompt}]}
if not think: payload["thinking"] = {"type": "disabled"}
req = urllib.request.Request("http://127.0.0.1:8000/v1/chat/completions", data=json.dumps(payload).encode(),
                             headers={"Content-Type": "application/json"})
t0 = time.monotonic(); first = None; usage = None; fr = None; r_chars = a_chars = 0
with urllib.request.urlopen(req, timeout=7200) as r:
    for line in r:
        l = line.decode().strip()
        if not l.startswith("data: "): continue
        b = l[6:]
        if b == "[DONE]": break
        c = json.loads(b)
        if c.get("usage"): usage = c["usage"]
        ch = (c.get("choices") or [{}])[0]; d = ch.get("delta") or {}
        rc = d.get("reasoning_content") or ""; co = d.get("content") or ""
        if (rc or co) and first is None: first = time.monotonic()
        r_chars += len(rc); a_chars += len(co)
        if ch.get("finish_reason"): fr = ch["finish_reason"]
t1 = time.monotonic(); ct = usage["completion_tokens"]
print(json.dumps({"thinking": think, "ttft_s": round(first - t0, 2), "wall_s": round(t1 - t0, 1),
                  "completion_tokens": ct, "decode_tok_s": round(ct / (t1 - first), 2),
                  "finish_reason": fr, "reasoning_chars": r_chars, "answer_chars": a_chars}, indent=2))
