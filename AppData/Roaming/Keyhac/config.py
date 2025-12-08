import keyhac
import pyauto
import math
from enum import Enum
from typing import Tuple, List, Set, Dict, Optional, Any, Callable, Iterator
from functools import cmp_to_key

def configure(keymap: Any) -> None:
    Frame.padding = 10

    ms: MonitorSet = {}
    for i, monitor_info in enumerate(keyhac.Window.getMonitorInfo()):
        ms[i] = Monitor(i, Box.from_rect(monitor_info[1]))
    main_monitor = Monitor.primary(ms)
    sub_monitors = [m for m in ms.values() if m != main_monitor]

    fs: FrameSet = {}
    layout_xp: Tuple[float, float, float]
    layout_yp: Tuple[float, float, float]
    if main_monitor.size().x >= 2560:
        layout_xp = [(0, 0.125, 0.25), (0.25, 0.5, 0.75), (0.75, 0.875, 1)]
        layout_yp = [(0, 0.25, 0.5), (0, 0.5, 1), (0.5, 0.75, 1)]
    else:
        layout_xp = [(0, 0.35, 0.7), (0.5, 0.75, 1)]
        layout_yp = [(0, 0.25, 0.5), (0, 0.5, 1), (0.5, 0.75, 1)]

    main_frame = Frame.tile("main", main_monitor, layout_xp, layout_yp, fs)
    for m in sub_monitors:
        sub_frame = Frame(f"sub-{m.id}", m, (0, 0.5, 1), (0, 0.5, 1))
        fs[sub_frame.id] = sub_frame

        dir = (m.center() - main_monitor.center()).direction()
        side = main_frame[dir]
        for i, f in enumerate(side):
            f.link_to(sub_frame, dir, i == math.floor(len(side) / 2))

    def is_ignored_window(win: Any) -> bool:
        if win.getText() == "": return True
        if not win.isVisible(): return True
        if win.isMinimized(): return True

        rect = win.getRect()
        if rect[0] == rect[2] or rect[1] == rect[3]: return True

        # ignore VR related applications
        if win.getText() == "vrmonitor": return True
        # ignore LogiOverlay.exe
        if win.getProcessName() == "LogiOverlay.exe": return True
        # ignore explorer.exe
        if win.getClassName() == "Progman": return True
        # ignore NVIDIA GeForce Overlay
        if win.getClassName() == "CEF-OSC-WIDGET": return True
        # ignore ApplicationFrameWindow
        if win.getClassName() == "ApplicationFrameWindow": return True
        # ignore CoreWindow
        if win.getClassName() == "Windows.UI.Core.CoreWindow": return True

        return False

    Window.is_ignored_window = is_ignored_window
    Window.get_top_level_window = keymap.getTopLevelWindow
    Window.pop_balloon = keymap.popBalloon

    keymap.clipboard_history.maxnum = 1

    # treat Muhenkan as U0
    keymap.replaceKey("(29)", 235)
    keymap.defineModifier(235, "User0")

    bind = keymap.defineWindowKeymap()
    bind["BACKSLASH"] = keymap.InputKeyCommand("S-UNDERSCORE")

    bind["U0-C-R"] = keymap.command_ReloadConfig

    bind["U0-Return"] = lambda: Window.focus_by_application(fs, "WindowsTerminal.exe", "wt.exe")
    bind["U0-B"] = lambda: Window.focus_by_application(fs, "firefox.exe")
    bind["U0-C"] = lambda: Window.focus_by_application(fs, "slack.exe")
    bind["U0-V"] = lambda: Window.focus_by_application(fs, "Code.exe")
    bind["U0-N"] = lambda: Window.focus_by_application(fs, "Notion.exe")

    bind["U0-S-C"] = Window.close

    bind["U0-M"] = Window.toggle_maximize

    bind["U0-K"] = lambda: Window.focus_by_direction(fs, Direction.TOP)
    bind["U0-J"] = lambda: Window.focus_by_direction(fs, Direction.BOTTOM)
    bind["U0-H"] = lambda: Window.focus_by_direction(fs, Direction.LEFT)
    bind["U0-L"] = lambda: Window.focus_by_direction(fs, Direction.RIGHT)

    bind["U0-I"] = lambda: Window.focus_by_frame(fs, None, +1)
    bind["U0-O"] = lambda: Window.focus_by_frame(fs, None, -1)

    bind["U0-E"] = lambda: Window.move_by_direction(fs, Direction.TOP)
    bind["U0-D"] = lambda: Window.move_by_direction(fs, Direction.BOTTOM)
    bind["U0-S"] = lambda: Window.move_by_direction(fs, Direction.LEFT)
    bind["U0-F"] = lambda: Window.move_by_direction(fs, Direction.RIGHT)

    bind["U0-S-I"] = lambda: Window.reset_size(fs)

    bind["U0-S-K"] = lambda: Window.resize_by_direction(fs, Direction.TOP, 0.1)
    bind["U0-S-J"] = lambda: Window.resize_by_direction(fs, Direction.BOTTOM, 0.1)
    bind["U0-S-H"] = lambda: Window.resize_by_direction(fs, Direction.LEFT, 0.1)
    bind["U0-S-L"] = lambda: Window.resize_by_direction(fs, Direction.RIGHT, 0.1)

    Window.reactivate_binds()


