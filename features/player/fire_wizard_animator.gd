class_name FireWizardAnimator
extends Node

const TEXTURE_PATH    := "res://assets/art/characters/fire_wizard_idle.png"
const DL_TEXTURE_PATH := "res://assets/art/characters/fire_wizard_down_left.png"

# Static direction sprite sheet (3×3 grid, 256×256 per cell)
const FRAME_W := 256
const FRAME_H := 256

# Animated down-left sheet (4×4 grid, 256×256 per cell, 16 frames)
const DL_COLS       := 4
const DL_ROWS       := 4
const DL_FRAME_W    := 256
const DL_FRAME_H    := 256
const DL_FPS        := 8.0

const SCALE := 0.5

# Static poses: [anim_name, row, col] from fire_wizard_idle.png
const ANIM_DEFS := [
	["idle_down",       0, 0],
	["idle_down_right", 0, 1],
	["idle_right",      0, 2],
	["idle_up_right",   1, 0],
	["idle_up",         1, 1],
	["idle_up_left",    2, 0],
	["idle_left",       2, 1],
]

const PI8 := PI / 8.0

var _sprite: AnimatedSprite2D = null
var _player: Node2D = null
var _wants_visible: bool = false

func _ready() -> void:
	_player = get_parent() as Node2D
	_build_sprite()

func _build_sprite() -> void:
	var texture := load(TEXTURE_PATH) as Texture2D
	if texture == null:
		push_error("FireWizardAnimator: missing " + TEXTURE_PATH)
		return
	var dl_texture := load(DL_TEXTURE_PATH) as Texture2D
	if dl_texture == null:
		push_error("FireWizardAnimator: missing " + DL_TEXTURE_PATH)
		return

	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = _build_frames(texture, dl_texture)
	_sprite.scale = Vector2(SCALE, SCALE)
	_sprite.z_index = 2
	_sprite.visible = _wants_visible
	_sprite.play("idle_down")
	_player.call_deferred("add_child", _sprite)

func _build_frames(texture: Texture2D, dl_texture: Texture2D) -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.remove_animation("default")

	# Static 1-frame poses
	for def in ANIM_DEFS:
		var anim_name: String = def[0]
		var row: int = def[1]
		var col: int = def[2]
		sf.add_animation(anim_name)
		sf.set_animation_loop(anim_name, false)
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(col * FRAME_W, row * FRAME_H, FRAME_W, FRAME_H)
		sf.add_frame(anim_name, atlas)

	# Animated down-left — 16 frames from 4×4 sheet
	sf.add_animation("idle_down_left")
	sf.set_animation_loop("idle_down_left", true)
	sf.set_animation_speed("idle_down_left", DL_FPS)
	for row in DL_ROWS:
		for col in DL_COLS:
			var atlas := AtlasTexture.new()
			atlas.atlas = dl_texture
			atlas.region = Rect2(col * DL_FRAME_W, row * DL_FRAME_H, DL_FRAME_W, DL_FRAME_H)
			sf.add_frame("idle_down_left", atlas)

	return sf

func _process(_delta: float) -> void:
	if _sprite == null or not _sprite.visible:
		return
	_update_direction()

func _update_direction() -> void:
	var angle := (_player.get_global_mouse_position() - _player.global_position).angle()
	var anim: String

	if angle >= -PI8 and angle < PI8:
		anim = "idle_right"
	elif angle >= PI8 and angle < 3.0 * PI8:
		anim = "idle_down_right"
	elif angle >= 3.0 * PI8 and angle < 5.0 * PI8:
		anim = "idle_down"
	elif angle >= 5.0 * PI8 and angle < 7.0 * PI8:
		anim = "idle_down_left"
	elif angle >= 7.0 * PI8 or angle < -7.0 * PI8:
		anim = "idle_left"
	elif angle >= -7.0 * PI8 and angle < -5.0 * PI8:
		anim = "idle_up_left"
	elif angle >= -5.0 * PI8 and angle < -3.0 * PI8:
		anim = "idle_up"
	else:
		anim = "idle_up_right"

	if _sprite.animation != anim:
		_sprite.flip_h = false
		_sprite.play(anim)

func activate() -> void:
	_wants_visible = true
	if _sprite:
		_sprite.show()

func deactivate() -> void:
	_wants_visible = false
	if _sprite:
		_sprite.hide()
