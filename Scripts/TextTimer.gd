class_name TextTimer extends RichTextLabel

@export var lifetime: float
@export var gradient: Gradient
@export var shake: float
@export var shake_curve: Curve

var time: float

signal timeout()

func _ready() -> void:
    time = lifetime

func _process(delta: float) -> void:
    time = max(time - delta, 0)
    text = "%.2f" % time
    
    var t = inverse_lerp(lifetime, 0, time)
    modulate = gradient.sample(t)
    var s = shake_curve.sample(t) * shake
    position = Vector2(randf_range(-s, s), randf_range(-s, s))
    
    if (time == 0):
        position = Vector2.ZERO
        process_mode = PROCESS_MODE_DISABLED
        timeout.emit()