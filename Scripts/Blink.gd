class_name Blink extends Sprite2D

@export var length: float
@export var gradient: Gradient

var t: float = 99

func Blink():
    t = 0

func _process(delta: float) -> void:
    if t > length:
        return
    t += delta
    modulate = gradient.sample(inverse_lerp(0, length, t))
