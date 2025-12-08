-- Based on ApeData/Roaming/Keyhac/config.py

function init()
  Vector.test()
  Box.test()
  Direction.test()
  Monitor.test()
  Frame.test()

  Frame.padding = 10

  local ms = {}
  do
    for i, screen in ipairs(hs.screen.allScreens()) do
      ms[i] = Monitor.new(i, Box.fromRect(screen:frame()))
    end
    ms.main = Monitor.primary(ms)
    ms.subs = hs.fnutils.filter(ms, function(m) return m ~= ms.main end)
  end

  local fs = {}
  do
    local layout = ms.main:size().x >= 2560 and {
      xp = {{0, 0.125, 0.25}, {0.25, 0.5, 0.75}, {0.75, 0.875, 1}},
      yp = {{0, 0.25, 0.5}, {0, 0.5, 1}, {0.5, 0.75, 1}},
    } or {
      xp = {{0, 0.35, 0.7}, {0.5, 0.75, 1}},
      yp = {{0, 0.25, 0.5}, {0, 0.5, 1}, {0.5, 0.75, 1}},
    }

    local main = Frame.tile("main", ms.main, layout.xp, layout.yp, fs)
    for _, m in pairs(ms.subs) do
      local sub = Frame.new(string.format("sub-%s", m.id), m, {0, 0.5, 1}, {0, 0.5, 1})
      fs[sub.id] = sub

      local dir = (m:center() - ms.main:center()):direction()
      local side = main[dir]
      for i, f in ipairs(side) do
        f:linkTo(sub, dir, i == math.ceil(#side / 2))
      end
    end
  end

  hs.window.animationDuration = 0
  hs.window.spacesModifiers = {alt = true}

  hs.hotkey.bind({"alt", "ctrl"}, "r", hs.reload)

  hs.hotkey.bind({"alt"}, "return", function() window.focusByApplication(fs, "WezTerm") end)
  hs.hotkey.bind({"alt"}, "b", function() window.focusByApplication(fs, "Firefox") end)
  hs.hotkey.bind({"alt"}, "c", function() window.focusByApplication(fs, "Slack") end)
  hs.hotkey.bind({"alt"}, "v", function() window.focusByApplication(fs, "Visual Studio Code") end)
  hs.hotkey.bind({"alt"}, "n", function() window.focusByApplication(fs, "Notion") end)

  hs.hotkey.bind({"alt", "shift"}, "c", window.close)

  hs.hotkey.bind({"alt"}, "m", window.toggleMaximize)

  hs.hotkey.bind({"alt"}, "k", function() window.focusByDirection(fs, Direction.top) end)
  hs.hotkey.bind({"alt"}, "j", function() window.focusByDirection(fs, Direction.bottom) end)
  hs.hotkey.bind({"alt"}, "h", function() window.focusByDirection(fs, Direction.left) end)
  hs.hotkey.bind({"alt"}, "l", function() window.focusByDirection(fs, Direction.right) end)

  hs.hotkey.bind({"alt"}, "i", function() window.focusByFrame(fs, nil, 1) end)
  hs.hotkey.bind({"alt"}, "o", function() window.focusByFrame(fs, nil, -1) end)

  hs.hotkey.bind({"alt"}, "e", function() window.moveByDirection(fs, Direction.top) end)
  hs.hotkey.bind({"alt"}, "d", function() window.moveByDirection(fs, Direction.bottom) end)
  hs.hotkey.bind({"alt"}, "s", function() window.moveByDirection(fs, Direction.left) end)
  hs.hotkey.bind({"alt"}, "f", function() window.moveByDirection(fs, Direction.right) end)

  hs.hotkey.bind({"alt", "shift"}, "i", function() window.resetSize(fs) end)

  hs.hotkey.bind({"alt", "shift"}, "k", function() window.resizeByDirection(fs, Direction.top, 0.1) end)
  hs.hotkey.bind({"alt", "shift"}, "j", function() window.resizeByDirection(fs, Direction.bottom, 0.1) end)
  hs.hotkey.bind({"alt", "shift"}, "h", function() window.resizeByDirection(fs, Direction.left, 0.1) end)
  hs.hotkey.bind({"alt", "shift"}, "l", function() window.resizeByDirection(fs, Direction.right, 0.1) end)
end

Vector = {}

function Vector.new(x, y)
  return setmetatable({ x = x, y = y }, Vector.mt)
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
  if type(s) == "number" then
    return Vector.new(self.x * s, self.y * s)
  else
    return Vector.new(self.x * s.x, self.y * s.y)
  end
end

function Vector:scalar()
  return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

function Vector:direction()
  local r = math.atan(-self.y, self.x) / math.pi * 4

  if r > -1 and r <= 1 then
    return Direction.right
  elseif r > 1 and r <= 3 then
    return Direction.top
  elseif r > -3 and r <= -1 then
    return Direction.bottom
  else
    return Direction.left
  end
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
  assert(Vector.new(3, 5) * Vector.new(3, 4) == Vector.new(9, 20))
  assert(Vector.new(3, 4):scalar() == 5)
  assert(Vector.new(1, -3):direction() == Direction.top)
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

function Box.new(min, max)
  return setmetatable({ min = min, max = max }, Box.mt)
end

function Box.box(x1, y1, x2, y2)
  return Box.new(Vector.new(x1, y1), Vector.new(x2, y2))
end

function Box.fromRect(rect)
  return Box.box(rect.x, rect.y, rect.x + rect.w, rect.y + rect.h)
end

function Box:eq(other)
  return self.min == other.min and self.max == other.max
end

function Box:mul(other)
  return Box.new(self.min * other, self.max * other)
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
  assert(Box.box(5, 10, 15, 25) == Box.box(5, 10, 15, 25))
  assert(Box.box(5, 10, 15, 25) ~= Box.box(5, 10, 15, 30))
  assert(tostring(Box.box(5, 10, 15, 25)) == "(5, 10 .. 15, 25)")
  assert(Box.box(5, 10, 15, 25):size() == Vector.new(10, 15))
  assert(Box.box(-1, -2, 3, 4) * Vector.new(2, 3) == Box.box(-2, -6, 6, 12))
  assert(Box.box(5, 10, 15, 30):center() == Vector.new(10, 20))
end

Box.mt = {
  __index = Box,
  __eq = Box.eq,
  __mul = Box.mul,
  __tostring = Box.tostring,
}

Direction = {}

function Direction.new(id, vector)
  return setmetatable({ id = id, vector = vector, neighbors = {} }, Direction.mt)
end

function Direction:tostring()
  return self.id
end

function Direction:letInverse(other)
  self.inverse = other
  other.inverse = self
end

function Direction:letNeighbors(...)
  for _, other in next, {...} do
    table.insert(self.neighbors, other)
    table.insert(other.neighbors, self)
  end
end

function Direction.test()
  assert(tostring(Direction.bottom) == "bottom")
  assert(Direction.top.inverse == Direction.bottom)
  assert(Direction.top.neighbors[1] == Direction.left)
  assert(Direction.top.neighbors[2] == Direction.right)
  assert(Direction.top.neighbors[3] == nil)
end

Direction.mt = {
  __index = Direction,
  __tostring = Direction.tostring,
}

Direction.top = Direction.new("top", Vector.new(0, -1))
Direction.bottom = Direction.new("bottom", Vector.new(0, 1))
Direction.left = Direction.new("left", Vector.new(-1, 0))
Direction.right = Direction.new("right", Vector.new(1, 0))

Direction.top:letInverse(Direction.bottom)
Direction.left:letInverse(Direction.right)
Direction.top:letNeighbors(Direction.left, Direction.right)
Direction.bottom:letNeighbors(Direction.left, Direction.right)

Monitor = {}

function Monitor.new(id, box)
  return setmetatable({
    id = id,
    box = box,
  }, Monitor.mt)
end

function Monitor:size()
  return self.box:size()
end

function Monitor:center()
  return self.box:center()
end

function Monitor:map(vec, padding)
  local px = (vec.x == 0 or vec.x == 1) and 1 or 0.5
  local py = (vec.y == 0 or vec.y == 1) and 1 or 0.5
  return Vector.new(
    self.box.min.x * (1 - vec.x) + self.box.max.x * vec.x + px * padding,
    self.box.min.y * (1 - vec.y) + self.box.max.y * vec.y + py * padding
  )
end

function Monitor:tostring()
  return "Monitor(" .. self.id .. ", box=" .. tostring(self.box) .. ")"
end

function Monitor.primary(ms)
  local primary = nil
  local size = nil
  for _, item in ipairs(ms) do
    local s = item:size():scalar()
    if not size or size < s then
      primary = item
      size = s
    end
  end
  return primary
end

function Monitor.test()
  local m = Monitor.new(1, Box.box(0, 0, 1680, 1050))
  assert(m:size() == Vector.new(1680, 1050))
  assert(m:map(Vector.new(0, 0), 10) == Vector.new(10, 10))
  assert(m:map(Vector.new(0.5, 0), 10) == Vector.new(845, 10))
  assert(m:map(Vector.new(1, 1), -10) == Vector.new(1670, 1040))
  assert(m:map(Vector.new(0.25, 0.5), 0) == Vector.new(420, 525))
  local ms = {
    Monitor.new(1, Box.box(0, 0, 100, 100)),
    Monitor.new(2, Box.box(100, 0, 400, 100)),
    Monitor.new(3, Box.box(-100, 0, 0, 150)),
  }
  assert(Monitor.primary(ms).id == 2)
end

Monitor.mt = {
  __index = Monitor,
  __tostring = Monitor.tostring,
}

Frame = {}

function Frame.new(id, monitor, x, y)
  local padding = Frame.padding or 0
  local min = Vector.new(x[1], y[1])
  local base = Vector.new(x[2], y[2])
  local max = Vector.new(x[3], y[3])
  local space = {
    t = min.y ~= 0 and 1 or 0,
    b = max.y ~= 1 and 1 or 0,
    l = min.x ~= 0 and 1 or 0,
    r = max.x ~= 1 and 1 or 0,
  }
  return setmetatable({
    id = id,
    monitor = monitor,
    box = Box.new(monitor:map(min, padding), monitor:map(max, -padding)),
    base = monitor:map(base, 0),
    scaler = Box.new(
      Vector.new(space.l == space.r and -0.5 or space.l, space.t == space.b and -0.5 or space.t),
      Vector.new(space.l == space.r and 0.5 or space.r, space.t == space.b and 0.5 or space.b)
    ) * monitor:size(),
    links = {},
  }, Frame.mt)
end

function Frame:linkTo(other, dir, inverse)
  self.links[dir] = other
  if inverse or inverse == nil then
    other.links[dir.inverse] = self
  end
end

function Frame:traverseLinks(dir)
  local todo = {self.links[dir]}
  local done = {}
  return function()
    while next(todo) do
      local frame = table.remove(todo, 1)
      if frame and not done[frame.id] then
        done[frame.id] = true
        table.insert(todo, frame.links[dir])
        for _, d in ipairs(dir.neighbors) do
          table.insert(todo, frame.links[d])
        end
        return frame
      end
    end
  end
end

function Frame:tostring()
  return "Frame(" .. self.id .. ", box=" .. tostring(self.box) .. ", base=" .. tostring(self.base) .. ")"
end

function Frame.nearest(fs, pos)
  local frame = nil
  local distance = math.huge
  for _, f in pairs(fs) do
    local d = (pos - f.base):scalar()
    if d < distance then
      frame = f
      distance = d
    end
  end
  return frame
end

function Frame.tile(idPrefix, monitor, xp, yp, fs)
  local function id(x, y)
    return string.format("%s-%s-%s", idPrefix, x, y)
  end

  local outline = {}
  outline[Direction.top] = {}
  outline[Direction.bottom] = {}
  outline[Direction.left] = {}
  outline[Direction.right] = {}

  for y = 1, #yp do
    for x = 1, #xp do
      local frame = Frame.new(id(x, y), monitor, xp[x], yp[y])
      fs[frame.id] = frame

      if x ~= 1 then frame:linkTo(fs[id(x - 1, y)], Direction.left) end
      if y ~= 1 then frame:linkTo(fs[id(x, y - 1)], Direction.top) end
      if y == 1 then table.insert(outline[Direction.top], frame) end
      if y == #yp then table.insert(outline[Direction.bottom], frame) end
      if x == 1 then table.insert(outline[Direction.left], frame) end
      if x == #xp then table.insert(outline[Direction.right], frame) end
    end
  end
  return outline
end

function Frame.test()
  Frame.padding = 6
  local m = Monitor.new(1, Box.box(0, 0, 100, 100))
  local a = Frame.new("a", m, {0, 0.25, 0.5}, {0, 0.5, 1})
  local b = Frame.new("b", m, {0.5, 0.75, 1}, {0, 0.5, 1})
  assert(a.box == Box.box(6, 6, 47, 94))
  assert(a.base == Vector.new(25, 50))
  assert(a.scaler == Box.box(0, -50, 100, 50))
  assert(b.box == Box.box(53, 6, 94, 94))
  assert(b.base == Vector.new(75, 50))
  assert(b.scaler == Box.box(100, -50, 0, 50))

  Frame.padding = 0
  m = Monitor.new(1, Box.box(0, 0, 400, 100))
  local fs = {
    a = Frame.new("a", m, {0,    0.125, 0.25}, {0, 0.5, 1}),
    b = Frame.new("b", m, {0.25, 0.375, 0.5},  {0, 0.5, 1}),
    c = Frame.new("c", m, {0.5,  0.625, 0.75}, {0, 0.5, 1}),
    d = Frame.new("d", m, {0.75, 0.875, 1},    {0, 0.5, 1}),
  }
  fs.a:linkTo(fs.b, Direction.right)
  fs.b:linkTo(fs.c, Direction.right)
  fs.c:linkTo(fs.d, Direction.right)
  assert(fs.a.links[Direction.right] == fs.b)
  assert(fs.b.links[Direction.right] == fs.c)
  assert(fs.b.links[Direction.left] == fs.a)
  local t = fs.a:traverseLinks(Direction.right)
  assert(t() == fs.b)
  assert(t() == fs.c)
  assert(t() == fs.d)
  assert(t() == nil)
  t = fs.b:traverseLinks(Direction.right)
  assert(t() == fs.c)
  assert(t() == fs.d)
  assert(t() == nil)
  t = fs.b:traverseLinks(Direction.left)
  assert(t() == fs.a)
  assert(t() == nil)
  assert(Frame.nearest(fs, Vector.new(50, 50)) == fs.a)
  assert(Frame.nearest(fs, Vector.new(250, 50)) == fs.c)
end

Frame.mt = {
  __index = Frame,
  __tostring = Frame.tostring,
}

window = {}

function window.list(cond)
  local wins = hs.fnutils.filter(hs.window.visibleWindows(), function(win)
    return win:isStandard() and (not cond or cond(win))
  end)
  table.sort(wins, function(a, b) return a:id() < b:id() end)
  return wins
end

function window.listInFrame(fs, frame)
  return window.list(function(win)
    local box = Box.fromRect(win:frame())
    return frame == Frame.nearest(fs, box:center())
  end)
end

function window.current()
  local win = hs.window.focusedWindow()
  return win and win:isStandard() and win or nil
end

function window.frame(fs, win)
  local box = Box.fromRect(win:frame())
  local frame = Frame.nearest(fs, box:center())
  frame.latestWin = win:id()
  return frame
end

function window.close()
  local win = window.current()
  if win then win:close() end
end

do
  local stashedWindowRect = {}
  local maximizeThreshold = 20

  function window.toggleMaximize()
    local win = window.current()
    if not win then return end

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

function window.focusAny(fs)
  for _, win in pairs(window.list()) do
    win:focus()
    return true
  end
  return false
end

function window.focusByDirection(fs, dir)
  local win = window.current()
  if not win then return window.focusAny(fs) end

  for frame in window.frame(fs, win):traverseLinks(dir) do
    if window.focusByFrame(fs, frame) then return true end
  end
  return false
end

function window.focusByFrame(fs, frame, offset)
  if not frame then
    local win = window.current()
    if not win then return window.focusAny(fs) end

    frame = window.frame(fs, win)
  end

  local wins = window.listInFrame(fs, frame)
  if not wins or not next(wins) then return false end

  return window.focusInOrder(fs, wins, offset or 0, frame.latestWin)
end

function window.focusByApplication(fs, app, offset)
  local wins = window.list(function(win) return win:application():path():find(app) end)

  if not wins or not next(wins) then
    hs.applescript.applescript([[do shell script "/usr/bin/open -a ']] .. app .. [['"]])
    return true
  end

  return window.focusInOrder(fs, wins, offset or 1)
end

function window.focusInOrder(fs, wins, offset, latestWin)
  local index = nil
  local current = window.current()
  for i, w in ipairs(wins) do
    if w == current then
      index = i
      break
    end
  end

  if not index and latestWin then
    for i, w in ipairs(wins) do
      if w:id() == latestWin then
        index = i
        break
      end
    end
  end

  if not index then index = 1 end

  local current = wins[((#wins + index + offset - 1) % #wins) + 1]
  current:focus()

  -- Report orders by hs.alert for convenience
  do
    local apps = {}
    for _, win in pairs(wins) do
      local app = win:application():title()
      apps[app] = 1 + (apps[app] or 0)
    end

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

  return true
end

function window.moveByDirection(fs, dir)
  local win = window.current()
  if not win then return end

  local frame = window.frame(fs, win)
  frame = frame.links[dir] or frame
  win:setFrame(frame.box:rect())
end

function window.resetSize(fs)
  local win = window.current()
  if not win then return end

  local frame = window.frame(fs, win)
  win:setFrame(frame.box:rect())
end

function window.resizeByDirection(fs, dir, l)
  local win = window.current()
  if not win then return end

  local box = Box.fromRect(win:frame())
  local frame = window.frame(fs, win)
  box.min = box.min + dir.vector * frame.scaler.min * l
  box.max = box.max + dir.vector * frame.scaler.max * l
  win:setFrame(box:rect())
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
