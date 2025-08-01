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
@export var _max_hp: int = 3
@export var _hurt_stun_timer: Timer
@export var _invicibility_timer: Timer
@export var _slash_timer: Timer
@export var _trail: PackedScene
@export var _sprite: Blink

enum Attack {
    Ready, DashSpent, BothSpent, Charged
}

var dash_direction: Vector2
var attack_pressed: bool
var attacks: Attack
var temporary_speed: float = 0
var input_mode_mouse: bool = true
var look_direction: Vector2
var dashing: bool
var hp: int

func _ready() -> void:
    hp = _max_hp
    dashing = false
    attacks = Attack.Ready
    call_deferred("Dash", Vector2.DOWN)

func OnHit(_direction: Vector2):
    if !IsInvincible():
        vertical_momentum = - _dash_jump_speed
        temporary_speed = sign(_direction.x) * _dash_speed
        _hurt_stun_timer.start()
        _invicibility_timer.start()
        _sprite.Blink()
        _animator.TransitionTo(KnightAnimator.State.Hurt)
        hp -= 1

func EndDash():
    vertical_momentum = - _dash_end_jump
    dashing = false
    _dash_timer.stop()

func DashTimerTimeout():
    if dashing:
        EndDash()
        _animator.TransitionTo(KnightAnimator.State.Airborne)

func SlamTimerTimeout():
    pass

func StunTimerTimeout():
    attacks = Attack.Ready
    EndDash()

func TrailTimerTimeout():
    if (attacks == Attack.DashSpent):
        var trail: Fading = _trail.instantiate()
        trail.global_position = _sprite.global_position
        trail.texture = _sprite.texture
        trail.global_rotation = _sprite.global_rotation
        trail.global_scale = _sprite.global_scale
        trail.flip_h = _sprite.flip_h
        trail.flip_v = _sprite.flip_v
        get_node(Fading.ROOT_PARENT).add_child(trail)

func SlashTimerTimeout():
    if attacks == Attack.Charged:
        attacks = Attack.Ready
    if is_on_floor():
        _animator.TransitionTo(KnightAnimator.State.Idle)
    else:
        _animator.TransitionTo(KnightAnimator.State.Airborne)

func Slam(_normal: Vector2):
    EndDash()
    _animator.SetDirection(dash_direction.x)
    _animator.TransitionTo(KnightAnimator.State.Slam)
    attacks = Attack.BothSpent
    temporary_speed = 0
    _slam_stun_timer.start()
    var collisions = _slam_cast.get_collision_count()
    for i in collisions:
        if _slam_cast.get_collider(i) != null:
            _slam_cast.get_collider(i).call("OnHit", (_slam_cast.get_collision_point(i) - self.global_position).normalized())
    

func AxeSwing():
    _slash_timer.start()
    _animator.TransitionTo(KnightAnimator.State.Slash)
    _animator.SetDashDirection(_aiming._direction)
    var collisions = _slash_cast.get_collision_count()
    if (collisions > 0):
        attacks = Attack.Charged
    for i in collisions:
        if _slash_cast.get_collider(i) != null:
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
    if !IsDashing() && is_on_floor() && attacks != Attack.Charged:
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
    _animator.TransitionTo(KnightAnimator.State.Dash)
    _animator.SetDashDirection(direction)


func IsDashing() -> bool:
    return dashing

func IsHurt() -> bool:
    return !_hurt_stun_timer.is_stopped()

func IsInvincible() -> bool:
    return !_invicibility_timer.is_stopped()

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
    if !_slam_stun_timer.is_stopped() || IsHurt():
        ProcessVerticalMomentum(delta)
        velocity = Vector2(temporary_speed, vertical_momentum)
    elif IsDashing():
        DashMovement(delta)
    else:
        LegsMovement(delta)
        

func DashMovement(delta: float):
    var movement = Vector2.ZERO

    if is_on_floor():
        _animator.SetDirection(dash_direction.x)
        _animator.TransitionTo(KnightAnimator.State.Slide)
    elif (!temporary_speed && attacks == Attack.DashSpent):
        _animator.SetDashDirection(dash_direction)
        _animator.TransitionTo(KnightAnimator.State.Dash)

    if TryJump():
        _dash_timer.start()
        temporary_speed = (dash_direction * _dash_speed).x
        vertical_momentum = - _dash_jump_speed
        _animator.SetVSpeed(vertical_momentum)
        _animator.SetDirection(temporary_speed)
        _animator.TransitionTo(KnightAnimator.State.Airborne)

    if (temporary_speed):
        ProcessVerticalMomentum(delta)
        movement = Vector2(temporary_speed, vertical_momentum)
    else:
        movement = dash_direction * _dash_speed
    velocity = movement
