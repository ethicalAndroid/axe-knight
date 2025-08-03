class_name Fading extends Sprite2D

const ROOT_PARENT = "/root/Game/Battle/Trails"

@export var lifetime: float
@export var gradient: Gradient

var life: float = 0

func _process(delta: float) -> void:
    life += delta
    modulate = gradient.sample(inverse_lerp(0, lifetime, life))
    if (life > lifetime):
        queue_free()

func Copy(sprite: Sprite2D):
    global_position = sprite.global_position
    texture = sprite.texture
    global_rotation = sprite.global_rotation
    global_scale = sprite.global_scale
    flip_h = sprite.flip_h
    flip_v = sprite.flip_v