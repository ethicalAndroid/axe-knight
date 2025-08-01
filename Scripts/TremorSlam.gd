class_name TremorSlam extends Node2D

@export var y_pos: float
@export var spacing: float
@export var count: int
@export var timer: Timer
@export var tremor: PackedScene

var index: int = 0
var x_pos: float

func StartTremors():
    index = 0
    x_pos = global_position.x
    NextTremor()

func NextTremor():
    if index >= count:
        return

    CreateTremor(Vector2(x_pos + spacing * (index + 1), y_pos))
    CreateTremor(Vector2(x_pos - spacing * (index + 1), y_pos))

    index += 1
    timer.start()
    
func CreateTremor(pos: Vector2):
    var spawn: Node2D = tremor.instantiate()
    get_node(Projectile.ROOT_PARENT).add_child(spawn)
    spawn.global_position = pos
