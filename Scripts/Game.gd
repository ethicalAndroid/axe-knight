class_name Game extends Node2D

@export var transition: AnimationPlayer
@export var battle_scene: PackedScene

signal loop_menu()


var battle: PauseGame

func _ready() -> void:
	loop_menu.emit()

func StartBattle():
	battle = battle_scene.instantiate()
	battle.defer_lose.connect(OnLose)
	battle.defer_win.connect(OnWin)
	add_child(battle)
	transition.queue("screen_open")

func AnimationEnded(animation: StringName):
	if (animation == "screen_open"):
		battle.Resume()
	if (animation == "screen_close"):
		battle.queue_free()
		loop_menu.emit()

func OnWin():
	print("win")
	transition.queue("screen_close")

func OnLose():
	print("lose")
	transition.queue("screen_close")