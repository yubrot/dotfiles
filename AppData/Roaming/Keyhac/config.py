import keyhac
import math
from enum import Enum
from typing import Tuple, List, Set, Dict, Optional, Any
from functools import cmp_to_key


def configure(keymap: Any) -> None:
    ms = MonitorSet()
    for i, monitor_info in enumerate(keyhac.Window.getMonitorInfo()):
        box = Box(monitor_info[1])
        ms.register(Monitor(i, box))

    fs = FrameSet()
    fs.initialize(
        Frame("TopLeft", 0, (0, 0.25, 0.5), (0, 0.3, 0.5),
              {Direction.BOTTOM: "Left", Direction.RIGHT: "Center"}),
        Frame("Left", 0, (0, 0.25, 0.5), (0, 0.5, 1),
              {Direction.TOP: "TopLeft", Direction.BOTTOM: "BottomLeft", Direction.RIGHT: "Center"}),
        Frame("BottomLeft", 0, (0, 0.25, 0.5), (0.5, 0.7, 1),
              {Direction.TOP: "Left", Direction.RIGHT: "Center"}),
        Frame("Top", 0, (0.25, 0.5, 0.75), (0, 0.2, 0.5),
              {Direction.BOTTOM: "Center", Direction.LEFT: "Left", Direction.RIGHT: "Right"}),
        Frame("Center", 0, (0.25, 0.5, 0.75), (0.1, 0.5, 0.9),
              {Direction.TOP: "Top", Direction.BOTTOM: "Bottom", Direction.LEFT: "Left", Direction.RIGHT: "Right"}),
        Frame("Bottom", 0, (0.25, 0.5, 0.75), (0.5, 0.8, 1),
              {Direction.TOP: "Center", Direction.LEFT: "Left", Direction.RIGHT: "Right"}),
        Frame("TopRight", 0, (0.5, 0.75, 1), (0, 0.3, 0.5),
              {Direction.BOTTOM: "Right", Direction.LEFT: "Center", Direction.RIGHT: "Sub"}),
        Frame("Right", 0, (0.5, 0.75, 1), (0, 0.5, 1),
              {Direction.TOP: "TopRight", Direction.BOTTOM: "BottomRight", Direction.LEFT: "Center", Direction.RIGHT: "Sub"}),
        Frame("BottomRight", 0, (0.5, 0.75, 1), (0.5, 0.7, 1),
              {Direction.TOP: "Right", Direction.LEFT: "Center", Direction.RIGHT: "Sub"}),
        Frame("Sub", 1, (0, 0.5, 1), (0, 0.5, 1),
              {Direction.LEFT: "Right"}))
    fs.populate(ms, 0)

    def is_ignored_window(win: Any) -> bool:
        if win.getText() == "":
            return True
        if not win.isVisible():
            return True
        if win.isMinimized():
            return True
        rect = win.getRect()
        if rect[0] == rect[2] or rect[1] == rect[3]:
            return True

        # ignore VR related applications
        if win.getText() == "SteamVR" or win.getText() == "SteamVR ステータス" or win.getText() == "vrmonitor":
            return True
        # ignore explorer.exe
        if win.getClassName() == "Progman":
            return True
        # ignore NVIDIA GeForce Overlay
        if win.getClassName() == "CEF-OSC-WIDGET":
            return True
        # ignore ApplicationFrameWindow
        if win.getClassName() == "ApplicationFrameWindow":
            return True
        # ignore CoreWindow
        if win.getClassName() == "Windows.UI.Core.CoreWindow":
            return True
        return False

    Operation.is_ignored_window = is_ignored_window
    Operation.get_top_level_window = keymap.getTopLevelWindow

    keymap.clipboard_history.maxnum = 1

    # treat Muhenkan as U0
    keymap.replaceKey("(29)", 235)
    keymap.defineModifier(235, "User0")

    bind = keymap.defineWindowKeymap()
    bind["BACKSLASH"] = keymap.InputKeyCommand("S-UNDERSCORE")

    bind["U0-C-R"] = keymap.command_ReloadConfig

    bind["U0-Return"] = keymap.ShellExecuteCommand(None, "wt.exe", "", "")
    bind["U0-S-C"] = Operation.close_window

    bind["U0-M"] = Operation.toggle_maximize_window

    bind["U0-K"] = lambda: Operation.focus_frame_by_direction(fs, Direction.TOP)
    bind["U0-J"] = lambda: Operation.focus_frame_by_direction(fs, Direction.BOTTOM)
    bind["U0-H"] = lambda: Operation.focus_frame_by_direction(fs, Direction.LEFT)
    bind["U0-L"] = lambda: Operation.focus_frame_by_direction(fs, Direction.RIGHT)

    bind["U0-I"] = lambda: Operation.focus_window_in_frame(fs, +1)
    bind["U0-O"] = lambda: Operation.focus_window_in_frame(fs, -1)

    bind["U0-E"] = lambda: Operation.move_window_by_direction(fs, Direction.TOP)
    bind["U0-D"] = lambda: Operation.move_window_by_direction(fs, Direction.BOTTOM)
    bind["U0-S"] = lambda: Operation.move_window_by_direction(fs, Direction.LEFT)
    bind["U0-F"] = lambda: Operation.move_window_by_direction(fs, Direction.RIGHT)

    bind["U0-S-I"] = lambda: Operation.reset_window_size(fs)

    bind["U0-S-K"] = lambda: Operation.resize_window_by_direction(fs, Direction.TOP, 50)
    bind["U0-S-J"] = lambda: Operation.resize_window_by_direction(fs, Direction.BOTTOM, 50)
    bind["U0-S-H"] = lambda: Operation.resize_window_by_direction(fs, Direction.LEFT, 50)
    bind["U0-S-L"] = lambda: Operation.resize_window_by_direction(fs, Direction.RIGHT, 50)

    Operation.reactivate_binds()


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

    def __mul__(self, s: float) -> "Vector":
        return Vector(self.x * s, self.y * s)

    def distance_to(self, other: "Vector") -> float:
        return abs(self.x - other.x) + abs(self.y - other.y)

    def __str__(self) -> str:
        return f"({self.x}, {self.y})"


