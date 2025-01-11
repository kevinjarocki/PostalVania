extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const gravityConstant = 1000
var mousePosition = Vector2(0,0)

var hookActive = false
var hookPos
var maxRopeLength = 500
var currentRopeLength = 0
var rad_vel
var radius

func inputManagement():
	mousePosition = get_global_mouse_position()
	
func _process(delta: float) -> void:
	inputManagement()

	# Add the gravity.
func gravity(delta):
	if not is_on_floor():
		velocity.y += gravityConstant * delta

func _physics_process(delta: float) -> void:
	#something about safely accessing space https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
	var space_state = get_world_2d().direct_space_state
	hookUpdate(delta)
	gravity(delta)
	if hookActive:
		gravity(delta)
	#velocity decay on swing. must be near 1 or swinging feels artificially damped
	velocity *= 0.99
	move_and_slide()

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		if hookActive:
			if direction > 0:
				velocity += radius.normalized().rotated(-PI/2) * -rad_vel/1000 * SPEED
			elif direction < 0:
				velocity += radius.normalized().rotated(PI/2) * -rad_vel/1000 * SPEED
			velocity += (hookPos - global_position).normalized() * 10000 * delta
		else:
			if is_on_floor():
				velocity.x = move_toward(velocity.x, SPEED*direction, 200)
			else:
				velocity.x = move_toward(velocity.x, SPEED*direction, 50)
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		#move towards velocity of 0 at a rate of 1. giga slow decay. AKA keep your momentum when not toucing keyboard or on ground
		velocity.x = move_toward(velocity.x, 0, 1)
		

	move_and_slide()
	
func hookUpdate(delta):
	$Raycast/RayCast01.look_at(mousePosition)
	if Input.is_action_just_pressed("left_click"):
		hookPos = getHookPos()
		if hookPos:
			hookActive = true
			currentRopeLength = global_position.distance_to(hookPos)
		if $Raycast/RayCast01.is_colliding():
			pass
	if Input.is_action_just_released("left_click"):
		hookActive = false
		$Rope.visible = false
	if hookActive:
		#apply velocity based on grapple physics
		if hookPos:
			radius = global_position - hookPos
			if velocity.length() < 0.01 or radius.length() < 10: return
			var angle = acos((radius.dot(velocity) / (radius.length() * velocity.length())))
			rad_vel = cos(angle) * velocity.length()
			velocity += radius.normalized() * -rad_vel
				
			if global_position.distance_to(hookPos) > currentRopeLength:
				global_position = hookPos + radius.normalized() * currentRopeLength
			#when the line below had a typo, (+- instead of +=) we swung loose, no grappling in
			velocity +- (hookPos - global_position).normalized() * 10000 * delta
		#draw the hook
		$Rope.visible = true
		$Rope.look_at(hookPos)
		$Rope.rotate(-PI/2)
		$Rope.region_rect = Rect2(Vector2(0,0),Vector2(125,radius.length()/$Rope.scale.y))
		#$Rope.position.y = radius.length()/2

	else:
		return
		#destroy hook
func getHookPos():
	if $Raycast/RayCast01.is_colliding():
		return $Raycast/RayCast01.get_collision_point()
	else:
		print("couldnt find raycast collision")
