class_name Projectile extends RigidBody2D

var velocity: Vector2

const ROOT_PARENT = "/root/Game/Projectiles"

func OnBodyEntered(body: Node):
	if body.is_class("CharacterBody2D"):
		body.call("OnHit", velocity, false)
	queue_free()

func Shoot(shoot_velocity: Vector2, shoot_gravity: float):
	velocity = shoot_velocity
	gravity_scale = shoot_gravity
	linear_velocity = shoot_velocity

func OnHit(_direction: Vector2, _melee: bool):
	queue_free()
