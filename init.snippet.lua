-- ===========================================================================
-- Glove80 keymap overlay  (append to ~/.hammerspoon/init.lua)
-- Toggle: Ctrl+Shift+Alt+K | Resize: Ctrl+Shift+Alt+L | Load keymap: Ctrl+Shift+Alt+O | Esc closes
-- ===========================================================================
local g80 = {
  mods    = {"ctrl","shift","alt"},  -- <- change the hotkey here
  key     = "K",
  sizeKey = "L",                     -- toggles compact <-> large while shown
  loadKey = "O",                     -- pick a different keymap JSON
  file    = os.getenv("HOME") .. "/.hammerspoon/glove80.html",
  compact = { w = 1170, h = 675 },   -- default glanceable size (both halves)
  large   = { w = 1560, h = 900 },   -- enlarged size
}

local wv, escTap, shown, big = nil, nil, false, false

-- remembered across shows / restarts
local savedLayer = hs.settings.get("g80.layer") or 0
local savedPos   = hs.settings.get("g80.pos")          -- {x=, y=} or nil

local function readFile(path)
  local f = io.open(path, "r"); if not f then return nil end
  local c = f:read("*a"); f:close(); return c
end

-- keep a frame on-screen (in case the saved spot is off a now-disconnected display)
local function clamp(r)
  local sf = hs.screen.mainScreen():frame()
  r.x = math.max(sf.x, math.min(r.x, sf.x + sf.w - r.w))
  r.y = math.max(sf.y, math.min(r.y, sf.y + sf.h - r.h))
  return r
end

local function frameFor(size)
  if savedPos and savedPos.x then
    return clamp({ x = savedPos.x, y = savedPos.y, w = size.w, h = size.h })
  end
  local f = hs.screen.mainScreen():frame()   -- center on the active screen
  return { x = f.x + (f.w - size.w) / 2,
           y = f.y + (f.h - size.h) / 2,
           w = size.w, h = size.h }
end

-- capture current window position + selected layer so the next open restores them
local function persistState()
  if not wv then return end
  local fr = wv:frame()
  if fr then savedPos = { x = fr.x, y = fr.y }; hs.settings.set("g80.pos", savedPos) end
  wv:evaluateJavaScript("window.__g80layer", function(res)
    local n = tonumber(res)
    if n then savedLayer = math.floor(n); hs.settings.set("g80.layer", savedLayer) end
  end)
end

local function hide()
  persistState()
  if wv then wv:hide() end
  if escTap then escTap:stop(); escTap = nil end
  shown = false
end

local function show()
  local r = frameFor(big and g80.large or g80.compact)
  if not wv then
    wv = hs.webview.new(r)
      :windowStyle({ "titled", "closable", "nonactivating" })
      :level(hs.drawing.windowLevels.floating)
      :transparent(true)            -- let the translucent HTML show the app underneath
      :allowTextEntry(true)
      :shadow(true)
  else
    wv:frame(r)
  end
  -- Load the HTML *contents* directly (re-read from disk every show, so keymap
  -- edits appear without restarting HS). Using :html() avoids the WKWebView
  -- file:// sandbox issue that leaves the webview blank.
  local html = readFile(g80.file)
  if html then
    html = html:gsub("__INIT_LAYER__", tostring(savedLayer))  -- restore last tab
    wv:html(html)
  else
    wv:html("<body style='background:#0e1116;color:#fff;font:16px -apple-system;"
      .. "display:flex;align-items:center;justify-content:center;height:100vh'>"
      .. "glove80.html not found at<br>" .. g80.file .. "</body>")
  end
  wv:show():bringToFront(true)

  -- Esc closes (eventtap only while visible)
  escTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
    if e:getKeyCode() == hs.keycodes.map["escape"] then hide(); return true end
    return false
  end):start()
  shown = true
end

hs.hotkey.bind(g80.mods, g80.key, function()
  if shown then hide() else show() end
end)

hs.hotkey.bind(g80.mods, g80.sizeKey, function()
  if not shown then return end
  persistState()                 -- capture current position before resizing
  big = not big
  wv:frame(frameFor(big and g80.large or g80.compact))
  wv:bringToFront(true)
end)

-- Load a different keymap: HS shows the file dialog (the webview's own one isn't
-- available) and pushes the JSON into the page.
hs.hotkey.bind(g80.mods, g80.loadKey, function()
  if not (shown and wv) then return end
  local res = hs.dialog.chooseFileOrFolder(
    "Choose a Glove80 keymap JSON export:",
    os.getenv("HOME") .. "/Downloads", true, false, false, { "json" })
  local path = res and (res["1"] or res[1])
  if not path then return end
  local txt = readFile(path)
  if not txt then return end
  wv:evaluateJavaScript(
    "window.__loadKeymapB64 && window.__loadKeymapB64('" .. hs.base64.encode(txt) .. "')")
  wv:show():bringToFront(true)
end)
-- ===========================================================================