class Box:
    def __init__(self, rect: Tuple[float, float, float, float]) -> None:
        self.min = Vector(rect[0], rect[1])
        self.max = Vector(rect[2], rect[3])

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Box) and self.min == other.min and self.max == other.max

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

    def visit_order(self) -> List["Direction"]:
        if self == Direction.TOP:
            return [Direction.TOP, Direction.LEFT, Direction.RIGHT]
        elif self == Direction.BOTTOM:
            return [Direction.BOTTOM, Direction.LEFT, Direction.RIGHT]
        elif self == Direction.LEFT:
            return [Direction.LEFT, Direction.TOP, Direction.BOTTOM]
        else:
            return [Direction.RIGHT, Direction.TOP, Direction.BOTTOM]

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

    def map(self, vec: Vector) -> Vector:
        return Vector(
            self.box.min.x*(1 - vec.x) + self.box.max.x*vec.x,
            self.box.min.y*(1 - vec.y) + self.box.max.y*vec.y)

    def __str__(self) -> str:
        return f"Monitor({self.id}, {self.box})"


class MonitorSet:
    def __init__(self) -> None:
        self.items: Dict[int, Monitor] = {}

    def register(self, monitor: Monitor) -> None:
        self.items[monitor.id] = monitor

    def get(self, id: MonitorId) -> Monitor:
        return self.items[id]

    def contains(self, id: MonitorId) -> bool:
        return id in self.items


FrameId = str


class Frame:
    def __init__(self,
                 id: FrameId,
                 monitor: MonitorId,
                 x: Tuple[float, float, float],
                 y: Tuple[float, float, float],
                 links: Dict[Direction, FrameId]) -> None:
        self.id = id
        self.monitor = monitor
        self.box = Box((x[0], y[0], x[2], y[2]))
        self.base = Vector(x[1], y[1])
        self.links = links
        self.latest_window: Optional[int] = None
        t = 1 if y[0] != 0 else 0
        b = 1 if y[2] != 1 else 0
        l = 1 if x[0] != 0 else 0
        r = 1 if x[2] != 1 else 0
        self.scaler = Box((
            -1 if l == r else l,
            -1 if t == b else t,
            1 if l == r else r,
            1 if t == b else b,
        ))

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Frame) and self.id == other.id

    def populate(self, ms: MonitorSet, padding: int) -> bool:
        if not ms.contains(self.monitor):
            print(f"Unknown montior {self.monitor}")
            return False
        monitor = ms.get(self.monitor)

        def map_with_offset(v: Vector, f: float) -> Vector:
            px = 1 if v.x in {0, 1} else 0.5
            py = 1 if v.y in {0, 1} else 0.5
            return monitor.map(v) + Vector(px, py) * f

        self.box.min = map_with_offset(self.box.min, padding)
        self.box.max = map_with_offset(self.box.max, -padding)
        self.base = monitor.map(self.base)
        return True

    def __str__(self) -> str:
        return f"Frame({self.id}, {self.box})"


class FrameSet:
    def __init__(self) -> None:
        self.items: Dict[str, Frame] = {}

    def register(self, frame: Frame) -> None:
        self.items[frame.id] = frame

    def get(self, id: FrameId) -> Frame:
        return self.items[id]

    def get_nearest(self, pos: Vector) -> Frame:
        return min([(f.base.distance_to(pos), i, f) for i, f in enumerate(self.items.values())])[2]

    def get_by_direction(self, base: Frame, dir: Direction) -> Optional[Frame]:
        return self.items[base.links[dir]] if dir in base.links else None

    def enumerate_by_direction(self, base: Frame, dir: Direction) -> List[Frame]:
        todo = [self.get_by_direction(base, dir)]
        done: Set[FrameId] = set()
        ret: List[Frame] = []
        while todo:
            f = todo.pop(0)
            if f and f.id not in done:
                done.add(f.id)
                ret.append(f)
                for d in dir.visit_order():
                    todo.append(self.get_by_direction(f, d))
        return ret

    def contains(self, id: FrameId) -> bool:
        return id in self.items

    def populate(self, ms: MonitorSet, padding: int) -> None:
        missing_frames: Set[FrameId] = set()
        for frame in self.items.values():
            for id in frame.links.values():
                if not self.contains(id):
                    raise Exception(f"Unknown frame {id}")
            if not frame.populate(ms, padding):
                missing_frames.add(frame.id)

        for id in missing_frames:
            del self.items[id]
        for frame in self.items.values():
            missing_links = [k for k, v in frame.links.items() if v in missing_frames]
            for dir in missing_links:
                del frame.links[dir]

    def initialize(self, *frames: Frame) -> None:
        for frame in frames:
            self.register(frame)


