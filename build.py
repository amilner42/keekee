#!/usr/bin/env python3
"""Embed a MoErgo Glove80 Layout Editor JSON export into glove80.html.

Usage:
    python3 build.py /path/to/glove80-export.json
    python3 build.py              # auto-pick newest *.json in ~/Downloads

Re-runnable: it replaces the KEYMAP_RAW blob already in glove80.html.
After running, copy glove80.html to ~/.hammerspoon/ (or just re-summon the overlay,
which reloads the file on every show).
"""
import json, re, sys, glob, os

HERE = os.path.dirname(os.path.abspath(__file__))
HTML = os.path.join(HERE, "glove80.html")


def pick_source():
    if len(sys.argv) > 1:
        return sys.argv[1]
    cands = sorted(glob.glob(os.path.expanduser("~/Downloads/*.json")),
                   key=os.path.getmtime, reverse=True)
    for c in cands:
        try:
            d = json.load(open(c, encoding="utf-8"))
            if "layers" in d and "layer_names" in d:
                print("auto-picked newest export:", c)
                return c
        except Exception:
            pass
    sys.exit("no keymap JSON given and none found in ~/Downloads")


def main():
    src = pick_source()
    d = json.load(open(src, encoding="utf-8"))
    if "layers" not in d or "layer_names" not in d:
        sys.exit("not a Glove80 Layout Editor export (missing layers/layer_names)")
    subset = {
        "layer_names": d["layer_names"],
        "layers": d["layers"],
        "holdTaps": d.get("holdTaps", []),
        "macros": [{"name": m.get("name")} for m in d.get("macros", [])],
        "title": d.get("title"),
    }
    blob = json.dumps(subset, separators=(",", ":"), ensure_ascii=False)

    html = open(HTML, encoding="utf-8").read()
    anchor = r"/\* ---------- physical layout"
    pat = re.compile(r"const KEYMAP_RAW = [\s\S]*?;\s*\n\s*\n\s*(?=" + anchor + ")")
    if "__KEYMAP_JSON__" in html:                       # fresh template
        html = html.replace("__KEYMAP_JSON__", blob)
    elif pat.search(html):                              # already-built file
        html = pat.sub("const KEYMAP_RAW = " + blob + ";\n\n", html)
    else:
        sys.exit("could not locate KEYMAP_RAW assignment in glove80.html")
    open(HTML, "w", encoding="utf-8").write(html)
    print("embedded %d layers (%s), %d bytes" %
          (len(subset["layers"]), ", ".join(subset["layer_names"]), len(blob)))


if __name__ == "__main__":
    main()
