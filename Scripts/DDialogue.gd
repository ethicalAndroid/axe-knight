class_name DDialogue extends Control

enum TalkSprite {
	Normal, Happy, Serious, Confused, Yap1, Yap2
}

@export var text: RichTextLabel
@export var mage: DPerson
@export var knight: DPerson
@export var transition: AnimationPlayer

var i: int = 0
var block: DBlock
var loading: bool

signal done()

func AnimationEnded(animation: StringName):
	if animation == "intro":
		loading = false
		Next()
	elif animation == "outro":
		done.emit()

func Finish():
	transition.queue("outro")
	block = null

func StartJson(json: JSON):
	var data_received = json.data
	var created_block = DBlock.new()
	created_block.frames = [] as Array[DFrame]

	for x: Dictionary in data_received:
		var frame = DFrame.new()
		frame.sprite = TalkSprite.get(x.get("sprite"))
		frame.is_knight = x.get("char").strip_edges() == "K"
		frame.text = x.get("text")
		created_block.frames.append(frame)

	created_block.mage_start = TalkSprite.Normal
	created_block.knight_start = TalkSprite.Normal
	StartBlock(created_block)


func StartBlock(given_block: DBlock):
	i = 0
	loading = true
	block = given_block
	mage.ShowSprite(TalkSprite.Normal)
	knight.ShowSprite(TalkSprite.Normal)
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
	if !loading && Input.is_action_just_pressed("Continue"):
		Next()
