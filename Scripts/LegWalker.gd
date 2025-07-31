class_name LegWalker extends CharacterBody2D

@export var _speed: float = 384
@export var _gravity: float = 1024
@export var _jump_speed: float = 640

var horizontal_input: float
var vertical_momentum: float
var jump_buffer: float
var jump_released: bool
var coyote_t: float

const JUMP_BUFFER_TIME = 0.1
const COYOTE_TIME = 0.1
const JUMP_RELEASE_CUT = 0.5

func GetInput():
    horizontal_input = Input.get_axis("Left", "Right")
    if Input.is_action_just_pressed("Jump"):
        jump_buffer = JUMP_BUFFER_TIME
    elif Input.is_action_just_released("Jump"):
        jump_released = true

func LegsMovement(delta: float):
    var movement = Vector2.ZERO
    movement.x = horizontal_input * _speed

    if TryJump():
        vertical_momentum = - _jump_speed
        movement.y = vertical_momentum
    elif is_on_floor():
        vertical_momentum = 0
    else:
        ProcessVerticalMomentum(delta)
        movement.y = vertical_momentum
    velocity = movement

func ProcessVerticalMomentum(delta: float):
    if (jump_released && vertical_momentum < 0):
        jump_released = false
        vertical_momentum = vertical_momentum * JUMP_RELEASE_CUT
    vertical_momentum += _gravity * delta

func TryJump() -> bool:
    if jump_buffer > 0 && coyote_t > 0:
        jump_buffer = 0
        coyote_t = 0
        return true
    return false

func UpdateInput(delta: float):
    if is_on_floor():
        coyote_t = COYOTE_TIME
    else:
        coyote_t -= delta
    jump_buffer -= delta
    jump_released = false