class_name MonsterWalkState
extends MonsterState

@onready var anim: AnimationPlayer = $"../../AnimationPlayer"
@onready var sprite: Sprite2D = $"../../Sprite2D"

func Physics(_delta: float) -> MonsterState:
	# Movement is handled by monster.gd on the Monster root.
	# Here we ONLY play the right walk animation based on current velocity.
	if monster == null:
		monster = get_parent().get_parent() as CharacterBody2D
		if monster == null:
			return null

	var v := monster.velocity
	if v.length_squared() > 1.0:
		_play_walk_anim(v)
	return null

func _play_walk_anim(v: Vector2) -> void:
	if absf(v.x) > absf(v.y):
		if anim.current_animation != "walk_side":
			anim.play("walk_side")
		sprite.scale.x = -1 if v.x < 0.0 else 1
	else:
		var anim_name := "walk_down" if v.y > 0.0 else "walk_up"
		if anim.current_animation != anim_name:
			anim.play(anim_name)
