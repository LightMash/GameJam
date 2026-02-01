class_name HorseBoss
extends CharacterBody2D

@export var move_speed: float = 85.0
@export var backoff_speed: float = 105.0
@export var charge_speed: float = 260.0

# Smooth movement (main fix)
@export var move_accel: float = 900.0
@export var move_decel: float = 1100.0

# Charge smoothing
@export var charge_accel: float = 1600.0

# Spacing
@export var preferred_range: float = 180.0
@export var range_deadzone: float = 35.0 # Bigger = less clingy

# Orbiting when in the band (feels smart / less sticky)
@export var strafe_speed: float = 65.0
@export var strafe_switch_time: float = 2.2
@export var radial_correction: float = 0.55 # keeps him near preferred_range

# Attack ranges
@export var too_close_range: float = 95.0
@export var melee_range: float = 120.0

@export var melee_damage: int = 1
@export var charge_damage: int = 2

@export var melee_cooldown: float = 1.3
@export var charge_cooldown: float = 3.2

# “smart” aim
@export var lead_time: float = 0.28

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var state_machine: BossStateMachine = $StateMachine
@onready var health:  = $Health

@onready var melee_hitbox: Area2D = $Hitboxes/MeleeHitbox
@onready var charge_hitbox: Area2D = $Hitboxes/ChargeHitbox

var target: Player = null

var melee_cd_left: float = 0.0
var charge_cd_left: float = 0.0

var melee_active: bool = false
var charge_active: bool = false

var charge_force_end: bool = false
var charge_target: Vector2 = Vector2.ZERO

var last_face_dir: Vector2 = Vector2.RIGHT

# orbit direction: 1 or -1
var orbit_dir: int = 1
var orbit_timer: float = 0.0

func _ready() -> void:
	add_to_group("boss")
	_find_player()

	# connect hitboxes
	if melee_hitbox and not melee_hitbox.body_entered.is_connected(_on_melee_body_entered):
		melee_hitbox.body_entered.connect(_on_melee_body_entered)
	if charge_hitbox and not charge_hitbox.body_entered.is_connected(_on_charge_body_entered):
		charge_hitbox.body_entered.connect(_on_charge_body_entered)

	set_melee_active(false)
	set_charge_active(false)

	if health and not health.Died.is_connected(_on_died):
		health.Died.connect(_on_died)

	orbit_timer = strafe_switch_time

	state_machine.Initialize(self)

func _process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		_find_player()

	melee_cd_left = maxf(0.0, melee_cd_left - delta)
	charge_cd_left = maxf(0.0, charge_cd_left - delta)

	orbit_timer -= delta
	if orbit_timer <= 0.0:
		orbit_timer = strafe_switch_time
		orbit_dir *= -1

	state_machine.Update(delta)

func _physics_process(delta: float) -> void:
	state_machine.PhysicsUpdate(delta)

	# safety: if no target, smoothly stop
	if not has_target():
		steer_toward(Vector2.ZERO, delta)

	move_and_slide()

# ----------------------
# Target helpers
# ----------------------

func _find_player() -> void:
	target = get_tree().get_first_node_in_group("player") as Player

func has_target() -> bool:
	return target != null and is_instance_valid(target)

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
	return target.global_position + target.velocity * lead_time

# ----------------------
# Cooldowns
# ----------------------

func melee_ready() -> bool:
	return melee_cd_left <= 0.0

func charge_ready() -> bool:
	return charge_cd_left <= 0.0

func start_melee_cooldown() -> void:
	melee_cd_left = melee_cooldown

func start_charge_cooldown() -> void:
	charge_cd_left = charge_cooldown

# ----------------------
# Hitboxes
# ----------------------

func set_melee_active(active: bool) -> void:
	melee_active = active
	if melee_hitbox:
		melee_hitbox.monitoring = active

func set_charge_active(active: bool) -> void:
	charge_active = active
	if charge_hitbox:
		charge_hitbox.monitoring = active

func request_end_charge() -> void:
	charge_force_end = true

func clear_end_charge_request() -> void:
	charge_force_end = false

func set_charge_target(pos: Vector2) -> void:
	charge_target = pos

func get_charge_direction() -> Vector2:
	if charge_target == Vector2.ZERO:
		return dir_to_target()
	return global_position.direction_to(charge_target)

func _on_melee_body_entered(body: Node) -> void:
	if not melee_active:
		return

	var p: Player = body as Player
	if p == null:
		return

	# Player has its own TakeDamage() method
	for i in range(melee_damage):
		p.TakeDamage()


func _on_charge_body_entered(body: Node) -> void:
	if not charge_active:
		return

	var p: Player = body as Player
	if p == null:
		return

	# Player has its own TakeDamage() method
	for i in range(charge_damage):
		p.TakeDamage()

	request_end_charge()


func _on_died() -> void:
	queue_free()

# ----------------------
# Smooth movement (main fix)
# ----------------------

func steer_toward(desired_velocity: Vector2, delta: float, accel_override: float = -1.0) -> void:
	var accel := move_accel if accel_override < 0.0 else accel_override
	var decel := move_decel if accel_override < 0.0 else accel_override

	var rate := accel if desired_velocity.length() > velocity.length() else decel
	velocity = velocity.move_toward(desired_velocity, rate * delta)

func desired_keep_distance_velocity() -> Vector2:
	if not has_target():
		return Vector2.ZERO

	var to := dir_to_target()
	var d := distance_to_target()

	var inner := preferred_range - range_deadzone
	var outer := preferred_range + range_deadzone

	# Too far: approach
	if d > outer:
		return to * move_speed

	# Too close: retreat
	if d < inner:
		return (-to) * backoff_speed

	# In the band: orbit/strafe with a tiny radial correction
	var tangent := Vector2(-to.y, to.x) * float(orbit_dir)
	var radial_error := (d - preferred_range) / maxf(1.0, range_deadzone) # -1..1 in band
	var radial_push := to * (radial_error * move_speed * radial_correction)

	return tangent * strafe_speed + radial_push

# ----------------------
# Animation helpers
# ----------------------

func set_facing_from_vector(v: Vector2) -> void:
	if v.length_squared() < 0.0001:
		return
	last_face_dir = v
	if absf(v.x) >= absf(v.y):
		sprite_2d.scale.x = -1 if v.x < 0.0 else 1

func play_move_anim(v: Vector2) -> void:
	set_facing_from_vector(v)

	# no walk_up, so we just reuse walk_down for vertical
	var name := "walk_side" if absf(v.x) >= absf(v.y) else "walk_down"
	if anim.current_animation != name:
		anim.play(name)

func play_attack_side(v: Vector2) -> void:
	set_facing_from_vector(v)
	if anim.has_animation("attack_side"):
		anim.play("attack_side")

func play_attack_dash(v: Vector2) -> void:
	set_facing_from_vector(v)
	if anim.has_animation("attack_dash"):
		anim.play("attack_dash")

func pause_anim() -> void:
	if anim.is_playing():
		anim.pause()

func stop_motion() -> void:
	velocity = Vector2.ZERO


func _on_charge_hurtbox_area_entered(area: Area2D) -> void:
		if area.is_in_group("player_hitbox"):
			area.TakeDamage()
