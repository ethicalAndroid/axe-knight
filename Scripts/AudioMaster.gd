class_name AudioMaster extends Node

var player: AudioStreamPlayer

const PLAYER_ROOT = "/root/Game/Audio"
const PACKED_PLAYER = preload("res://Nodes/audio.tscn")

func _ready() -> void:
    player = get_node(PLAYER_ROOT)

func Play(audio: AudioStream):
    var p = PACKED_PLAYER.instantiate()
    player.add_child(p)
    p.stream = audio
    p.play()
    p.finished.connect(p.queue_free)
