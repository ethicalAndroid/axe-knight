class_name DirectionProjectile extends Projectile

@export var pivot: Node2D

func Shoot(shoot_velocity: Vector2, shoot_gravity: float):
    pivot.rotation = Vector2.RIGHT.angle_to(shoot_velocity)
    super (shoot_velocity, shoot_gravity)