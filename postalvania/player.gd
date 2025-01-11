extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const gravityConstant = 1000
var mousePosition = Vector2(0,0)

var hookActive = false
var hookPos
var maxRopeLength = 500
var currentRopeLength = 0

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
	velocity *= 0.99
	move_and_slide()

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, 1)

	move_and_slide()
	
func draw():
	var pos = global_position
	
	if hookActive:
		print("draw me")
		draw_line(Vector2(0,-6), to_local(hookPos), Color(0.3,0.3,0.1),10, false)
	else:
		return
		
		var colliding = $Raycast/RayCast01.is_colliding()
		var collisionPoint = $Raycast/RayCast01.get_collision_point()
		if colliding and pos.distance_to(collisionPoint) < maxRopeLength:
			draw_line(Vector2(0,-6), to_local(collisionPoint), Color(1,1,1,0.25),0.5,true)
	
func hookUpdate(delta):
	$Raycast/RayCast01.look_at(mousePosition)
	if Input.is_action_just_pressed("left_click"):
		hookPos = getHookPos()
		print("click")
		if hookPos:
			print("hookPos is real")
			hookActive = true
			currentRopeLength = global_position.distance_to(hookPos)
		if $Raycast/RayCast01.is_colliding():
			print("Commence Hook")
	if Input.is_action_just_released("left_click"):
		hookActive = false
	if hookActive:
		draw()
		print("Hook is active")
		#know where the hook is


		#apply velocity based on grapple physics
		if hookPos:
			print("hookPos does exist")
			var radius = global_position - hookPos
			if velocity.length() < 0.01 or radius.length() < 10: return
			var angle = acos((radius.dot(velocity) / (radius.length() * velocity.length())))
			var rad_vel = cos(angle) * velocity.length()
			velocity += radius.normalized() * -rad_vel
				
			if global_position.distance_to(hookPos) > currentRopeLength:
				global_position = hookPos + radius.normalized() * currentRopeLength
				
			velocity +- (hookPos - global_position).normalized() * 10000 * delta
		#draw the hook

	else:
		return
		#destroy hook
func getHookPos():
	if $Raycast/RayCast01.is_colliding():
		return $Raycast/RayCast01.get_collision_point()
	else:
		print("couldnt find raycast collision")
