# keekee — Glove80 keymap overlay for macOS

A glanceable, always-on-top HUD of your **MoErgo Glove80** keymap. Press a global
hotkey from any app → both keyboard halves pop up; flip through layers from the home
row; press the hotkey again or **Esc** to dismiss.

No browser tab, no dock icon, fully offline. Hammerspoon binds the hotkey and loads a
self-contained local HTML file's contents into a non-activating `hs.webview`.

## What's here
| file | purpose |
|------|---------|
| `glove80.html` | self-contained viewer (inline CSS/JS, **your keymap embedded**) |
| `init.snippet.lua` | the Hammerspoon hotkey config |
| `README.md` | this file |

The deployed copies live at `~/.hammerspoon/glove80.html` and `~/.hammerspoon/init.lua`.

## Install (one time)

1. **Install Hammerspoon**
   ```sh
   brew install --cask hammerspoon
   ```
   Then launch **Hammerspoon** (Applications). A hammer icon appears in the menu bar.

2. **Grant Accessibility permission**
   On first launch macOS prompts for it. Otherwise:
   *System Settings → Privacy & Security → Accessibility → enable **Hammerspoon***.
   (Needed so the global hotkey + Esc work from any app.)

3. **Files are already in place** (`~/.hammerspoon/glove80.html` and `init.lua`).
   In the menu-bar hammer icon → **Reload Config**.

That's it. Press **⌘⌥⌃K** from any app.

> If you ever re-run the deploy from this repo: it copies `glove80.html` to
> `~/.hammerspoon/` and **appends** the snippet to `init.lua` only if not already there
> (it never clobbers an existing config).

## Using it

| action | keys |
|--------|------|
| **Show / hide** overlay | `⌃⇧⌥K` (Ctrl+Shift+Alt+K) |
| **Enlarge / shrink** (while shown) | `⌃⇧⌥L` |
| **Close** | `Esc` |
| **Prev / next layer** | `k` / `j` (also `h` / `l`, Helix-style), or click a layer tab |
| Load a **different keymap** | click *load keymap…* in the footer |

Both halves are shown at once, centered, so you can glance at them while typing.
Change the hotkey or sizes by editing the constants at the top of
`~/.hammerspoon/init.lua` (then *Reload Config*).

### How keys are rendered
- `&kp` keys show readable glyphs, including shifted symbols (`LS(N4)`→`$`, `LS(COMMA)`→`<`).
- Modifiers as symbols: `⌘ ⌥ ⌃ ⇧`; combos like `LG(LS(N4))`→`⌘⇧4`.
- **Mod-tap** `&mt`: big tap key + small mod badge (top-right, orange).
- **Layer-tap** `&lt` / layer holds (`&mo`, your custom `&layer_access`): purple `L<n>`
  with a `hold`/`sticky` note.
- `&sk` sticky mods are outlined green; `&to`/`&tog` show `→L<n>`/`⇄L<n>`.
- `&trans` shows **what's underneath** — the key from the Base layer, faded with a dashed
  border (so you see the effective key without it being remapped on this layer).
- `&none` (mapped to nothing) is a blank key with a single diagonal slash.
- `&magic`, `&bt`/`&out`/`&rgb_ug`, `&reset`/`&bootloader`, and your `&tmux_*` macros get
  sensible labels. Anything unrecognized shows its raw token (never crashes).

Your `&colon_semi` mod-morph renders as `:` (with `;` shown as its shifted form).

## Re-exporting your keymap later

1. Open your layout at **my.glove80.com** (Layout Editor).
2. Export / download the **JSON** for the layout.
3. Either:
   - **Quick swap (no rebuild):** click *load keymap…* in the overlay footer and pick the
     new JSON. (Lasts for that session.)
   - **Make it the default:** re-run the embed step so the new keymap is baked into the
     HTML:
     ```sh
     cd ~/Desktop/programming/git/keekee
     python3 build.py /path/to/new-export.json   # see below
     cp glove80.html ~/.hammerspoon/glove80.html
     ```
     Then Hammerspoon menu → **Reload Config** (the overlay reloads the file on every show,
     so usually just re-summoning it is enough).

The viewer assumes the standard Glove80 80-key physical layout, so any Glove80 Layout
Editor export will map onto the same board shape.

## Notes
- Everything is local — the HTML makes **no external requests**.
- The overlay is *non-activating*: it floats over your current app without stealing focus,
  so it won't interrupt typing.