class Vector:
    def __init__(self, x: float, y: float) -> None:
        self.x = x
        self.y = y

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Vector) and self.x == other.x and self.y == other.y

    def __add__(self, other: "Vector") -> "Vector":
        return Vector(self.x + other.x, self.y + other.y)

    def __sub__(self, other: "Vector") -> "Vector":
        return Vector(self.x - other.x, self.y - other.y)

    def __mul__(self, s: "int | float | Vector") -> "Vector":
        if isinstance(s, (int, float)):
            return Vector(self.x * s, self.y * s)
        else:
            return Vector(self.x * s.x, self.y * s.y)

    def scalar(self) -> float:
        return math.sqrt(self.x ** 2 + self.y ** 2)

    def direction(self) -> "Direction":
        r = math.atan2(-self.y, self.x) / math.pi * 4
        if r > -1 and r <= 1:
            return Direction.RIGHT
        elif r > 1 and r <= 3:
            return Direction.TOP
        elif r > -3 and r <= -1:
            return Direction.BOTTOM
        else:
            return Direction.LEFT

    def __str__(self) -> str:
        return f"({self.x}, {self.y})"


class Box:
    def __init__(self, min: Vector, max: Vector) -> None:
        self.min = min
        self.max = max

    @classmethod
    def from_rect(c, rect: Tuple[int | float, int | float, int | float, int | float]) -> "Box":
        return c(Vector(rect[0], rect[1]), Vector(rect[2], rect[3]))

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Box) and self.min == other.min and self.max == other.max

    def __mul__(self, s: Vector) -> "Box":
        return Box(self.min * s, self.max * s)

    def size(self) -> Vector:
        return self.max - self.min

    def center(self) -> Vector:
        return (self.max + self.min) * 0.5

    def rect(self) -> Tuple[int, int, int, int]:
        return (int(self.min.x), int(self.min.y), int(self.max.x), int(self.max.y))

    def __str__(self) -> str:
        return f"({self.min.x}, {self.min.y} .. {self.max.x}, {self.max.y})"


class Direction(Enum):
    TOP = 0
    BOTTOM = 1
    LEFT = 2
    RIGHT = 3

    def inverse(self) -> "Direction":
        if self == Direction.TOP:
            return Direction.BOTTOM
        elif self == Direction.BOTTOM:
            return Direction.TOP
        elif self == Direction.LEFT:
            return Direction.RIGHT
        else:
            return Direction.LEFT

    def neighbors(self) -> List["Direction"]:
        if self == Direction.TOP or self == Direction.BOTTOM:
            return [Direction.LEFT, Direction.RIGHT]
        else:
            return [Direction.TOP, Direction.BOTTOM]

    def vector(self) -> Vector:
        if self == Direction.TOP:
            return Vector(0, -1)
        elif self == Direction.BOTTOM:
            return Vector(0, 1)
        elif self == Direction.LEFT:
            return Vector(-1, 0)
        else:
            return Vector(1, 0)


MonitorId = int


