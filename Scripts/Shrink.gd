class_name Shrink extends Fading

@export var curve: Curve
@export var base_size: float


func _process(delta: float) -> void:
    var t = curve.sample(inverse_lerp(0, lifetime, life)) * base_size
    scale = Vector2(t, t)
    super (delta)