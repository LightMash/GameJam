extends Sprite2D   # THIS is the rolling dice sprite

@onready var roll_anim: AnimationPlayer = $AnimationPlayer
@onready var faces_parent: Node = $Sprite2D2   # final dice faces container

var last_day := -1
var dice_result := 1

func _ready():
	NightCycleManager.time_tick.connect(_on_time_tick)
	roll_anim.animation_finished.connect(_on_roll_finished)

	_show_face(1)

func _on_time_tick(day: int, hour: int, minute: int):
	if day != last_day:
		last_day = day
		start_dice_roll()

func start_dice_roll():
	dice_result = randi_range(1, 6)

	# hide FINAL face during roll
	faces_parent.visible = false

	# stop any previous face animation
	for ap in faces_parent.get_children():
		ap.stop()

	roll_anim.play("dice")

func _on_roll_finished(anim_name: String):
	if anim_name == "dice":
		faces_parent.visible = true
		_show_face(dice_result)

func _show_face(face: int):
	var ap_name = "animationplayer" + str(face)
	var face_anim: AnimationPlayer = faces_parent.get_node(ap_name)

	face_anim.play("default")
	face_anim.stop()
