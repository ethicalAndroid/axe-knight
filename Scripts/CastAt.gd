class_name CastAt extends ShapeCast2D

@export var _length: float

func Aim(direction: Vector2):
    target_position = direction * _length