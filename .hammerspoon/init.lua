function init()
  hs.window.animationDuration = 0
  hs.window.spacesModifiers = {alt = true}

  hs.grid.GRIDWIDTH = 2
  hs.grid.GRIDHEIGHT = 1
  hs.grid.MARGINX = 0
  hs.grid.MARGINY = 0

  hs.hotkey.bind({"alt", "ctrl"}, "r", hs.reload)

  hs.hotkey.bind({"alt"}, "v", function()
    for i = 1, 20 do
      hs.timer.doAfter(i * 0.05, function()
        local p = hs.mouse.getAbsolutePosition()
        hs.eventtap.leftClick(p)
      end)
    end
  end)

  hs.hotkey.bind({"alt"}, "return",
      hs.fnutils.applyL(hs.applescript.applescript, [[do shell script "/usr/bin/open -n -a iTerm"]]))
  hs.hotkey.bind({"alt", "shift"}, "c", focusedWin(hs.window.close))

  for key, dir in pairs({h = "West", j = "South", k = "North", l = "East"}) do
    hs.hotkey.bind({"alt"}, key, focusedWin(hs.window["focusWindow" .. dir], true))
  end
  hs.hotkey.bind({"alt"}, "i", focusedWin(hs.window.focusNearestWindow, true))
  hs.hotkey.bind({"alt"}, "o", focusedWin(hs.window.focusOtherScreenWindow, true))

  local resizeWidth = 10 / 1920 * 9
  for key, v in pairs({h = {x = -resizeWidth, y = 0}, l = {x = resizeWidth, y = 0}}) do
    hs.hotkey.bind({"alt", "shift"}, key, focusedWin(hs.fnutils.applyR(hs.window.resizeWithGrids, v.x, v.y)))
  end

  for key, v in pairs({s = {x = -1, y = 0}, f = {x = 1, y = 0}}) do
    hs.hotkey.bind({"alt"}, key, focusedWin(hs.fnutils.applyR(hs.window.moveByGrid, v.x, v.y)))
  end
  hs.hotkey.bind({"alt", "shift"}, "i", focusedWin(hs.window.moveToNearestGrid))
  hs.hotkey.bind({"alt", "shift"}, "o", focusedWin(hs.window.moveToOtherScreen))

  hs.hotkey.bind({"alt"}, "m", focusedWin(hs.window.toggleMaximize))

  for i = 1, 9 do
    local key = tostring(i)
    -- NOTE
    -- Option(Alt) + [1-9] で対応するスペースに移動するようにシステムの環境設定を行うことで動作する
    hs.hotkey.bind({"alt", "shift"}, key, focusedWin(hs.fnutils.applyR(hs.window.moveToSpace, key)))
  end

  for key, op in pairs({pageup = "+", pagedown = "-"}) do
    hs.hotkey.bind({}, key, function()
      local _, volume = hs.applescript.applescript("output volume of (get volume settings) " .. op .. " 1")
      hs.alert.show("volume " .. volume , 1)
      hs.applescript.applescript("set volume output volume " .. volume)
    end)
  end
end

do
  function hs.fnutils.applyL(f, ...)
    local args = {...}
    return function(...)
      local t = hs.fnutils.copy(args)
      hs.fnutils.concat(t, {...})
      return f(table.unpack(t))
    end
  end

  function hs.fnutils.applyR(f, ...)
    local args = {...}
    return function(...)
      local t = {...}
      hs.fnutils.concat(t, args)
      return f(table.unpack(t))
    end
  end
end

-- 疑似的なfloatingのトグル
do
  local floatingFrames = {}

  function hs.window:saveFloatingFrame()
    local id = self:id()
    floatingFrames[id] = self:frame()
  end

  function hs.window:toFloating()
    local id = self:id()
    if floatingFrames[id] then
      self:setFrame(floatingFrames[id])
      floatingFrames[id] = nil
    end
  end
end

