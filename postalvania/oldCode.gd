extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const gravityConstant = 700
var mousePosition = Vector2(0,0)
var isJumping = false

var hookEnabled = true
var hookActive = false
var hookPos
var maxRopeLength = 500
var currentRopeLength = 0
var rad_vel
var radius

var glideEnabled = true
var isGliding = false
var maxGlideSpeed = 300

func inputManagement():
	mousePosition = get_global_mouse_position()
	
func _process(delta: float) -> void:
	inputManagement()
	if isGliding:
		if Input.is_action_just_released("ui_accept"):
			isGliding = false
	print(global_position)

	# Add the gravity.
func gravity(delta):
	if not is_on_floor():
		if isGliding:
			velocity.y += gravityConstant*delta*0.1
			print("gliding")
		else:
			print("normal gravity")
			velocity.y += gravityConstant * delta
func glide():
	isGliding = true
	if velocity.y > 0 && abs(velocity.x) < maxGlideSpeed:
		if velocity.x != 0:
			velocity.x += abs(velocity.y/2)*velocity.x/abs(velocity.x)
			print("add glide speed")
		else:
			isGliding = false

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
		isJumping = true
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("ui_accept"):
		isJumping = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if Input.is_action_just_pressed("ui_left"):
		$AnimatedSprite2D.scale.x = -abs($AnimatedSprite2D.scale.x)
	elif Input.is_action_just_pressed("ui_right"):
		$AnimatedSprite2D.scale.x = abs($AnimatedSprite2D.scale.x)
	if direction:
		if hookActive:
			$AnimatedSprite2D.look_at(hookPos)
			$AnimatedSprite2D.rotate(PI/2)
			if direction > 0:
				velocity += radius.normalized().rotated(-PI/2) * -rad_vel/1000 * SPEED
				
			elif direction < 0:
				velocity += radius.normalized().rotated(PI/2) * -rad_vel/1000 * SPEED
			velocity += (hookPos - global_position).normalized() * 10000 * delta
		else:
			$AnimatedSprite2D.rotation = 0
			if is_on_floor():
				velocity.x = move_toward(velocity.x, SPEED*direction, 200)
				isGliding = false
			elif isGliding == false:
				velocity.x = move_toward(velocity.x, SPEED*direction, 50)
	elif is_on_floor():
		$AnimatedSprite2D.rotation = 0
		velocity.x = move_toward(velocity.x, 0, SPEED)
	elif hookActive:
		$AnimatedSprite2D.look_at(hookPos)
		$AnimatedSprite2D.rotate(PI/2)
	else:
		
		if Input.is_action_pressed("ui_accept") && glideEnabled && is_on_floor() == false && isJumping == false:
			glide()
		else:
			#move towards velocity of 0 at a rate of 1. giga slow decay. AKA keep your momentum when not toucing keyboard or on ground
			velocity.x = move_toward(velocity.x, 0, 1)

		

	move_and_slide()
	
func hookUpdate(delta):
	$RayCast01.look_at(mousePosition)
	if Input.is_action_just_pressed("left_click"):
		hookPos = getHookPos()
		if hookPos:
			hookActive = true
			currentRopeLength = global_position.distance_to(hookPos)
		if $RayCast01.is_colliding():
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


	else:
		return
		#destroy hook
func getHookPos():
	if $RayCast01.is_colliding():
		return $RayCast01.get_collision_point()
	else:
		print("couldnt find raycast collision")
