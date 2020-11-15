tool
extends Control

const EmptyTexture = preload("../../icons/empty.png")

signal load_pressed
signal clear_pressed


onready var _label = $Label
onready var _texture_rect = $TextureRect


func set_label(text: String):
	_label.text = text


func set_texture(tex: Texture):
	if tex == null:
		_texture_rect.texture = EmptyTexture
	else:
		_texture_rect.texture = tex


func _on_LoadButton_pressed():
	emit_signal("load_pressed")


func _on_ClearButton_pressed():
	emit_signal("clear_pressed")
