
extends CharacterBody3D

@export var move_speed := 5.0
@export var jump_velocity := 5.0
@export var mouse_sensitivity := 0.003

@onready var camera_pivot: Node3D = $CameraPivot

var gravity := 9.8


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Rotate player left/right
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Rotate camera up/down
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)

		# Stop camera from flipping upside down
		camera_pivot.rotation.x = clamp(
			camera_pivot.rotation.x,
			deg_to_rad(-60),
			deg_to_rad(60)
		)

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if position.y < -8:
		position = Vector3(0,5,0);

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Movement
	var input_vector := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)


	var direction := Vector3(input_vector.x, 0, input_vector.y)

	direction = transform.basis * direction
	direction.y = 0
	direction = direction.normalized()
	if direction.length() > 0:
		direction = direction.normalized()

		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		# Smoothly stop
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	move_and_slide()
	for i in get_slide_collision_count():

		var collision := get_slide_collision(i)
		var body := collision.get_collider()
		if body is RigidBody3D:
			var push_direction := -collision.get_normal()
			push_direction.y = 0
			body.apply_central_force(push_direction * 50.0)
