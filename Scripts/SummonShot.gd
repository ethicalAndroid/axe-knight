class_name SummonShot extends Summon

var target: Node2D
var speed: float
var add: Vector2

func GetVelocity() -> Vector2:
    return (target.global_position - global_position).normalized() * speed + add