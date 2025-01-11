extends CharacterBody2D

# all global variable declarations
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const gravityConstant = 900

#state Variables
var isGrounded = false
var isJumping = false
var isInAir = true
var isSwinging = false
var isGliding = false

#Input Variables
var mousePosition = Vector2(0,0)
var direction = 0
var spaceJustPressed = false
var spaceHeld = false
var spaceJustReleased = false
var clickJustPressed = false
var clickJustReleased = false
var clickHeld = false

#swinging variables
var hookEnabled = true
var hookActive = false
var hookPos
var maxRopeLength = 500
var currentRopeLength = 0
var rad_vel
var radius

#gliding Variables
var glideEnabled = true
var maxGlideSpeed = 300
var stallSpeed = 200

func _process(delta: float) -> void:
	$RayCast01.look_at(get_global_mouse_position())

func _physics_process(delta: float) -> void:
	var space_state = get_world_2d().direct_space_state
	QueryInputs()
	
	
	if isGrounded:
		#animation control
		if direction != 0:
			$AnimatedSprite2D.scale.x = direction * abs($AnimatedSprite2D.scale.x)
		
		#physics
		velocity.x = move_toward(velocity.x, SPEED*direction, 200)
		#transitions out of state
		if spaceJustPressed:
			isGrounded = false
			isJumping = true
		if is_on_floor() == false:
			isGrounded = false
			isInAir = true
		pass
		
	if isJumping:
		
		#animation control
		if direction != 0:
			$AnimatedSprite2D.scale.x = direction * abs($AnimatedSprite2D.scale.x)
		if spaceJustPressed:
			velocity.y = JUMP_VELOCITY
			print("Launch em")
		velocity.x = move_toward(velocity.x, SPEED*direction, 50)
		#transitions out of state
		if velocity.y > 0:
			isJumping = false
			isInAir = true
		if spaceJustReleased:
			isJumping = false
			isInAir = true
		
	if isInAir:
		#animation control
		if velocity.x > 0:
			$AnimatedSprite2D.scale.x = 1
		if velocity.x < 0:
			$AnimatedSprite2D.scale.x = -1
		if velocity.y > stallSpeed:
			var fallAngle
			if $AnimatedSprite2D.scale.x > 0:
				fallAngle = move_toward(0,PI,1)
				$AnimatedSprite2D.rotation = fallAngle + (PI/2)
			if $AnimatedSprite2D.scale.x < 0:
				fallAngle = move_toward(0,-PI,1)
				$AnimatedSprite2D.rotation = fallAngle + (-PI/2)
		else:
			$AnimatedSprite2D.rotation = 0
		if direction != 0:
			$AnimatedSprite2D.scale.x = direction * abs($AnimatedSprite2D.scale.x)
		velocity.x = move_toward(velocity.x, SPEED*direction, 50)
		#state transitions
		if clickJustPressed:
			isInAir = false
			isSwinging = true
		if spaceJustPressed:
			isInAir = false
			isGliding = true
		if is_on_floor():
			isInAir = false
			isGrounded = true
		pass
		
	if isSwinging:
		#Hook Update to check if i can swing
		
		if Input.is_action_just_pressed("left_click"):
			hookPos = getHookPos()
			if hookPos:
				hookActive = true
				currentRopeLength = global_position.distance_to(hookPos)
			else:
				hookActive = false
				isSwinging = false
				isInAir = true
		if Input.is_action_just_released("left_click"):
			hookActive = false
			$Rope.visible = false
			isSwinging = false
			isInAir = true
		Gravity(delta)
		if hookActive:
			Gravity(delta)
			#apply velocity based on grapple physics
			if hookPos:
				radius = global_position - hookPos
				if velocity.length() < 0.01 or radius.length() < 10: 
					isSwinging = false
					isInAir = true
					return
				var angle = acos((radius.dot(velocity) / (radius.length() * velocity.length())))
				rad_vel = cos(angle) * velocity.length()
				velocity += radius.normalized() * -rad_vel
					
				if global_position.distance_to(hookPos) > currentRopeLength:
					global_position = hookPos + radius.normalized() * currentRopeLength
				#when the line below had a typo, (+- instead of +=) we swung loose, no grappling in
				velocity += (hookPos - global_position).normalized() * 10000 * delta
			if direction > 0:
				velocity += radius.normalized().rotated(-PI/2) * -rad_vel/1000 * SPEED
				
			elif direction < 0:
				velocity += radius.normalized().rotated(PI/2) * -rad_vel/1000 * SPEED
			
			velocity +- (hookPos - global_position).normalized() * 10000 * delta
			
			#draw the hook
			$Rope.visible = true
			$Rope.look_at(hookPos)
			$Rope.rotate(-PI/2)
			$Rope.region_rect = Rect2(Vector2(0,0),Vector2(125,radius.length()/$Rope.scale.y))

			$AnimatedSprite2D.look_at(hookPos)
			$AnimatedSprite2D.rotate(PI/2)

	if isGliding:
		var glideAngle
		if velocity.x > 0:
			$AnimatedSprite2D.scale.x = 1
		if velocity.x < 0:
			$AnimatedSprite2D.scale.x = -1
		if $AnimatedSprite2D.scale.x > 0:
			glideAngle = move_toward(0,velocity.angle(),1)
			$AnimatedSprite2D.rotation = glideAngle + (PI/2)
		if $AnimatedSprite2D.scale.x < 0:
			glideAngle = move_toward(0,-velocity.angle(),1)
			$AnimatedSprite2D.rotation = glideAngle + (-PI/2)
		if velocity.y > 0 && abs(velocity.x) < maxGlideSpeed:
			if velocity.x != 0:
				velocity.x += abs(velocity.y/2)*velocity.x/abs(velocity.x)
				print("add glide speed")
			elif velocity.y > stallSpeed:
				velocity.x = $AnimatedSprite2D.scale.x * move_toward(0,SPEED,10)
			else:
				isGliding = false
				isInAir = true
		if spaceJustReleased:
			isGliding = false
			isInAir = true
		pass
	move_and_slide()
	Gravity(delta)
	
func QueryInputs():
	direction = Input.get_axis("ui_left", "ui_right")
	mousePosition = get_global_mouse_position()
	spaceJustPressed = Input.is_action_just_pressed("ui_accept")
	spaceHeld = Input.is_action_pressed("ui_accept")
	spaceJustReleased = Input.is_action_just_released("ui_accept")
	clickJustPressed = Input.is_action_just_pressed("left_click")
	clickJustReleased = Input.is_action_just_released("left_click")
	clickHeld = Input.is_action_pressed("left_click")
#check direction
#check space
#check mousepos
#check click

func Gravity(delta):
	if isGrounded||isInAir:
		#do gravity
		velocity.y += gravityConstant*delta
		pass
	if isJumping:
		velocity.y += gravityConstant*delta*0.5
		pass
	if isInAir:
		velocity.y += gravityConstant*delta
		pass
	if isSwinging:
		velocity.y += gravityConstant*delta
		pass
	if isGliding:
		velocity.y = move_toward(velocity.y, gravityConstant*0.1,10)
		pass
		
func getHookPos():
	if $RayCast01.is_colliding():
		return $RayCast01.get_collision_point()
	else:
		print("couldnt find raycast collision")
