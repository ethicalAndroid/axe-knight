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
@export var _hurt_stun_timer: Timer
@export var _invicibility_timer: Timer
@export var _slash_timer: Timer
@export var _trail: PackedScene
@export var _sprite: Blink
@export var _target: DragonKnight
@export var _reflect: PackedScene
@export var _reflect_speed: float

@export var _gradient_charge: Gradient
@export var _gradient_spent: Gradient

@export var _shine_k: PackedScene
@export var _shine_both: PackedScene
@export var _shockwave: PackedScene

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

signal on_hit()

func _ready() -> void:
	dashing = false
	attacks = Attack.Ready
	call_deferred("Dash", Vector2.DOWN)

func OnHit(_direction: Vector2, _melee: bool):
	if !IsInvincible():
		vertical_momentum = - _dash_jump_speed
		temporary_speed = sign(_direction.x) * _dash_speed
		_hurt_stun_timer.start()
		_invicibility_timer.start()
		_sprite.Blink()
		_animator.TransitionTo(KnightAnimator.State.Hurt)
		on_hit.emit()

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

func Clash(opponent: Vector2):
	attacks = Attack.Charged
	_slash_timer.start()
	_hurt_stun_timer.start()
	
	var direction = opponent - global_position
	vertical_momentum = - _dash_jump_speed
	temporary_speed = sign(-direction.x) * _dash_speed
	
	_animator.TransitionTo(KnightAnimator.State.Slash)
	_animator.SetDashDirection(direction)

func TrailTimerTimeout():
	if (attacks != Attack.Ready):
		var trail: Fading = _trail.instantiate()
		trail.Copy(_sprite)
		if attacks == Attack.BothSpent:
			trail.gradient = _gradient_spent
		else:
			trail.gradient = _gradient_charge
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
	var effect: Node2D = _shockwave.instantiate()
	get_node(Fading.ROOT_PARENT).add_child(effect)
	effect.global_position = global_position

	_animator.SetDirection(dash_direction.x)
	_animator.TransitionTo(KnightAnimator.State.Slam)
	attacks = Attack.BothSpent
	temporary_speed = 0
	_slam_stun_timer.start()
	var collisions = _slam_cast.get_collision_count()
	for i in collisions:
		var c = _slam_cast.get_collider(i)
		if c != null:
			c.call("OnHit", (c.global_position - self.global_position).normalized(), true)
			if c.is_class("RigidBody2D"):
				ReflectAttack(c.global_position)
				

func ReflectAttack(pos: Vector2):
	var spawn: DirectionProjectile = _reflect.instantiate()
	get_node(Projectile.ROOT_PARENT).add_child(spawn)
	spawn.global_position = pos
	spawn.Shoot((_target.global_position - pos).normalized() * _reflect_speed, 0)

func AxeSwing():
	_slash_timer.start()
	_animator.TransitionTo(KnightAnimator.State.Slash)
	_animator.SetDashDirection(_aiming._direction)
	var collisions = _slash_cast.get_collision_count()
	var clash = false
	if (collisions > 0):
		attacks = Attack.Charged
	for i in collisions:
		var c = _slash_cast.get_collider(i)
		if c != null:
			if c.is_class("RigidBody2D"):
				ReflectAttack(c.global_position)
			elif c.is_class("CharacterBody2D") && c.IsDashing():
				clash = true
			c.call("OnHit", _aiming._direction, true)
	if clash:
		var effect: Node2D = _shine_both.instantiate()
		get_node(Fading.ROOT_PARENT).add_child(effect)
		effect.global_position = global_position + (_target.global_position - global_position) * 0.5
		effect.rotation = Vector2.RIGHT.angle_to(_aiming._direction)
	else:
		var effect: Node2D = _shine_k.instantiate()
		get_node(Fading.ROOT_PARENT).add_child(effect)
		effect.global_position = global_position + _slash_cast.target_position
		effect.rotation = Vector2.RIGHT.angle_to(_aiming._direction)
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
			EndDash()
			AxeSwing()

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
