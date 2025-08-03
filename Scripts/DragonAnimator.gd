class_name DragonAnimator extends AnimationPlayer

@export var flip: Node2D

func SetDirection(x_aim: float):
    if x_aim:
        flip.scale.x = sign(x_aim)

func AnimationEnded(animation: StringName):
    if animation == "RESET":
        return
    StartAnimation("idle")

func StartAnimation(animation: StringName):
    stop()
    clear_queue()
    queue("RESET")
    queue(animation)