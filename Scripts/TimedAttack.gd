class_name TimedAttack extends ShapeCast2D

@export var direction: Vector2

func Attack():
    var collisions = get_collision_count()
    for i in collisions:
        if get_collider(i) != null:
            get_collider(i).call("OnHit", direction)

func Expire():
    queue_free()