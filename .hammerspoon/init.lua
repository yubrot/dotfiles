-- Based on AppData/Roaming/Keyhac/config.py

function init()
  Vector.test()
  Box.test()
  Direction.test()
  Monitor.test()
  Frame.test()
  FrameSet.test()

  local ms = {}
  for i, screen in ipairs(hs.screen.allScreens()) do
    ms[i] = Monitor.new(i, Box.fromRect(screen:frame()))
  end

  local h = {{0, 0.125, 0.25}, {0.25, 0.5, 0.75}, {0.75, 0.875, 1}}
  local v = {{0, 0.25, 0.5}, {0, 0.5, 1}, {0.5, 0.75, 1}}
  local frames = {}
  for x = 1, #h do
    for y = 1, #v do
      table.insert(frames, Frame.panel(h, v, {[Direction.bottom] = "2"}, 1, x, y))
    end
  end
  table.insert(frames, Frame.new("2", 2, {0, 0.5, 1}, {0, 0.5, 1}, {[Direction.top] = "1-2-2"}))
  local fs = FrameSet.new()
  fs:initialize(frames)
  fs:populate(ms, 10)

  hs.window.animationDuration = 0
  hs.window.spacesModifiers = {alt = true}

  hs.hotkey.bind({"alt", "ctrl"}, "r", hs.reload)

  hs.hotkey.bind({"alt"}, "return", function() operation.focusByApplication(fs, "WezTerm") end)
  hs.hotkey.bind({"alt"}, "b", function() operation.focusByApplication(fs, "Firefox") end)
  hs.hotkey.bind({"alt"}, "c", function() operation.focusByApplication(fs, "Slack") end)
  hs.hotkey.bind({"alt"}, "v", function() operation.focusByApplication(fs, "Visual Studio Code") end)
  hs.hotkey.bind({"alt"}, "n", function() operation.focusByApplication(fs, "Obsidian") end)

  hs.hotkey.bind({"alt", "shift"}, "c", operation.closeWindow)

  hs.hotkey.bind({"alt"}, "m", operation.toggleMaximizeWindow)

  hs.hotkey.bind({"alt"}, "k", function() operation.focusFrameByDirection(fs, Direction.top) end)
  hs.hotkey.bind({"alt"}, "j", function() operation.focusFrameByDirection(fs, Direction.bottom) end)
  hs.hotkey.bind({"alt"}, "h", function() operation.focusFrameByDirection(fs, Direction.left) end)
  hs.hotkey.bind({"alt"}, "l", function() operation.focusFrameByDirection(fs, Direction.right) end)

  hs.hotkey.bind({"alt"}, "i", function() operation.focusWindowInFrame(fs, 1) end)
  hs.hotkey.bind({"alt"}, "o", function() operation.focusWindowInFrame(fs, -1) end)

  hs.hotkey.bind({"alt"}, "e", function() operation.moveWindowByDirection(fs, Direction.top) end)
  hs.hotkey.bind({"alt"}, "d", function() operation.moveWindowByDirection(fs, Direction.bottom) end)
  hs.hotkey.bind({"alt"}, "s", function() operation.moveWindowByDirection(fs, Direction.left) end)
  hs.hotkey.bind({"alt"}, "f", function() operation.moveWindowByDirection(fs, Direction.right) end)

  hs.hotkey.bind({"alt", "shift"}, "i", function() operation.resetWindowSize(fs) end)

  hs.hotkey.bind({"alt", "shift"}, "k", function() operation.resizeWindowByDirection(fs, Direction.top, 0.1) end)
  hs.hotkey.bind({"alt", "shift"}, "j", function() operation.resizeWindowByDirection(fs, Direction.bottom, 0.1) end)
  hs.hotkey.bind({"alt", "shift"}, "h", function() operation.resizeWindowByDirection(fs, Direction.left, 0.1) end)
  hs.hotkey.bind({"alt", "shift"}, "l", function() operation.resizeWindowByDirection(fs, Direction.right, 0.1) end)
