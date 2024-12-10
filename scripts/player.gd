extends CharacterBody3D
@onready var dashCooldownTimer: Timer = $DashCooldownTimer

var current_speed = 10.0
var lerp_speed = 10
var direction = Vector3.ZERO
var extraVelocity = Vector3.ZERO
@export var dash_count = 1
@export var dash_cooldown = 1.0
@export var dash_strength = 25.0
@export var dash_count_max = 3

const JUMP_VELOCITY = 4.5
const walk_speed = 5.0
const sprint_speed = 50.0

@onready var pivot: Node3D = $CamOrigin
@export var sens = 0.5

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	dashCooldownTimer.wait_time = dash_cooldown

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))

func _on_timer_timeout() -> void:
	
	#When dash timer runs out, add a 'dash charge' to dash_count
	if dash_count < dash_count_max:
		dash_count += 1
		dashCooldownTimer.start()
	
	#print_debug(dash_count)
	#ADD some kind of feedback to the player to know when they have charged the dash

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	
	if Input.is_action_just_pressed("sprint") and dash_count > 0:
		dash_count -= 1
		dashCooldownTimer.start()
		
		if !input_dir:
			input_dir = Vector2(0,-1)
		if velocity.y < 0:
			velocity.y = 0
		extraVelocity += (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()*dash_strength
	
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	velocity += extraVelocity
	
	extraVelocity = lerp( extraVelocity, Vector3.ZERO, 0.1)
	
	move_and_slide()
