class_name AxeKnight extends CharacterBody2D

@export var _speed: float
@export var _gravity: float
@export var _jump_speed: float
@export var _dash_jump_speed: float
@export var _dash_timer: Timer
@export var _dash_speed: float
@export var _dash_end_jump: float
@export var _dash_slam_requirement: float = 0.9
@export var _aiming: LookAt
@export var _bump_collision: CastAt
@export var _slash_cast: CastAt


enum Attack {
    Ready, DashSpent, BothSpent
}

var horizontal_input: float
var vertical_momentum: float
var jump_buffer: float
var jump_released: bool
var coyote_t: float
var dash_direction: Vector2
var attack_pressed: bool
var attacks: Attack
var temporary_speed: float = 0

func _ready() -> void:
    attacks = Attack.Ready
    _bump_collision.enabled = false

const JUMP_BUFFER_TIME = 0.1
const COYOTE_TIME = 0.1
const JUMP_RELEASE_CUT = 0.5

func CancelDash():
    _dash_timer.stop()

func EndDash():
    vertical_momentum = - _dash_end_jump
    _bump_collision.enabled = false

func Slam(normal: Vector2):
    EndDash()

func AxeSwing():
    var collisions = _slash_cast.get_collision_count()
    if (collisions > 0):
        attacks = Attack.Ready

# INPUT
func _process(_delta: float) -> void:
    horizontal_input = Input.get_axis("Left", "Right")
    if Input.is_action_just_pressed("Jump"):
        jump_buffer = JUMP_BUFFER_TIME
    elif Input.is_action_just_released("Jump"):
        jump_released = true
    if Input.is_action_just_pressed("Attack"):
        attack_pressed = true

func _physics_process(delta: float) -> void:
    _aiming.SetAim(get_global_mouse_position())
    _slash_cast.Aim(_aiming._direction)

    ProcessAttack()
    CheckForSlam()

    GetMovement(delta)
    UpdateInput(delta)
    move_and_slide()

func ProcessAttack():
    if !IsDashing() && is_on_floor():
        attacks = Attack.Ready

    if (attack_pressed):
        attack_pressed = false

        if attacks == Attack.DashSpent:
            attacks = Attack.BothSpent
            AxeSwing()
            if IsDashing():
                CancelDash()
            else:
                EndDash()

        elif (attacks == Attack.Ready):
            attacks = Attack.DashSpent
            dash_direction = _aiming._direction
            _bump_collision.Aim(dash_direction)
            _bump_collision.enabled = true
            temporary_speed = 0
            _dash_timer.start()

func IsDashing() -> bool:
    return _dash_timer.time_left > 0

func CheckForSlam():
    var collisions = _bump_collision.get_collision_count()
    if (collisions > 0):
        for i in collisions:
            var normal = _bump_collision.get_collision_normal(i)
            if (-normal.dot(dash_direction) > _dash_slam_requirement):
                Slam(normal)

func UpdateInput(delta: float):
    if is_on_floor():
        coyote_t = COYOTE_TIME
    else:
        coyote_t -= delta
    jump_buffer -= delta
    jump_released = false

# MOVEMENT

func GetMovement(delta: float):
    if IsDashing():
        DashMovement(delta)
    else:
        LegsMovement(delta)

func DashMovement(delta: float):
    var movement = Vector2.ZERO
    if TryJump():
        _dash_timer.start()
        temporary_speed = (dash_direction * _dash_speed).x
        vertical_momentum = - _dash_jump_speed

    if (temporary_speed):
        ProcessVerticalMomentum(delta)
        movement = Vector2(temporary_speed, vertical_momentum)
    else:
        movement = dash_direction * _dash_speed
    velocity = movement
    
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