end

Vector = {}

function Vector.new(x, y)
  return setmetatable({
    x = x,
    y = y,
  }, Vector.mt)
end

function Vector:eq(other)
  return self.x == other.x and self.y == other.y
end

function Vector:add(other)
  return Vector.new(self.x + other.x, self.y + other.y)
end

function Vector:sub(other)
  return Vector.new(self.x - other.x, self.y - other.y)
end

function Vector:mul(s)
  return Vector.new(self.x * s, self.y * s)
end

function Vector:distanceTo(other)
  return math.abs(self.x - other.x) + math.abs(self.y - other.y)
end

function Vector:tostring()
  return "(" .. self.x .. ", " .. self.y .. ")"
end

function Vector.test()
  assert(Vector.new(3, 5) == Vector.new(3, 5))
  assert(Vector.new(3, 5) ~= Vector.new(3, 4))
  assert(tostring(Vector.new(3, 5)) == "(3, 5)")
  assert(Vector.new(3, 5) + Vector.new(1, 4) == Vector.new(4, 9))
  assert(Vector.new(3, 5) - Vector.new(1, 4) == Vector.new(2, 1))
  assert(Vector.new(3, 5) * 3 == Vector.new(9, 15))
  assert(Vector.new(3, 5):distanceTo(Vector.new(5, 8)) == 5)
end

Vector.mt = {
  __index = Vector,
  __eq = Vector.eq,
  __add = Vector.add,
  __sub = Vector.sub,
  __mul = Vector.mul,
  __tostring = Vector.tostring,
}

Box = {}

function Box.new(x1, y1, x2, y2)
  return setmetatable({
    min = Vector.new(x1, y1),
    max = Vector.new(x2, y2),
  }, Box.mt)
end

function Box.fromRect(rect)
  return Box.new(rect.x, rect.y, rect.x + rect.w, rect.y + rect.h)
end

function Box:eq(other)
  return self.min == other.min and self.max == other.max
end

function Box:mul(other)
  return Box.new(
    self.min.x * other.x,
    self.min.y * other.y,
    self.max.x * other.x,
    self.max.y * other.y
  )
end

function Box:size()
  return self.max - self.min
end

function Box:center()
  return (self.max + self.min) * 0.5
end

function Box:rect()
  return {x = self.min.x, y = self.min.y, w = self.max.x - self.min.x, h = self.max.y - self.min.y}
end

function Box:tostring()
  return "(" .. self.min.x .. ", " .. self.min.y .. " .. " .. self.max.x .. ", " .. self.max.y .. ")"
end

function Box.test()
  assert(Box.new(5, 10, 15, 25) == Box.new(5, 10, 15, 25))
  assert(Box.new(5, 10, 15, 25) ~= Box.new(5, 10, 15, 30))
  assert(tostring(Box.new(5, 10, 15, 25)) == "(5, 10 .. 15, 25)")
  assert(Box.new(5, 10, 15, 25):size() == Vector.new(10, 15))
  assert(Box.new(-1, -2, 3, 4) * Vector.new(2, 3) == Box.new(-2, -6, 6, 12))
  assert(Box.new(5, 10, 15, 30):center() == Vector.new(10, 20))
end

Box.mt = {
  __index = Box,
  __eq = Box.eq,
  __mul = Box.mul,
  __tostring = Box.tostring,
}

Direction = {}

function Direction.new(key, neighborKeys, vector)
  return setmetatable({
    key = key,
    neighborKeys = neighborKeys,
    vector = vector,
  }, Direction.mt)
end

function Direction:visitOrder()
  local t = {self}
  for i, nk in ipairs(self.neighborKeys) do
    t[i + 1] = Direction[nk]
  end
  return t
end

function Direction:tostring()
  return self.key
end

