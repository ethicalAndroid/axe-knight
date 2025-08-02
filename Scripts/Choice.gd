class_name Choice extends Control

@export var direction: Vector2
@export var charge_max: float = 1
@export var gradient: Gradient
@export var sprite: CanvasItem

var charge: float
var sent: bool = false

const MARGIN = 0.8

signal choice_made()

func Reset():
    sent = false
    charge = 0
    sprite.modulate = gradient.sample(0)

func _process(delta: float) -> void:
    var input = Input.get_vector("Left", "Right", "Up", "Down")
    if input && direction.dot(input) > MARGIN:
        charge = min(charge + delta, charge_max)
        if !sent && charge >= charge_max:
            choice_made.emit()
            sent = true
    else:
        charge = 0

    sprite.modulate = gradient.sample(inverse_lerp(0, charge_max, charge))