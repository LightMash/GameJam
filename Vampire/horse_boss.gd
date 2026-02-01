# HorseBoss.gd
class_name HorseBoss
extends CharacterBody2D

# -------------------------
# Target / AI
# -------------------------
@export var target_group: StringName = &"player"

@export var move_speed: float = 90.0
@export var move_accel: float = 900.0

@export var preferred_range: float = 120.0
@export var too_close_range: float = 60.0
@export var melee_range: float = 55.0

# Backoff / Charge
@export var backoff_speed: float = 140.0
@export var charge_speed: float = 320.0
@export var charge_accel: float = 1400.0
@export var charge_cooldown: float = 1.6

# Melee
@export var melee_cooldown: float = 0.9

# Prediction for charge windup
@export var prediction_time: float = 0.18

# -------------------------
# Scene references (set these in Inspector if your node names differ)
# -------------------------
@export var state_machine_path: NodePath = NodePath("StateMachine")
@export var animation_player_path: NodePath = NodePath("AnimationPlayer")
@export var sprite_path: NodePath = NodePath("Sprite2D")
@export var health_path: NodePath = NodePath("Health")

# These should be Area2D nodes (optional)
@export var melee_hitbox_path: NodePath = NodePath("MeleeHitbox")      # enabled during melee active window
@export var charge_hitbox_path: NodePath = NodePath("ChargeHitbox")    # enabled during charge (optional)
@export var attack_hitbox_path: NodePath = NodePath("")               # if you have an Area2D that hits the player (optional)

# -------------------------
# Runtime
# -------------------------
var target: Node2D = null

var charge_force_end: bool = false
var _charge_active: bool = false
var _melee_active: bool = false

var _charge_target_pos: Vector2 = Vector2.ZERO
var _has_charge_target: bool = false

var _charge_cd_left: float = 0.0
var _melee_cd_left: float = 0.0

var _last_target_pos: Vector2 = Vector2.ZERO
var _target_vel_est: Vector2 = Vector2.ZERO

@onready var state_machine: BossStateMachine = get_node_or_null(state_machine_path) as BossStateMachine
@onready var anim: AnimationPlayer = get_node_or_null(animation_player_path) as AnimationPlayer
@onready var sprite: Sprite2D = get_node_or_null(sprite_path) as Sprite2D
@onready var health: Health = get_node_or_null(health_path) as Health

@onready var melee_hitbox: Area2D = get_node_or_null(melee_hitbox_path) as Area2D
@onready var charge_hitbox: Area2D = get_node_or_null(charge_hitbox_path) as Area2D
@onready var attack_hitbox: Area2D = get_node_or_null(attack_hitbox_path) as Area2D

func _ready() -> void:
	_refresh_target(true)

	# Init state machine (your BossStateMachine expects this)
	if state_machine:
		state_machine.Initialize(self)

	# Health hookup (uses your health.gd)
	if health and not health.Died.is_connected(_on_died):
		health.Died.connect(_on_died)

	# Start with hitboxes off
	set_melee_active(false)
	set_charge_active(false)

	# Optional: if you have a boss attack hitbox that should damage the player,
	# connect it here (it should detect Area2D in group "player_hitbox").
	if attack_hitbox and not attack_hitbox.area_entered.is_connected(_on_attack_hitbox_area_entered):
		attack_hitbox.area_entered.connect(_on_attack_hitbox_area_entered)

func _process(delta: float) -> void:
	_refresh_target(false)
	_update_cooldowns(delta)
	_update_target_velocity_estimate(delta)

	if state_machine:
		state_machine.Update(delta)

func _physics_process(delta: float) -> void:
	if state_machine:
		state_machine.PhysicsUpdate(delta)

	move_and_slide()

	# If charging and you hit something solid, request early end
	if _charge_active and get_slide_collision_count() > 0:
		for i in range(get_slide_collision_count()):
			var col := get_slide_collision(i)
			var collider := col.get_collider()
			# Don’t auto-end on the player; end on walls/props/etc.
			if collider != null and collider != target:
				charge_force_end = true
				break

# -------------------------
# Damage API (this is what your player expects to call)
# -------------------------
func TakeDamage() -> void:
	if health:
		health.TakeDamage(1)
	else:
		# fallback if you forgot the Health node
		queue_free()
		return
	_flash()

func _on_died() -> void:
	velocity = Vector2.ZERO
	queue_free()

func _flash() -> void:
	if sprite == null:
		return
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.3, 0.08)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.08)
	tween.tween_property(sprite, "modulate:a", 0.3, 0.08)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.08)

# -------------------------
# Target helpers (used by states)
# -------------------------
func has_target() -> bool:
	return is_instance_valid(target)

func distance_to_target() -> float:
	if not has_target():
		return INF
	return global_position.distance_to(target.global_position)

func dir_to_target() -> Vector2:
	if not has_target():
		return Vector2.ZERO
	return global_position.direction_to(target.global_position)

func predicted_target_pos() -> Vector2:
	if not has_target():
		return global_position
	return target.global_position + _target_vel_est * prediction_time

func _refresh_target(force: bool) -> void:
	if force or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group(target_group) as Node2D
		if is_instance_valid(target):
			_last_target_pos = target.global_position
			_target_vel_est = Vector2.ZERO

