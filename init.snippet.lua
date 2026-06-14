-- ===========================================================================
-- Glove80 keymap overlay  (append to ~/.hammerspoon/init.lua)
-- Toggle:  Ctrl+Shift+Alt+K  |  Resize compact/large: Ctrl+Shift+Alt+L  |  Esc closes
-- ===========================================================================
local g80 = {
  mods    = {"ctrl","shift","alt"},  -- <- change the hotkey here
  key     = "K",
  sizeKey = "L",                     -- toggles compact <-> large while shown
  file    = os.getenv("HOME") .. "/.hammerspoon/glove80.html",
  compact = { w = 1170, h = 675 },   -- default glanceable size (both halves)
  large   = { w = 1560, h = 900 },   -- enlarged size
}

local wv, escTap, shown, big = nil, nil, false, false

local function readFile(path)
  local f = io.open(path, "r"); if not f then return nil end
  local c = f:read("*a"); f:close(); return c
end

local function frameFor(size)
  local f = hs.screen.mainScreen():frame()   -- screen with the active window
  return { x = f.x + (f.w - size.w) / 2,
           y = f.y + (f.h - size.h) / 2,
           w = size.w, h = size.h }
end

local function hide()
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
  big = not big
  wv:frame(frameFor(big and g80.large or g80.compact))
  wv:bringToFront(true)
end)
-- ===========================================================================
