class_name DPerson extends Node2D

@export var sprite: Sprite2D
@export var bounce: AnimationPlayer
@export var sprites: Array[Texture]
@export var voices: Array[AudioStream]
@export var audio: AudioStreamPlayer

func Talk(frame: DFrame):
    ShowSprite(frame.sprite)
    bounce.queue("bounce")
    audio.stream = voices[frame.sprite]
    audio.play()

func ShowSprite(talk_sprite: Dialogue.TalkSprite):
    sprite.texture = sprites[talk_sprite]