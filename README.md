# keekee — Glove80 keymap overlay for macOS

Press a hotkey from any app → an always-on-top HUD of your **MoErgo Glove80** keymap
(both halves, every layer) pops up. Press again or **Esc** to dismiss. Offline, no
dock icon. Built on Hammerspoon + a single self-contained HTML file.

## Setup

1. Install Hammerspoon and grant it Accessibility:
   ```sh
   brew install --cask hammerspoon
   ```
   Launch it → grant **System Settings → Privacy & Security → Accessibility → Hammerspoon**.

2. Embed your keymap. Export your layout JSON from **my.glove80.com** (Layout Editor),
   then:
   ```sh
   python3 build.py /path/to/your-export.json   # or no arg = newest *.json in ~/Downloads
   ```

3. Install the files:
   ```sh
   cp glove80.html ~/.hammerspoon/glove80.html
   cat init.snippet.lua >> ~/.hammerspoon/init.lua   # appends; won't clobber existing config
   ```

4. Hammerspoon menu-bar icon → **Reload Config**.

## Use

| | |
|---|---|
| toggle overlay | `⌃⇧⌥K` |
| prev / next layer | `k` / `j` (or `h` / `l`, or click a tab) |
| resize | `⌃⇧⌥L` |
| load another keymap (session only) | `⌃⇧⌥O` |
| close | `Esc` |

Window position and selected layer are remembered between opens.

## Notes

- Re-export after editing your layout → re-run step 2–3 (overlay reloads on each open).
- Edit the hotkey/sizes at the top of `init.snippet.lua` (the `g80` table).
- Handles `&kp` (incl. shifted symbols), mods, mod/layer-taps, sticky, `&magic`, macros,
  etc. `&trans` shows the underlying Base key (faded); `&none` shows a slash; unknown
  behaviors show their raw token.
