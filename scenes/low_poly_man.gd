extends CharacterBody3D

@onready var spring_arm_pivot = $SpringArmPivot
@onready var spring_arm_3d = $SpringArmPivot/SpringArm3D
@onready var armature = $Armature
@onready var animation_tree = $AnimationTree
@onready var norm_cam = $SpringArmPivot/SpringArm3D/Camera3D
@onready var alt_cam = $"../../Camera3D"

@export var knockback_resistance: float

const SPEED = 5.0
const LERP_VAL = 0.15
const JUMP_VELOCITY = 4.5
const MOUSE_SENS = 0.005

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if Input.is_action_just_pressed("camera_switch"):
		if alt_cam.current:
			norm_cam.current = true
		else:
			alt_cam.current = true

	# optional: queue_free or destroy the node
	if event is InputEventMouseMotion:
		spring_arm_pivot.rotate_y(-event.relative.x * MOUSE_SENS)
		spring_arm_3d.rotate_x(-event.relative.y * MOUSE_SENS)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# rotate direction to match spring_arm_pivot (determined by the mouse movement)
	direction = direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)

	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED, LERP_VAL)
		velocity.z = lerp(velocity.z, direction.z * SPEED, LERP_VAL)
		# rotate armature (and mesh) smoothly to the direction the the LowPolyMain is actually travelling
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(-velocity.x, -velocity.z), LERP_VAL)
	else:
		velocity.x = lerp(velocity.x, 0.0, LERP_VAL)
		velocity.z = lerp(velocity.z, 0.0, LERP_VAL)
	# This sets the blend value of the BlendSpace1D in the animation tree to blend between idle and running
	animation_tree.set("parameters/BlendSpace1D/blend_position", velocity.length() / SPEED)
	move_and_slide()

func knockback(k: Knockback):
	print("doing knockback")
	velocity += (global_transform.origin - k.knockback_origin).normalized() * k.knockback_force
	velocity.y += k.knockback_force / knockback_resistance