func _update_target_velocity_estimate(delta: float) -> void:
	if not has_target() or delta <= 0.0:
		return

	# If target is a CharacterBody2D, use its real velocity if available
	if target is CharacterBody2D:
		_target_vel_est = (target as CharacterBody2D).velocity
		_last_target_pos = target.global_position
		return

	# Otherwise estimate velocity from position change
	var now_pos := target.global_position
	_target_vel_est = (now_pos - _last_target_pos) / delta
	_last_target_pos = now_pos

# -------------------------
# Cooldowns (used by states)
# -------------------------
func _update_cooldowns(delta: float) -> void:
	_charge_cd_left = maxf(0.0, _charge_cd_left - delta)
	_melee_cd_left = maxf(0.0, _melee_cd_left - delta)

func charge_ready() -> bool:
	return _charge_cd_left <= 0.0

func melee_ready() -> bool:
	return _melee_cd_left <= 0.0

func start_charge_cooldown() -> void:
	_charge_cd_left = charge_cooldown

func start_melee_cooldown() -> void:
	_melee_cd_left = melee_cooldown

# -------------------------
# Charge target helpers (used by windup/charge states)
# -------------------------
func set_charge_target(pos: Vector2) -> void:
	_charge_target_pos = pos
	_has_charge_target = true

func get_charge_direction() -> Vector2:
	if _has_charge_target:
		var v := _charge_target_pos - global_position
		if v.length_squared() > 0.0001:
			return v.normalized()
	return dir_to_target()

func clear_end_charge_request() -> void:
	charge_force_end = false

# -------------------------
# Movement helpers (used by states)
# -------------------------
func stop_motion() -> void:
	velocity = Vector2.ZERO

func steer_toward(desired: Vector2, delta: float, accel: float = -1.0) -> void:
	var a := move_accel if accel < 0.0 else accel
	velocity = velocity.move_toward(desired, a * delta)

func desired_keep_distance_velocity() -> Vector2:
	if not has_target():
		return Vector2.ZERO

	var d := distance_to_target()
	var dir := dir_to_target()

	if d < preferred_range * 0.85:
		return (-dir) * backoff_speed
	if d > preferred_range * 1.15:
		return dir * move_speed
	return Vector2.ZERO

# -------------------------
# Hitbox enable/disable (used by states)
# -------------------------
func set_melee_active(active: bool) -> void:
	_melee_active = active
	if melee_hitbox:
		# If you use CollisionShape2D under the Area2D
		for c in melee_hitbox.get_children():
			if c is CollisionShape2D:
				(c as CollisionShape2D).disabled = not active

func set_charge_active(active: bool) -> void:
	_charge_active = active
	if charge_hitbox:
		for c in charge_hitbox.get_children():
			if c is CollisionShape2D:
				(c as CollisionShape2D).disabled = not active

# -------------------------
# Animation helpers (used by states)
# -------------------------
func pause_anim() -> void:
	if anim:
		anim.pause()

func play_move_anim(v: Vector2) -> void:
	if anim == null or sprite == null:
		return

	# Flip for left/right
	if absf(v.x) > 0.001:
		sprite.scale.x = -1 if v.x < 0.0 else 1

	var name := _dir_anim_name("walk", v)
	_play_if_exists(name)

func play_attack_dash(v: Vector2) -> void:
	if anim == null or sprite == null:
		return

	if absf(v.x) > 0.001:
		sprite.scale.x = -1 if v.x < 0.0 else 1

	# Try common naming patterns
	_play_best([
		_dir_anim_name("dash", v),
		_dir_anim_name("attack_dash", v),
		"attack_dash",
		"dash",
	])

func play_attack_side(v: Vector2) -> void:
	if anim == null or sprite == null:
		return

	if absf(v.x) > 0.001:
		sprite.scale.x = -1 if v.x < 0.0 else 1

	_play_best([
		_dir_anim_name("attack", v),
		_dir_anim_name("attack_side", v),
		"attack",
		"melee",
	])

func _dir_anim_name(prefix: String, v: Vector2) -> String:
	# returns like "walk_down", "walk_up", "walk_side"
	if absf(v.x) > absf(v.y):
		return prefix + "_side"
	return prefix + ("_down" if v.y > 0.0 else "_up")

func _play_best(candidates: Array[String]) -> void:
	for anim_name in candidates:
		if anim.has_animation(anim_name):
			if anim.current_animation != anim_name:
				anim.play(anim_name)
			return

func _play_if_exists(anim_name: String) -> void:
	if anim.has_animation(anim_name):
		if anim.current_animation != anim_name:
			anim.play(anim_name)


func _on_charge_hurtbox_area_entered(_area: Area2D) -> void:
	if _charge_active:
		charge_force_end = true

func _on_charge_hurtbox_body_entered(_body: Node) -> void:
	if _charge_active:
		charge_force_end = true


# -------------------------
# OPTIONAL: boss damaging player (same pattern as monster.gd)
# -------------------------
func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		area.TakeDamage()

# If you connect charge_hitbox collisions to these, it can also end charge on impact:
func _on_charge_hitbox_body_entered(_body: Node) -> void:
	if _charge_active:
		charge_force_end = true

func _on_charge_hitbox_area_entered(_area: Area2D) -> void:
	if _charge_active:
		charge_force_end = true
