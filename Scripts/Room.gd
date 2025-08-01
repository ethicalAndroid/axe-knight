class_name Room extends Node2D

@export var transition: AnimationPlayer
@export var loading: Array[Node2D]

func _ready() -> void:
	transition.queue("screen_open")

func AnimationEnded(animation: StringName):
	if (animation == "screen_open"):
		SetupRoom()

func SetupRoom():
	for node in loading:
		node.process_mode = Node.PROCESS_MODE_INHERIT