function Direction.test()
  assert(Direction.top == Direction.top)
  assert(Direction.top ~= Direction.left)
  assert(tostring(Direction.bottom) == "bottom")
  assert(Direction.top:visitOrder()[1] == Direction.top)
  assert(Direction.top:visitOrder()[2] == Direction.left)
  assert(Direction.top:visitOrder()[3] == Direction.right)
  assert(Direction.top:visitOrder()[4] == nil)
  assert(Direction.top.vector == Vector.new(0, -1))
end

Direction.mt = {
  __index = Direction,
  __tostring = Direction.tostring,
}

Direction.top = Direction.new("top", {"left", "right"}, Vector.new(0, -1))
Direction.bottom = Direction.new("bottom", {"left", "right"}, Vector.new(0, 1))
Direction.left = Direction.new("left", {"top", "bottom"}, Vector.new(-1, 0))
Direction.right = Direction.new("right", {"top", "bottom"}, Vector.new(1, 0))

Monitor = {}

function Monitor.new(id, box)
  return setmetatable({
    id = id,
    box = box,
  }, Monitor.mt)
end

function Monitor:map(vec)
  return Vector.new(
    self.box.min.x * (1 - vec.x) + self.box.max.x * vec.x,
    self.box.min.y * (1 - vec.y) + self.box.max.y * vec.y)
end

function Monitor:tostring()
  return "Monitor(" .. self.id .. ", box=" .. tostring(self.box) .. ")"
end

function Monitor.test()
  local m = Monitor.new(1, Box.new(0, 0, 1680, 1050))
  assert(m:map(Vector.new(0, 0)) == Vector.new(0, 0))
  assert(m:map(Vector.new(1, 1)) == Vector.new(1680, 1050))
  assert(m:map(Vector.new(0.25, 0.5)) == Vector.new(420, 525))
end

Monitor.mt = {
  __index = Monitor,
  __tostring = Monitor.tostring,
}

Frame = {}

function Frame.new(id, monitorId, x, y, links)
  local t = y[1] ~= 0 and 1 or 0
  local b = y[3] ~= 1 and 1 or 0
  local l = x[1] ~= 0 and 1 or 0
  local r = x[3] ~= 1 and 1 or 0
  return setmetatable({
    id = id,
    monitor = monitorId,
    box = Box.new(x[1], y[1], x[3], y[3]),
    base = Vector.new(x[2], y[2]),
    links = links,
    latestWindow = nil,
    scaler = Box.new(
      l == r and -0.5 or l,
      t == b and -0.5 or t,
      l == r and 0.5 or r,
      t == b and 0.5 or b),
  }, Frame.mt)
end

function Frame:populate(ms, padding)
  if not ms[self.monitor] then
    print("Unknown monitor " .. self.monitor)
    return false
  end
  local monitor = ms[self.monitor]

  local function mapWithOffset(vec, f)
    local px = (vec.x == 0 or vec.x == 1) and 1 or 0.5
    local py = (vec.y == 0 or vec.y == 1) and 1 or 0.5
    return monitor:map(vec) + Vector.new(px, py) * f
  end

  self.box.min = mapWithOffset(self.box.min, padding)
  self.box.max = mapWithOffset(self.box.max, -padding)
  self.base = monitor:map(self.base)
  self.scaler = self.scaler * monitor.box:size()
  return true
end

function Frame:tostring()
  return "Frame(" .. self.id .. ", box=" .. tostring(self.box) .. ", base=" .. tostring(self.base) .. ")"
end

