class_name BossHealth extends Control

@export var max_life: int
@export var bar: TextureRect
@export var hurt: AudioStream
@export var death: AudioStream

var life: int
var base_width: float

signal on_death()

func _ready() -> void:
    life = max_life
    base_width = bar.size.x

func LoseLife():
    if life == 0:
        return
    life -= 1
    bar.size.x = (life / float(max_life)) * base_width
    if life == 0:
        Audio.Play(death)
        bar.visible = false
        on_death.emit()
    else:
        Audio.Play(hurt)
