extends Area2D

@export var follow_parent_facing: bool = false
@export var sprite_path: NodePath = NodePath("../Sprite2D") # adjust if needed

var _base_scale_x: float = 1.0
@onready var _sprite: Sprite2D = null

func _ready() -> void:
	add_to_group("enemy_hitbox")

	_base_scale_x = abs(scale.x)

	if follow_parent_facing:
		_sprite = get_node_or_null(sprite_path) as Sprite2D
		if _sprite == null:
			# fallback: try to find Sprite2D anywhere under the parent
			_sprite = get_parent().get_node_or_null("Sprite2D") as Sprite2D

func _process(_delta: float) -> void:
	if not follow_parent_facing:
		return
	if _sprite == null:
		return

	# Your horse flips by sprite.scale.x = -1/1
	var facing_sign := -1.0 if _sprite.scale.x < 0.0 else 1.0
	scale.x = _base_scale_x * facing_sign

func TakeDamage() -> void:
	get_parent().TakeDamage()