-- See keyhac/config.py
function Frame.panel(h, v, e, monitor, x, y)
  local function id(x, y)
    return string.format("%s-%s-%s", monitor, x, y)
  end

  local dirs = {}

  if y == 1 then
    dirs[Direction.top] = e[Direction.top]
  else
    dirs[Direction.top] = id(x, y - 1)
  end

  if y == #v then
    dirs[Direction.bottom] = e[Direction.bottom]
  else
    dirs[Direction.bottom] = id(x, y + 1)
  end

  if x == 1 then
    dirs[Direction.left] = e[Direction.left]
  else
    dirs[Direction.left] = id(x - 1, y)
  end

  if x == #h then
    dirs[Direction.right] = e[Direction.right]
  else
    dirs[Direction.right] = id(x + 1, y)
  end

  return Frame.new(id(x, y), monitor, h[x], v[y], dirs)
end

function Frame.test()
  local m = Monitor.new(1, Box.new(0, 0, 100, 100))
  local a = Frame.new("a", m.id, {0, 0.25, 0.5}, {0, 0.5, 1}, {})
  local b = Frame.new("b", m.id, {0.5, 0.75, 1}, {0, 0.5, 1}, {})
  local ms = {[m.id] = m}
  a:populate(ms, 6)
  b:populate(ms, 6)
  assert(a.box == Box.new(6, 6, 47, 94))
  assert(a.base == Vector.new(25, 50))
  assert(a.scaler == Box.new(0, -50, 100, 50))
  assert(b.box == Box.new(53, 6, 94, 94))
  assert(b.base == Vector.new(75, 50))
  assert(b.scaler == Box.new(100, -50, 0, 50))
end

Frame.mt = {
  __index = Frame,
  __tostring = Frame.tostring,
}

FrameSet = {}

function FrameSet.new()
  return setmetatable({items = {}}, FrameSet.mt)
end

function FrameSet:register(frame)
  self.items[frame.id] = frame
end

function FrameSet:get(frameId)
  return self.items[frameId]
end

function FrameSet:getNearest(pos)
  local nf = nil
  local nfd = math.huge
  for _, f in pairs(self.items) do
    local fd = f.base:distanceTo(pos)
    if fd < nfd then
      nf = f
      nfd = fd
    end
  end
  return nf
end

function FrameSet:getByDirection(baseFrame, dir)
  local frameId = baseFrame.links[dir]
  return frameId and self.items[frameId] or nil
end

function FrameSet:getByWindow(win, saveLatest)
  local box = Box.fromRect(win:frame())
  local frame = self:getNearest(box:center())
  if saveLatest or saveLatest == nil then
    frame.latestWindow = win:id()
  end
  return frame
end

function FrameSet:enumerateByDirection(baseFrame, dir)
  local visitOrder = dir:visitOrder()
  local todo = {self:getByDirection(baseFrame, dir)}
  local done = {}
  local ret = {}
  while next(todo) do
    local f = table.remove(todo, 1)
    if f and not done[f.id] then
      done[f.id] = true
      table.insert(ret, f)
      for _, d in ipairs(visitOrder) do
        table.insert(todo, self:getByDirection(f, d))
      end
    end
  end
  return ret
end

function FrameSet:populate(ms, padding)
  local missingFrames = {}
  for _, frame in pairs(self.items) do
    for _, frameId in pairs(frame.links) do
      if not self:get(frameId) then
        error("Unknown frame " .. frameId)
      end
    end
    if not frame:populate(ms, padding) then
      missingFrames[frame.id] = true
    end
  end

  for missingFrameId, _ in pairs(missingFrames) do
    self.items[missingFrameId] = nil
  end

  for _, frame in pairs(self.items) do
    local missingLinks = {}
    for dir, frameId in pairs(frame.links) do
      if missingFrames[frameId] then
        missingLinks[dir] = true
      end
    end
    for dir, _ in pairs(missingLinks) do
      frame.links[dir] = nil
    end
  end
end

function FrameSet:initialize(frames)
  for _, frame in ipairs(frames) do
    self:register(frame)
  end
end