class Operation:
    get_top_level_window: Any = None

    is_ignored_window: Any = None

    @classmethod
    def get_windows(c) -> List[Any]:
        ret = []

        def f(win, _):
            if not c.is_ignored_window(win):
                ret.append(win)
            return True

        keyhac.Window.enum(f, None)
        return ret

    @classmethod
    def get_windows_in_frame(c, fs: FrameSet, frame: Frame) -> List[Any]:
        def is_in_frame(win: Any) -> bool:
            box = Box(win.getRect())
            f = fs.get_nearest(box.center())
            return frame == f
        ret = [w for w in c.get_windows() if is_in_frame(w)]
        ret.sort(key=cmp_to_key(lambda a, b: a.getHWND() - b.getHWND()))
        return ret

    @classmethod
    def get_current_window(c) -> Any:
        win = c.get_top_level_window()
        return None if win is None or c.is_ignored_window(win) else win

    @classmethod
    def close_window(c) -> None:
        win = c.get_current_window()
        if win:
            win.sendMessage(keyhac.WM_SYSCOMMAND, keyhac.SC_CLOSE)

    @classmethod
    def toggle_maximize_window(c) -> None:
        win = c.get_current_window()
        if win:
            if win.isMaximized():
                win.restore()
            else:
                win.maximize()

    @classmethod
    def reactivate_binds(c) -> None:
        win = c.get_current_window()
        for w in c.get_windows():
            if w != win:
                w.setForeground()
                break

    @classmethod
    def focus_some_window(c, fs: FrameSet) -> bool:
        for win in c.get_windows():
            box = Box(win.getRect())
            base = fs.get_nearest(box.center())
            base.latest_window = win.getHWND()
            win.setForeground()
            return True
        return False

    @classmethod
    def focus_frame_by_direction(c, fs: FrameSet, dir: Direction, base: Optional[Frame] = None) -> bool:
        if not base:
            win = c.get_current_window()
            if not win:
                return c.focus_some_window(fs)
            box = Box(win.getRect())
            base = fs.get_nearest(box.center())

        base.latest_window = win.getHWND()
        for next_frame in fs.enumerate_by_direction(base, dir):
            if c.focus_window_in_frame(fs, 0, next_frame):
                return True
        return False

    @classmethod
    def focus_window_in_frame(c, fs: FrameSet, offset: int, base: Optional[Frame] = None) -> bool:
        win = c.get_current_window()
        if not base:
            if not win:
                return c.focus_some_window(fs)
            box = Box(win.getRect())
            base = fs.get_nearest(box.center())

        wins = c.get_windows_in_frame(fs, base)
        if not wins:
            return False

        current: Optional[int] = None
        for i, w in enumerate(wins):
            if w == win:
                current = i
                break

        if current is None and base.latest_window is not None:
            for i, w in enumerate(wins):
                if w.getHWND() == base.latest_window:
                    current = i
                    break

        if current is None:
            current = 0

        next_win = wins[(current + offset) % len(wins)]
        base.latest_window = next_win.getHWND()
        next_win.setForeground()
        return True

    @classmethod
    def move_window_by_direction(c, fs: FrameSet, dir: Direction) -> None:
        win = c.get_current_window()
        if not win:
            return
        box = Box(win.getRect())
        frame = fs.get_nearest(box.center())
        next_frame = fs.get_by_direction(frame, dir)
        if next_frame:
            next_frame.latest_window = win.getHWND()
            win.setRect(next_frame.box.rect())
        else:
            frame.latest_window = win.getHWND()
            win.setRect(frame.box.rect())

    @classmethod
    def reset_window_size(c, fs: FrameSet) -> None:
        win = c.get_current_window()
        if not win:
            return
        box = Box(win.getRect())
        frame = fs.get_nearest(box.center())
        frame.latest_window = win.getHWND()
        win.setRect(frame.box.rect())

    @classmethod
    def resize_window_by_direction(c, fs: FrameSet, dir: Direction, l: float) -> None:
        win = c.get_current_window()
        if not win:
            return
        box = Box(win.getRect())
        frame = fs.get_nearest(box.center())
        frame.latest_window = win.getHWND()
        box.min.x = box.min.x + dir.vector().x * frame.scaler.min.x * l
        box.min.y = box.min.y + dir.vector().y * frame.scaler.min.y * l
        box.max.x = box.max.x + dir.vector().x * frame.scaler.max.x * l
        box.max.y = box.max.y + dir.vector().y * frame.scaler.max.y * l
        win.setRect(box.rect())
