class_name Dialogue extends Control

enum TalkSprite {
    Normal, Happy, Serious, Confused, Yap1, Yap2
}

@export var text: RichTextLabel
@export var mage: DPerson
@export var knight: DPerson
@export var transition: AnimationPlayer

var i: int = 0
var block: DBlock

signal done()

func AnimationEnded(animation: StringName):
    if animation == "intro":
        Next()
    else:
        done.emit()

func Finish():
    transition.queue("outro")
    block = null

func StartBlock(given_block: DBlock):
    block = given_block
    mage.ShowSprite(block.mage_start)
    knight.ShowSprite(block.knight_start)
    text.text = ""
    transition.queue("intro")

func Next():
    if block == null:
        return
    if i >= block.frames.size():
        Finish()
        return

    var frame = block.frames[i]
    text.text = frame.text
    if (frame.is_knight):
        knight.Talk(frame)
    else:
        mage.Talk(frame)
    i += 1

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("Continue"):
        Next()