class Monitor:
    def __init__(self, id: MonitorId, box: Box) -> None:
        self.id = id
        self.box = box

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Monitor) and self.id == other.id

    def size(self) -> Vector:
        return self.box.size()

    def center(self) -> Vector:
        return self.box.center()

    def map(self, vec: Vector, padding: int) -> Vector:
        px = 1 if vec.x in {0, 1} else 0.5
        py = 1 if vec.y in {0, 1} else 0.5
        return Vector(
            self.box.min.x*(1 - vec.x) + self.box.max.x*vec.x + px * padding,
            self.box.min.y*(1 - vec.y) + self.box.max.y*vec.y + py * padding)

    def __str__(self) -> str:
        return f"Monitor({self.id}, {self.box})"

    @classmethod
    def primary(c, ms: Dict[MonitorId, "Monitor"]) -> "Monitor | None":
        primary = None
        size = None
        for item in ms.values():
            s = item.size().scalar()
            if not size or size < s:
                primary = item
                size = s
        return primary


MonitorSet = Dict[MonitorId, Monitor]


FrameId = str


class Frame:
    padding: int = 0

    def __init__(self, id: FrameId, monitor: Monitor, x: Tuple[float, float, float], y: Tuple[float, float, float]) -> None:
        padding = Frame.padding or 0
        min = Vector(x[0], y[0])
        base = Vector(x[1], y[1])
        max = Vector(x[2], y[2])
        t = 1 if min.y != 0 else 0
        b = 1 if max.y != 1 else 0
        l = 1 if min.x != 0 else 0
        r = 1 if max.x != 1 else 0
        self.id = id
        self.monitor = monitor
        self.box = Box(monitor.map(min, padding), monitor.map(max, -padding))
        self.base = monitor.map(base, 0)
        self.scaler = Box(
            Vector(-0.5 if l == r else l, -0.5 if t == b else t),
            Vector(0.5 if l == r else r, 0.5 if t == b else b)
        ) * monitor.size()
        self.links: Dict[Direction, Frame] = {}
        self.latest_win: Optional[int] = None

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Frame) and self.id == other.id

    def link_to(self, other: "Frame", dir: Direction, inverse = True):
        self.links[dir] = other
        if inverse: other.links[dir.inverse()] = self

    def traverse_links(self, dir: Direction) -> Iterator["Frame"]:
        todo = [self.links.get(dir)]
        done: Set[FrameId] = set()
        while todo:
            frame = todo.pop(0)
            if frame and frame.id not in done:
                done.add(frame.id)
                todo.append(frame.links.get(dir))
                for d in dir.neighbors(): todo.append(frame.links.get(d))
                yield frame

    def __str__(self) -> str:
        return f"Frame({self.id}, {self.box})"

    @classmethod
    def nearest(c, fs: Dict[FrameId, "Frame"], pos: Vector) -> "Frame":
        return min([((pos - f.base).scalar(), i, f) for i, f in enumerate(fs.values())])[2]

    @classmethod
    def tile(c,
             idPrefix: str,
             monitor: Monitor,
             xp: List[Tuple[float, float, float]],
             yp: List[Tuple[float, float, float]],
             fs: Dict[FrameId, "Frame"]) -> Dict[Direction, List["Frame"]]:
        outline: Dict[Direction, List["Frame"]] = {}
        outline[Direction.TOP] = []
        outline[Direction.BOTTOM] = []
        outline[Direction.LEFT] = []
        outline[Direction.RIGHT] = []

        for y in range(len(yp)):
            for x in range(len(xp)):
                frame = c(f"{idPrefix}-{x}-{y}", monitor, xp[x], yp[y])
                fs[frame.id] = frame

                if x != 0: frame.link_to(fs[f"{idPrefix}-{x-1}-{y}"], Direction.LEFT)
                if y != 0: frame.link_to(fs[f"{idPrefix}-{x}-{y-1}"], Direction.TOP)
                if y == 0: outline[Direction.TOP].append(frame)
                if y == len(yp) - 1: outline[Direction.BOTTOM].append(frame)
                if x == 0: outline[Direction.LEFT].append(frame)
                if x == len(xp) - 1: outline[Direction.RIGHT].append(frame)
        return outline


FrameSet = Dict[FrameId, Frame]


