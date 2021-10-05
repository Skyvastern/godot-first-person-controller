extends KinematicBody

# NodePaths
export(NodePath) var camera_path

# References
onready var camera = get_node(camera_path)

# Input Parameter
const MOUSE_SENSITIVITY = 0.1

# Movement
var velocity = Vector3.ZERO
var velocity_info = Vector3.ZERO
var current_vel = Vector3.ZERO
var dir = Vector3.ZERO
var snap = Vector3.ZERO

const SPEED = 10
const SPRINT_SPEED = 20
const ACCEL = 15.0

# Jump
const GRAVITY = -40.0
const JUMP_SPEED = 15
var jump_counter = 0
const AIR_ACCEL = 9.0



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



func _process(_delta):
	window_activity()



func _physics_process(delta):
	
	process_movement_inputs()
	process_jump(delta)
	process_movement(delta)



func process_movement_inputs():
	# Get the input directions
	dir = Vector3.ZERO
	
	if Input.is_action_pressed("forward"):
		dir -= global_transform.basis.z
	if Input.is_action_pressed("backward"):
		dir += global_transform.basis.z
	if Input.is_action_pressed("right"):
		dir += global_transform.basis.x
	if Input.is_action_pressed("left"):
		dir -= global_transform.basis.x
	
	# Normalizing the input directions
	dir = dir.normalized()


func process_jump(delta):
	# Apply gravity
	if is_on_floor():
		jump_counter = 0
		velocity.y = -0.01
	else:
		velocity.y += GRAVITY * delta
	
	# Jump
	if Input.is_action_just_pressed("jump") and jump_counter < 2:
		jump_counter += 1
		velocity.y = JUMP_SPEED
		snap = Vector3.ZERO
	else:
		snap = Vector3.DOWN


func process_movement(delta):
	# Set speed and target velocity
	var speed = 0
	speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED	
	
	var target_vel = dir * speed
	
	# Smooth out the player's movement
	var accel = ACCEL if is_on_floor() else AIR_ACCEL
	current_vel = current_vel.linear_interpolate(target_vel, accel * delta)
	
	# Finalize velocity and move the player
	velocity.x = current_vel.x
	velocity.z = current_vel.z
	
	velocity_info = move_and_slide_with_snap(velocity, snap, Vector3.UP, true, 4, deg2rad(45))



func _input(event):
	if event is InputEventMouseMotion:
		# Rotates the view vertically
		$CamRoot.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		$CamRoot.rotation_degrees.x = clamp($CamRoot.rotation_degrees.x, -75, 75)
		
		# Rotates the view horizontally
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))



# Close the Window
func window_activity():
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
