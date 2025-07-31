class_name LookAt extends Node2D

@export var _distance: float
@export var _aim: Node2D

var _look_position: Vector2
var _direction: Vector2;

func SetAim(look_position: Vector2):
    _look_position = look_position
    _direction = (look_position - self.global_position).normalized()
    _aim.position = _direction * _distance
    _aim.rotation = Vector2.RIGHT.angle_to(_direction)
