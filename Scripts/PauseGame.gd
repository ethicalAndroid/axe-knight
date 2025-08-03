class_name PauseGame extends Node2D

@export var paused: Array[Node]
@export var remove: Array[Node]

func Pause():
    call_deferred("SetPauseInternal", Node.PROCESS_MODE_DISABLED)

func Remove():
    for x in remove:
        x.queue_free()

func SetPauseInternal(mode: ProcessMode):
    for x in paused:
        x.process_mode = mode

func Resume():
    call_deferred("SetPauseInternal", Node.PROCESS_MODE_INHERIT)

signal defer_lose()
func DeferLose():
    defer_lose.emit()

signal defer_win()
func DeferWin():
    defer_win.emit()

signal defer_timeoout()
func DeferTimeout():
    defer_timeoout.emit()