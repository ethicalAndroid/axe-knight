class_name AxeKnight extends LegWalker

@export var _dash_jump_speed: float = 960
@export var _dash_timer: Timer
@export var _dash_speed: float = 768
@export var _dash_end_jump: float = 128
@export var _dash_slam_requirement: float = 0.7
@export var _aiming: LookAt
@export var _bump_collision: CastAt
@export var _slash_cast: CastAt
@export var _slam_stun_timer: Timer
@export var _slam_cast: ShapeCast2D


enum Attack {
    Ready, DashSpent, BothSpent
}

var dash_direction: Vector2
var attack_pressed: bool
var attacks: Attack
var temporary_speed: float = 0
var input_mode_mouse: bool = true
var look_direction: Vector2
var dashing: bool

func _ready() -> void:
    dashing = false
    attacks = Attack.Ready
    Dash(Vector2.DOWN)

func EndDash():
    vertical_momentum = - _dash_end_jump
    dashing = false
    _dash_timer.stop()

func DashTimerTimeout():
    if dashing:
        EndDash()

func SlamTimerTimeout():
    pass

func Slam(_normal: Vector2):
    EndDash()
    attacks = Attack.BothSpent
    _slam_stun_timer.start()
    var collisions = _slam_cast.get_collision_count()
    for i in collisions:
        _slam_cast.get_collider(i).call("OnHit", (_slam_cast.get_collision_point(i) - self.global_position).normalized())
    

func AxeSwing():
    var collisions = _slash_cast.get_collision_count()
    if (collisions > 0):
        attacks = Attack.Ready
    for i in collisions:
        _slash_cast.get_collider(i).call("OnHit", _aiming._direction)

# INPUT
func _process(_delta: float) -> void:
    GetInput()

func GetInput():
    look_direction = Input.get_vector("LookLeft", "LookRight", "LookUp", "LookDown")
    if Input.is_action_just_pressed("Attack"):
        attack_pressed = true
    super ()

func _physics_process(delta: float) -> void:
    if input_mode_mouse && look_direction:
        input_mode_mouse = false
    elif !input_mode_mouse && Input.get_last_mouse_velocity():
        input_mode_mouse = true

    if input_mode_mouse:
        _aiming.SetAim(get_global_mouse_position())
    elif look_direction:
        _aiming.SetAim(self.global_position + look_direction)

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

        if (attacks == Attack.DashSpent):
            attacks = Attack.BothSpent
            AxeSwing()
            EndDash()

        elif (attacks == Attack.Ready):
            Dash(_aiming._direction)

func Dash(direction: Vector2):
    attacks = Attack.DashSpent
    dash_direction = direction
    _bump_collision.Aim(dash_direction)
    temporary_speed = 0
    dashing = true
    _dash_timer.start()


func IsDashing() -> bool:
    return dashing

func CheckForSlam():
    if !dashing:
        return
    var collisions = _bump_collision.get_collision_count()
    if (collisions > 0):
        for i in collisions:
            var normal = _bump_collision.get_collision_normal(i)
            if (-normal.dot(dash_direction) > _dash_slam_requirement):
                Slam(normal)
                return

# MOVEMENT

func GetMovement(delta: float):
    if !_slam_stun_timer.is_stopped():
        ProcessVerticalMomentum(delta)
        velocity = Vector2(0, vertical_momentum)
    elif IsDashing():
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