do
  function hs.window.standardWindows()
    return hs.fnutils.filter(
        hs.window.visibleWindows(),
        function(win) return win:isStandard() end)
  end

  function hs.window:center()
    local f = self:frame()
    return {x = f.x + f.w / 2, y = f.y + f.h / 2}
  end

  function hs.window:distanceTo(win)
    local a, b = self:center(), win:center()
    return math.abs(a.x - b.x) + math.abs(a.y - b.y)
  end

  function hs.window:focusNearestWindow()
    local d, target = 999999, self
    for i, win in ipairs(hs.window.standardWindows()) do
      if self ~= win and self:screen() == win:screen() and self:distanceTo(win) < d then
        d = self:distanceTo(win)
        target = win
      end
    end
    target:focus()
  end

  function hs.window:focusOtherScreenWindow()
    local screen = self:screen()
    for i, win in ipairs(hs.window.standardWindows()) do
      if win:screen() ~= screen then
        win:focus()
        return
      end
    end
  end

  function hs.window:moveToOtherScreen()
    self:moveToScreen(self:screen():next())
  end

  function hs.window:resizeWithGrids(x, y)
    local grid = hs.grid.getNearestGrid(self)
    local f = self:frame()
    local sf = self:screen():frame()
    local s = {w = sf.w * x, h = sf.h * y}

    self:setFrame({
      x = grid.x == hs.grid.GRIDWIDTH - 1 and f.x + s.w or f.x,
      y = grid.y == hs.grid.GRIDHEIGHT - 1 and f.y - s.h or f.y,
      w = f.w + s.w * (grid.x == 0 and 1 or -1),
      h = f.h - s.h * (grid.y == 0 and 1 or -1),
    })
  end

  function hs.window:moveToNearestGrid()
    hs.grid.set(self, hs.grid.getNearestGrid(self), self:screen())
  end

  function hs.window:moveByGrid(x, y)
    local screen = self:screen()
    local grid = hs.grid.getNearestGrid(self)
    grid, screen = hs.grid.moveGrid(grid, x, y, screen)
    hs.grid.set(self, grid, screen)
  end

  function hs.window:toggle(frame)
    local threshold = 20
    local current = self:frame()
    if math.abs(frame.x - current.x) < threshold
        and math.abs(frame.y - current.y) < threshold
        and math.abs(frame.w - current.w) < threshold
        and math.abs(frame.h - current.h) < threshold then
      self:toFloating()
    else
      self:saveFloatingFrame()
      self:setFrame(frame)
    end
  end

  function hs.window:toggleMaximize()
    self:toggle(self:screen():frame())
  end
end

do
  function hs.grid.getNearestGrid(win)
    local center = win:center()
    local screenrect = win:screen():frame()
    return {
      x = math.floor((center.x - screenrect.x) / (screenrect.w / hs.grid.GRIDWIDTH)),
      y = math.floor((center.y - screenrect.y) / (screenrect.h / hs.grid.GRIDHEIGHT)),
      w = 1, h = 1
    }
  end

  function hs.grid.moveGrid(grid, x, y, screen)
    grid.x = grid.x + x
    grid.y = grid.y + y

    while grid.x < 0 do
      if not screen or not screen:toWest() then
        grid.x = 0
        break
      end
      grid.x = grid.x + hs.grid.GRIDWIDTH
      screen = screen:toWest()
    end
    while hs.grid.GRIDWIDTH < grid.x + grid.w do
      if not screen or not screen:toEast() then
        grid.x = hs.grid.GRIDWIDTH - grid.w
        break
      end
      grid.x = grid.x - hs.grid.GRIDWIDTH
      screen = screen:toEast()
    end
    while grid.y < 0 do
      if not screen or not screen:toNorth() then
        grid.y = 0
        break
      end
      grid.y = grid.y + hs.grid.GRIDWIDTH
      screen = screen:toNorth()
    end
    while hs.grid.GRIDHEIGHT < grid.y + grid.h do
      if not screen or not screen:toSouth() then
        grid.y = hs.grid.GRIDWIDTH - grid.h
        break
      end
      grid.y = grid.y - hs.grid.GRIDWIDTH
      screen = screen:toSouth()
    end

    return grid, screen
  end
end

-- spaces support from mjolnir.ny.tiling
-- https://github.com/nathyong/mjolnir.ny.tiling
-- mousedownを発行、スペース移動、mouseupを発行としてウィンドウと一緒にspace移動する
do
  function hs.window:moveToSpace(key)
    local bak = hs.mouse.getAbsolutePosition()
    local pos = self:zoomButtonRect()

    pos.x = pos.x + pos.w + 5
    pos.y = pos.y + (pos.h / 2)

    hs.mouse.setAbsolutePosition(pos)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, pos):post()
    hs.eventtap.event.newKeyEvent({"alt"}, key, true):post()
    hs.eventtap.event.newKeyEvent({"alt"}, key, false):post()
    hs.timer.usleep(300000)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, pos):post()
    hs.mouse.setAbsolutePosition(bak)
  end
end

function focusedWin(f, orFocus)
  return function()
    local win = hs.window.focusedWindow()
    if win and win:isStandard() then
      return f(win)
    elseif orFocus then
      win = hs.window.standardWindows()[1]
      if win then win:focus() end
    end
  end
end

init()
hs.alert.show("init.lua loaded")

