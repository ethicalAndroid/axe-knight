class_name KnightAnimator extends AnimationPlayer

@export var sprite: Sprite2D
@export var v_speed_margin: float

var turn: bool = false
var state: State = State.Idle
var vertical: float

enum State {
    Idle, Run, Airborne, Dash, Slide, Slash, Hurt, Slam
}

func TransitionTo(next: State):
    if (next == state):
        return
    state = next

    sprite.rotation = 0
    sprite.flip_v = false

    stop()
    clear_queue()
    queue("RESET")
    InternalTransition(next, false)

func SetDashDirection(direction: Vector2):
    if state == State.Dash || state == State.Slash:
        var angle = Vector2.RIGHT.angle_to(direction)
        sprite.rotation = angle
        sprite.flip_v = direction.x < 0
                
func InternalTransition(next: State, do_play: bool):
    var anim_name: StringName = GetStateName(next)
    if do_play:
        play(anim_name)
    else:
        queue(anim_name)

func GetStateName(next: State) -> StringName:
    match next:
        State.Run:
            return "run"
        State.Idle:
            return "idle"
        State.Dash:
            return "dash"
        State.Slide:
            return "slide"
        State.Slash:
            return "slash"
        State.Hurt:
            return "hurt"
        State.Slam:
            return "slam"
        State.Airborne:
            if (vertical > v_speed_margin):
                return "jump_down"
            elif (vertical > -v_speed_margin):
                return "jump_middle"
            else:
                return "jump_up"
    return "RESET"

func SetDirection(speed: float):
    if state == State.Slash:
        return
    turn = speed < 0

func SetVSpeed(v_speed: float):
    vertical = v_speed
    if (state == State.Airborne):
        InternalTransition(state, true)

func _process(_delta: float) -> void:
    if state == State.Dash || state == State.Slash:
        sprite.flip_h = false
    else:
        sprite.flip_h = turn