class Window:
    get_top_level_window: Any = None

    pop_balloon: Any = None

    is_ignored_window: Any = None

    @classmethod
    def list(c, cond: Optional[Callable[[Any], bool]] = None) -> List[Any]:
        ret = []

        def f(win, _):
            if c.is_ignored_window(win): return True
            if cond and not cond(win): return True
            ret.append(win)
            return True

        keyhac.Window.enum(f, None)
        ret.sort(key=cmp_to_key(lambda a, b: a.getHWND() - b.getHWND()))
        return ret

    @classmethod
    def list_in_frame(c, fs: FrameSet, frame: Frame) -> List[Any]:
        return c.list(lambda win: frame == Frame.nearest(fs, Box.from_rect(win.getRect()).center()))

    @classmethod
    def current(c) -> Any:
        win = c.get_top_level_window()
        return None if win is None or c.is_ignored_window(win) else win

    @classmethod
    def frame(c, fs: FrameSet, win: Any) -> Frame:
        box = Box.from_rect(win.getRect())
        frame = Frame.nearest(fs, box.center())
        frame.latest_win = win.getHWND()
        return frame

    @classmethod
    def close(c) -> None:
        win = c.current()
        if win: win.sendMessage(keyhac.WM_SYSCOMMAND, keyhac.SC_CLOSE)

    @classmethod
    def toggle_maximize(c) -> None:
        win = c.current()
        if win:
            if win.isMaximized():
                win.restore()
            else:
                win.maximize()

    @classmethod
    def reactivate_binds(c) -> None:
        win = c.current()
        for w in c.list():
            if w != win:
                w.setForeground()
                break

    @classmethod
    def focus_any(c, fs: FrameSet) -> bool:
        for win in c.list():
            win.setForeground()
            return True
        return False

    @classmethod
    def focus_by_direction(c, fs: FrameSet, dir: Direction) -> bool:
        win = c.current()
        if not win: return c.focus_any(fs)

        for frame in c.frame(fs, win).traverse_links(dir):
            if c.focus_by_frame(fs, frame): return True

        return False

    @classmethod
    def focus_by_frame(c, fs: FrameSet, frame: Optional[Frame], offset: int = 0) -> bool:
        if not frame:
            win = c.current()
            if not win: return c.focus_any(fs)

            frame = c.frame(fs, win)

        wins = c.list_in_frame(fs, frame)
        if not wins: return False

        return c.focus_in_order(fs, wins, offset, frame.latest_win)

    @classmethod
    def focus_by_application(c, fs: FrameSet, process_name: str, open_path: Optional[str] = None, offset: int = 1) -> bool:
        wins = c.list(lambda win: win.getProcessName() == process_name)

        if not wins:
            pyauto.shellExecute("open", open_path or process_name)
            return True

        return c.focus_in_order(fs, wins, offset)

    @classmethod
    def focus_in_order(c, fs: FrameSet, wins: List[Any], offset: int, latest_win: Optional[int] = None) -> bool:
        index: Optional[int] = None
        current = c.current()
        for i, w in enumerate(wins):
            if w == current:
                index = i
                break

        if index is None and latest_win:
            for i, w in enumerate(wins):
                if w.getHWND() == latest_win:
                    index = i
                    break

        if index is None: index = 0

        current = wins[(index + offset) % len(wins)]
        current.setForeground()

        # Report orders by hs.alert for convenience
        apps: Dict[str, int] = {}
        for win in wins:
            app = win.getProcessName()
            apps[app] = 1 + apps.get(app, 0)

        messages: List[str] = []
        for win in wins:
            prefix = "◆" if win == current else "◇"
            app = win.getProcessName()
            title = f"{app} ({win.getText()[:30]})" if 1 < apps[app] else app
            messages.append(f"{prefix} {title}")

        try:
            c.pop_balloon("alert_windows", "\n".join(messages), 1000)
        except AttributeError:
            # TODO: Why this happens?
            pass

        return True

    @classmethod
    def move_by_direction(c, fs: FrameSet, dir: Direction) -> None:
        win = c.current()
        if not win: return

        frame = c.frame(fs, win)
        frame = frame.links.get(dir) or frame
        win.setRect(frame.box.rect())

    @classmethod
    def reset_size(c, fs: FrameSet) -> None:
        win = c.current()
        if not win: return

        frame = c.frame(fs, win)
        win.setRect(frame.box.rect())

    @classmethod
    def resize_by_direction(c, fs: FrameSet, dir: Direction, l: float) -> None:
        win = c.current()
        if not win: return

        box = Box.from_rect(win.getRect())
        frame = c.frame(fs, win)
        box.min = box.min + dir.vector() * frame.scaler.min * l
        box.max = box.max + dir.vector() * frame.scaler.max * l
        win.setRect(box.rect())
