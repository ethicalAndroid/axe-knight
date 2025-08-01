class_name DragonKnight extends CharacterBody2D

@export var _run_speed: float = 384
@export var _max_hp: int
@export var _gravity: float = 1024
@export var _jump_speed: float = 640
@export var _target: Node2D
@export var _animator: DragonAnimator
@export var _axe: AxeSpawner
@export var _laser: LaserBlaster
@export var _shot: ShotSpawner
@export var _tremor: TremorSlam

@export var _attack_timers: Array[Timer]

@export var _attack_list: Array[Attack]

enum Attack {
    Axe, Laser, Shot, Tremor
}

var horizontal_input: float
var vertical_momentum: float
var current_hp: int
var just_jumped: bool
var index: int = 0

func NextAttack():
    var attack: Attack = _attack_list[index]
    match attack:
        Attack.Axe:
            _axe.StartAttack(GetDirection().x)
        Attack.Laser:
            _laser.StartAiming()
        Attack.Shot:
            _shot.Shoot()
        Attack.Tremor:
            _tremor.StartTremors()
    _attack_timers[attack].start()
    index = (index + 1) % _attack_list.size()

func _ready():
    current_hp = _max_hp
    propagate_call("SetTarget", [_target])
    _attack_timers[0].start()

func OnHit(direction: Vector2):
    pass

func _physics_process(delta: float) -> void:
    LegsMovement(delta)
    move_and_slide()

func ProcessVerticalMomentum(delta: float):
    vertical_momentum += _gravity * delta

func GetDirection() -> Vector2:
    return _target.global_position - global_position

func LegsMovement(delta: float):
    var movement = Vector2.ZERO
    movement.x = horizontal_input * _run_speed
    _animator.SetDirection(GetDirection().x)

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