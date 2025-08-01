class_name DragonKnight extends CharacterBody2D

@export var _run_speed: float = 384
@export var _max_hp: int
@export var _gravity: float = 1024
@export var _jump_speed: float = 640
@export var _target: Node2D

var horizontal_input: float
var vertical_momentum: float
var current_hp: int
var just_jumped: bool

func _ready():
    current_hp = _max_hp
    propagate_call("SetTarget", [_target])

func OnHit(direction: Vector2):
    pass

func _physics_process(delta: float) -> void:
    LegsMovement(delta)
    move_and_slide()

func ProcessVerticalMomentum(delta: float):
    vertical_momentum += _gravity * delta

func LegsMovement(delta: float):
    var movement = Vector2.ZERO
    movement.x = horizontal_input * _run_speed

    if just_jumped:
        just_jumped = false
        vertical_momentum = - _jump_speed
        movement.y = vertical_momentum
    elif is_on_floor():
        vertical_momentum = 0
    else:
        ProcessVerticalMomentum(delta)
        movement.y = vertical_momentum
    velocity = movement