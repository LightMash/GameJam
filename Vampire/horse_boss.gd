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
# Damage
# -------------------------
@export var melee_damage: int = 1
@export var charge_damage: int = 3

# If your hitboxes are NOT children of the sprite, they won't auto-flip.
# Keep this ON unless you already flip the Hitboxes node somewhere else.
@export var mirror_hitboxes_with_sprite: bool = true
@export var hitboxes_root_path: NodePath = NodePath("Hitboxes")

# -------------------------
# Scene references (set these in Inspector if your node names differ)
# -------------------------
@export var state_machine_path: NodePath = NodePath("StateMachine")
@export var animation_player_path: NodePath = NodePath("AnimationPlayer")
@export var sprite_path: NodePath = NodePath("Sprite2D")
@export var health_path: NodePath = NodePath("Health")

# IMPORTANT: default paths that match your scene screenshot
@export var melee_hitbox_path: NodePath = NodePath("Hitboxes/MeleeHurtBox")
@export var charge_hitbox_path: NodePath = NodePath("Hitboxes/ChargeHurtbox")
@export var attack_hitbox_path: NodePath = NodePath("") # optional

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

# Prevent multi-hits in a single charge/melee window
var _charge_hit_done: bool = false
var _melee_hit_done: bool = false

var _hitboxes_base_scale_x: float = 1.0

@onready var state_machine: BossStateMachine = get_node_or_null(state_machine_path) as BossStateMachine
@onready var anim: AnimationPlayer = get_node_or_null(animation_player_path) as AnimationPlayer
@onready var sprite: Sprite2D = get_node_or_null(sprite_path) as Sprite2D
@onready var health: Health = get_node_or_null(health_path) as Health

@onready var hitboxes_root: Node2D = get_node_or_null(hitboxes_root_path) as Node2D
@onready var melee_hitbox: Area2D = get_node_or_null(melee_hitbox_path) as Area2D
@onready var charge_hitbox: Area2D = get_node_or_null(charge_hitbox_path) as Area2D
@onready var attack_hitbox: Area2D = get_node_or_null(attack_hitbox_path) as Area2D

func _ready() -> void:
	_refresh_target(true)

	if state_machine:
		state_machine.Initialize(self)

	if health and not health.Died.is_connected(_on_died):
		health.Died.connect(_on_died)

	# fallback resolve if paths were not set
	if melee_hitbox == null:
		melee_hitbox = get_node_or_null("Hitboxes/MeleeHurtBox") as Area2D
	if charge_hitbox == null:
		charge_hitbox = get_node_or_null("Hitboxes/ChargeHurtbox") as Area2D

	if hitboxes_root == null:
		hitboxes_root = get_node_or_null("Hitboxes") as Node2D
	if hitboxes_root:
		_hitboxes_base_scale_x = absf(hitboxes_root.scale.x)

	# Start with hitboxes off
	set_melee_active(false)
	set_charge_active(false)

	# Connect hitboxes to damage player
	if melee_hitbox and not melee_hitbox.area_entered.is_connected(_on_melee_hitbox_area_entered):
		melee_hitbox.area_entered.connect(_on_melee_hitbox_area_entered)

	if charge_hitbox and not charge_hitbox.area_entered.is_connected(_on_charge_hitbox_area_entered):
		charge_hitbox.area_entered.connect(_on_charge_hitbox_area_entered)

	# Optional: generic attack hitbox (if you use one)
	if attack_hitbox and not attack_hitbox.area_entered.is_connected(_on_attack_hitbox_area_entered):
		attack_hitbox.area_entered.connect(_on_attack_hitbox_area_entered)

func _process(delta: float) -> void:
	_refresh_target(false)
	_update_cooldowns(delta)
	_update_target_velocity_estimate(delta)

	if mirror_hitboxes_with_sprite:
		_update_hitboxes_facing()

	if state_machine:
		state_machine.Update(delta)

func _physics_process(delta: float) -> void:
	if state_machine:
		state_machine.PhysicsUpdate(delta)

	move_and_slide()

	# Backup: if Area2D signal doesn't fire, still apply charge damage when overlapping
	if _charge_active and not _charge_hit_done and charge_hitbox:
		for a in charge_hitbox.get_overlapping_areas():
			if a is Area2D:
				_handle_charge_contact(a as Area2D)
				if _charge_hit_done:
					break

	# If charging and you hit something solid, request early end
	if _charge_active and get_slide_collision_count() > 0:
		for i in range(get_slide_collision_count()):
			var col := get_slide_collision(i)
			var collider := col.get_collider()
			if collider != null and collider != target:
				charge_force_end = true
				break

