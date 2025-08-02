class_name DragonKnight extends CharacterBody2D

@export var _run_speed: float = 384
@export var _max_hp: int
@export var _gravity: float = 1024
@export var _jump_speed: float = 640
@export var _target: AxeKnight
@export var _animator: DragonAnimator
@export var _axe: AxeSpawner
@export var _laser: LaserBlaster
@export var _shot: ShotSpawner
@export var _tremor: TremorSlam
@export var _dash_speed: float = 768

@export var _attack_timers: Array[Timer]

@export var _attack_list: Array[Attack]
@export var _dash_targets: Array[Node2D]

@export var _dash_attack: ShapeCast2D

enum Attack {
    Axe, Laser, Shot, Tremor, Dash
}

var horizontal_input: float
var vertical_momentum: float
var current_hp: int
var just_jumped: bool
var index: int = 0
var dash_direction: Vector2
var dash_time: float
var d_index: int = 0

const FORWARD_AIM_TIME = 0.2

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
        Attack.Dash:
            NextDash()
    if attack != Attack.Dash:
        _attack_timers[attack].start()
    index = (index + 1) % _attack_list.size()

func _ready():
    current_hp = _max_hp
    propagate_call("SetTarget", [_target])
    _attack_timers[0].start()

func EndDash():
    dash_time = 0
    _attack_timers[Attack.Dash].start()

func OnHit(_direction: Vector2, _melee: bool):
    if (dash_time > 0 && _melee):
        _target.Clash(global_position)
        EndDash()
        return
    current_hp -= 1
    

func _physics_process(delta: float) -> void:
    if dash_time > 0:
        DashMovement(delta)
    else:
        LegsMovement(delta)
    move_and_slide()

func NextDash():
    var t_pos: Vector2
    if (_dash_targets[d_index] == null):
        t_pos = _target.global_position + _target.velocity * FORWARD_AIM_TIME
    else:
        t_pos = _dash_targets[d_index].global_position
    var towards = t_pos - global_position
    dash_direction = towards.normalized()
    _animator.SetDirection(dash_direction.x)
    dash_time = towards.length() / _dash_speed
    d_index = (d_index + 1) % _dash_targets.size()

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

func DashMovement(delta: float):
    if _dash_attack.is_colliding():
        if _target.attacks == AxeKnight.Attack.DashSpent || _target.attacks == AxeKnight.Attack.Charged:
            _target.Clash(global_position)
        else:
            _target.OnHit(dash_direction, true)
        EndDash()
        return

    dash_time -= delta
    velocity = dash_direction * _dash_speed

    if dash_time < 0:
        EndDash()
