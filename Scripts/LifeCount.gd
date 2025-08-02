class_name LifeCount extends Control

@export var life_tex: Texture
@export var dead_tex: Texture

@export var life_sprites: Array[TextureRect]

var i: int = 0

signal on_death()

func _ready() -> void:
	for x in life_sprites:
		x.texture = life_tex

func LoseLife():
	if i >= life_sprites.size():
		return
	life_sprites[i].texture = dead_tex
	i += 1
	if (i >= life_sprites.size()):
		on_death.emit()
