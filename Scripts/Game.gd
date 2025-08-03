class_name Game extends Node2D

@export var transition: AnimationPlayer
@export var battle_scene: PackedScene
@export var dialogue: DDialogue
@export var talk_blocks: Array[JSON]
@export var intro: JSON
@export var final_loop_ask: Array[JSON]
@export var final_loop_yes: Array[JSON]
@export var final_loop_no: Array[JSON]


signal loop_menu()
signal final_menu()
signal final_lost()
signal final_won()


var final_loop = false
var battle: PauseGame
var d_type: DDialogueType
var final_loop_asked: int = 0
var talks = 0

enum DDialogueType {
	NextLoop, FinalLoopQuestion
}

func FinalLoopYes():
	d_type = DDialogueType.NextLoop
	final_loop = true
	dialogue.StartJson(final_loop_yes[final_loop_asked])

func FinalLoopNo():
	d_type = DDialogueType.NextLoop
	dialogue.StartJson(final_loop_no[final_loop_asked])
	final_loop_asked = min(final_loop_asked + 1, final_loop_ask.size() - 1)

func FinalLoopAsk():
	d_type = DDialogueType.FinalLoopQuestion
	dialogue.StartJson(final_loop_ask[final_loop_asked])

func Talk():
	d_type = DDialogueType.NextLoop
	dialogue.StartJson(talk_blocks[talks])
	talks = min(talks + 1, talk_blocks.size() - 1)

func _ready() -> void:
	dialogue.StartJson(intro)
	d_type = DDialogueType.NextLoop

func DDialogueEnded():
	match d_type:
		DDialogueType.NextLoop:
			StartBattle()
		DDialogueType.FinalLoopQuestion:
			final_menu.emit()

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
	if final_loop:
		battle.Remove()
		final_won.emit()
	else:
		transition.queue("screen_close")

func OnLose():
	if final_loop:
		battle.Remove()
		final_lost.emit()
	else:
		transition.queue("screen_close")
