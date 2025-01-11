extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var mousePosition = Vector2(0,0)

var hookActive = false
var hookPos
var maxRopeLength = 100
var currentRopeLength = 0

func inputManagement():
	mousePosition = get_global_mouse_position()
	
func _process(delta: float) -> void:
	inputManagement()
	

func _physics_process(delta: float) -> void:
	#something about safely accessing space https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
	var space_state = get_world_2d().direct_space_state
	hookUpdate(delta)
	velocity *= 0.95
	move_and_slide()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	
func hookUpdate(delta):
	$Raycast/RayCast01.look_at(mousePosition)
	if Input.is_action_just_pressed("left_click"):
		if $Raycast/RayCast01.is_colliding():
			hookActive = true
	if Input.is_action_just_released("left_click"):
		hookActive = false
	if hookActive:
		#know where the hook is
		hookPos = getHookPos()
		#apply velocity based on grapple physics
		var radius = global_position - hookPos
		if velocity.length() < 0.01 or radius.length() < 10: return
		var angle = acos((radius.dot(velocity) / (radius.length() * velocity.length())))
		var rad_vel = cos(angle) * velocity.length()
		velocity += radius.normalized() * -rad_vel
		
		if global_position.distance_to(hookPos) > currentRopeLength:
			global_position = hookPos + radius.normalized() * currentRopeLength
			
		velocity +- (hookPos - global_position).normalized() * 15000 * delta
		#draw the hook

	else:
		return
		#destroy hook
func getHookPos():
	if $Raycast/RayCast01.is_colliding():
		return $Raycast/RayCast01.get_collision_point()