function FrameSet.test()
  local m = Monitor.new(1, Box.new(0, 0, 400, 100))
  local a = Frame.new("a", m.id, {0,    0.125, 0.25}, {0, 0.5, 1}, {[Direction.right] = "b"})
  local b = Frame.new("b", m.id, {0.25, 0.375, 0.5},  {0, 0.5, 1}, {[Direction.left] = "a", [Direction.right] = "c"})
  local c = Frame.new("c", m.id, {0.5,  0.625, 0.75}, {0, 0.5, 1}, {[Direction.left] = "b", [Direction.right] = "d"})
  local d = Frame.new("d", m.id, {0.75, 0.875, 1},    {0, 0.5, 1}, {[Direction.left] = "c"})
  local ms = {[m.id] = m}
  local fs = FrameSet.new()
  fs:initialize({a, b, c, d})
  fs:populate(ms, 0)
  assert(fs:getNearest(Vector.new(50, 50)) == a)
  assert(fs:getNearest(Vector.new(250, 50)) == c)
  assert(fs:getByDirection(a, Direction.right) == b)
  assert(fs:getByDirection(b, Direction.right) == c)
  assert(fs:getByDirection(b, Direction.left) == a)
  assert(fs:getByDirection(b, Direction.top) == nil)
  assert(fs:enumerateByDirection(a, Direction.right)[1] == b)
  assert(fs:enumerateByDirection(a, Direction.right)[2] == c)
  assert(fs:enumerateByDirection(a, Direction.right)[3] == d)
  assert(fs:enumerateByDirection(a, Direction.right)[4] == nil)
  assert(fs:enumerateByDirection(b, Direction.right)[1] == c)
  assert(fs:enumerateByDirection(b, Direction.right)[2] == d)
  assert(fs:enumerateByDirection(b, Direction.right)[3] == nil)
  assert(fs:enumerateByDirection(b, Direction.left)[1] == a)
  assert(fs:enumerateByDirection(b, Direction.left)[2] == nil)
end

FrameSet.mt = {__index = FrameSet}

operation = {}

function operation.getWindows(cond)
  local wins = hs.fnutils.filter(hs.window.visibleWindows(), function(win)
    return win:isStandard() and (not cond or cond(win))
  end)
  table.sort(wins, function(a, b) return a:id() < b:id() end)
  return wins
end

function operation.getWindowsInFrame(fs, frame)
  return operation.getWindows(function(win)
    local box = Box.fromRect(win:frame())
    local f = fs:getNearest(box:center())
    return frame == f
  end)
end

function operation.getCurrentWindow()
  local win = hs.window.focusedWindow()
  return win and win:isStandard() and win or nil
end

function operation.closeWindow()
  local win = operation.getCurrentWindow()
  if win then
    win:close()
  end
end

do
  local stashedWindowRect = {}
  local maximizeThreshold = 20

  function operation.toggleMaximizeWindow()
    local win = operation.getCurrentWindow()
    if win then
      local id = win:id()
      local f = win:frame()
      local sf = win:screen():frame()

      if stashedWindowRect[id]
      and math.abs(sf.x - f.x) < maximizeThreshold
      and math.abs(sf.y - f.y) < maximizeThreshold
      and math.abs(sf.w - f.w) < maximizeThreshold
      and math.abs(sf.h - f.h) < maximizeThreshold
      then
        win:setFrame(stashedWindowRect[id])
        stashedWindowRect[id] = nil
      else
        stashedWindowRect[id] = f
        win:setFrame(sf)
      end
    end
  end
end

function operation.focusSomeWindow(fs)
  for _, win in pairs(operation.getWindows()) do
    win:focus()
    operation.alertWindows(operation.getWindowsInFrame(fs, fs:getByWindow(win)))
    return true
  end
  return false
end

function operation.focusFrameByDirection(fs, dir, baseFrame)
  if not baseFrame then
    local win = operation.getCurrentWindow()
    if not win then
      return operation.focusSomeWindow(fs)
    end
    baseFrame = fs:getByWindow(win)
  end

  for _, nextFrame in ipairs(fs:enumerateByDirection(baseFrame, dir)) do
    if operation.focusWindowInFrame(fs, 0, nextFrame) then
      return true
    end
  end
  return false