func _update_hitboxes_facing() -> void:
	if hitboxes_root == null or sprite == null:
		return
	var s := -1.0 if sprite.scale.x < 0.0 else 1.0
	hitboxes_root.scale.x = _hitboxes_base_scale_x * s

# -------------------------
# Damage API (player hitting boss)
# -------------------------
func TakeDamage() -> void:
	if health:
		health.TakeDamage(1)
	else:
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
	if target is CharacterBody2D:
		_target_vel_est = (target as CharacterBody2D).velocity
		_last_target_pos = target.global_position
		return
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
	var just_enabled := active and not _melee_active
	_melee_active = active

	if just_enabled:
		_melee_hit_done = false

	if melee_hitbox:
		melee_hitbox.monitoring = active
		melee_hitbox.monitorable = active
		for c in melee_hitbox.get_children():
			if c is CollisionShape2D:
				(c as CollisionShape2D).disabled = not active

		# If enabled while already overlapping, apply once
		if just_enabled:
			for a in melee_hitbox.get_overlapping_areas():
				if a is Area2D:
					_handle_melee_contact(a as Area2D)
					if _melee_hit_done:
						break

func set_charge_active(active: bool) -> void:
	var just_enabled := active and not _charge_active
	_charge_active = active

	if just_enabled:
		_charge_hit_done = false

	if charge_hitbox:
		charge_hitbox.monitoring = active
		charge_hitbox.monitorable = active
		for c in charge_hitbox.get_children():
			if c is CollisionShape2D:
				(c as CollisionShape2D).disabled = not active

		# If enabled while already overlapping, apply once
		if just_enabled:
			for a in charge_hitbox.get_overlapping_areas():
				if a is Area2D:
					_handle_charge_contact(a as Area2D)
					if _charge_hit_done:
						break

# -------------------------
# Animation helpers (used by states)
# -------------------------
func pause_anim() -> void:
	if anim:
		anim.pause()

func play_move_anim(v: Vector2) -> void:
	if anim == null or sprite == null:
		return
	if absf(v.x) > 0.001:
		sprite.scale.x = -1 if v.x < 0.0 else 1
	var nm := _dir_anim_name("walk", v)
	_play_if_exists(nm)

func play_attack_dash(v: Vector2) -> void:
	if anim == null or sprite == null:
		return
	if absf(v.x) > 0.001:
		sprite.scale.x = -1 if v.x < 0.0 else 1
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

# -------------------------
# Boss -> Player damage
# -------------------------
func _deal_damage_to_player(player_area: Area2D, amount: int) -> void:
	if not player_area.is_in_group("player_hitbox"):
		return

	# Most projects put TakeDamage() on the player hitbox Area2D (like your monster does)
	if player_area.has_method("TakeDamage"):
		for i in range(amount):
			player_area.TakeDamage()
		return

	# Fallback: climb to parent that has TakeDamage()
	var n: Node = player_area
	while n != null and not n.has_method("TakeDamage"):
		n = n.get_parent()
	if n != null:
		for i in range(amount):
			n.call("TakeDamage")

func _handle_melee_contact(area: Area2D) -> void:
	if not _melee_active or _melee_hit_done:
		return
	if not area.is_in_group("player_hitbox"):
		return
	_melee_hit_done = true
	_deal_damage_to_player(area, melee_damage)

func _handle_charge_contact(area: Area2D) -> void:
	if not _charge_active or _charge_hit_done:
		return
	if not area.is_in_group("player_hitbox"):
		return
	_charge_hit_done = true
	_deal_damage_to_player(area, charge_damage)
	charge_force_end = true

# These names cover whatever your scene connections currently use
func _on_melee_hitbox_area_entered(area: Area2D) -> void:
	_handle_melee_contact(area)

func _on_charge_hitbox_area_entered(area: Area2D) -> void:
	_handle_charge_contact(area)

func _on_charge_hurtbox_area_entered(area: Area2D) -> void:
	_handle_charge_contact(area)

func _on_charge_hurtbox_body_entered(_body: Node) -> void:
	if _charge_active:
		charge_force_end = true

func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	# If you ever use attack_hitbox_path, keep it 1 damage
	if area.is_in_group("player_hitbox"):
		_deal_damage_to_player(area, 1)
