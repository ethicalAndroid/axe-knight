class_name ClearedOnBonk extends Bonked

func OnHit(_direction: Vector2, _melee: bool):
    queue_free()