end

function operation.focusByApplication(fs, app)
  local wins = operation.getWindows(function(win)
    return win:application():path():find(app)
  end)

  if not wins or not next(wins) then
    hs.applescript.applescript([[do shell script "/usr/bin/open -a ']] .. app .. [['"]])
    return true
  end

  return operation.focusWindowInRotation(fs, wins, 1)
end

function operation.focusWindowInFrame(fs, offset, baseFrame)
  if not baseFrame then
    local win = operation.getCurrentWindow()
    if not win then
      return operation.focusSomeWindow(fs)
    end
    baseFrame = fs:getByWindow(win)
  end

  local frameWins = operation.getWindowsInFrame(fs, baseFrame)
  if not frameWins or not next(frameWins) then
    return false
  end

  return operation.focusWindowInRotation(fs, frameWins, offset, baseFrame.latestWindow)
end

function operation.focusWindowInRotation(fs, wins, offset, latest)
  local index = nil
  local current = operation.getCurrentWindow()
  for i, w in ipairs(wins) do
    if w == current then
      index = i
      break
    end
  end

  if not index and latest then
    for i, w in ipairs(wins) do
      if w:id() == latest then
        index = i
        break
      end
    end
  end

  if not index then
    index = 1
  end

  local nextWin = wins[((#wins + index + offset - 1) % #wins) + 1]
  nextWin:focus()
  fs:getByWindow(nextWin) -- save latest window
  operation.alertWindows(wins)
  return true
end

function operation.moveWindowByDirection(fs, dir)
  local win = operation.getCurrentWindow()
  if not win then
    return
  end
  local frame = fs:getByWindow(win)
  local nextFrame = fs:getByDirection(frame, dir)
  if nextFrame then
    win:setFrame(nextFrame.box:rect())
    operation.alertWindows(operation.getWindowsInFrame(fs, nextFrame))
  else
    win:setFrame(frame.box:rect())
  end
end

function operation.resetWindowSize(fs)
  local win = operation.getCurrentWindow()
  if not win then
    return
  end
  local frame = fs:getByWindow(win)
  win:setFrame(frame.box:rect())
end

function operation.resizeWindowByDirection(fs, dir, l)
  local win = operation.getCurrentWindow()
  if not win then
    return
  end
  local box = Box.fromRect(win:frame())
  local frame = fs:getByWindow(win)
  box.min.x = box.min.x + dir.vector.x * frame.scaler.min.x * l
  box.min.y = box.min.y + dir.vector.y * frame.scaler.min.y * l
  box.max.x = box.max.x + dir.vector.x * frame.scaler.max.x * l
  box.max.y = box.max.y + dir.vector.y * frame.scaler.max.y * l
  win:setFrame(box:rect())
end

function operation.alertWindows(wins)
  local apps = {}
  for _, win in pairs(wins) do
    local app = win:application():title()
    apps[app] = 1 + (apps[app] or 0)
  end

  local current = operation.getCurrentWindow()
  local messages = {}
  for _, win in pairs(wins) do
    local prefix = win == current and "◆ " or "◇ "
    local app = win:application():title()
    local title = 1 < apps[app] and app .. " (" .. utf8.sub(win:title(), 0, 30) .. ")" or app
    table.insert(messages, prefix .. title)
  end
  hs.alert.closeAll()
  hs.alert.show(table.concat(messages, "\n"), 1)
end

function utf8.sub(s, i, j)
  i = utf8.offset(s, i)
  j = utf8.offset(s, j + 1)
  if i and j then
    return s:sub(i, j - 1)
  elseif i then
    return s:sub(i)
  else
    return ""
  end
end

init()
hs.alert.show("init.lua loaded")
