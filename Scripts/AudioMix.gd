class_name AudioMix extends Node

@export var trans_speed: float
@export var a1: AudioStreamPlayer
@export var a2: AudioStreamPlayer
@export var l1: float
@export var l2: float

var direction: bool
var t: float = 0

func _process(delta: float) -> void:
	if direction:
		t = min(t + delta, 1)
	else:
		t = max(t - delta, 0)
	a1.volume_db = linear_to_db(lerp(float(0), l1, t))
	a2.volume_db = linear_to_db(lerp(l2, float(0), t))
