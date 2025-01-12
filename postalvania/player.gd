extends CharacterBody2D

# all global variable declarations
const SPEED = 300.0
const JUMP_VELOCITY = -700.0
const gravityConstant = 650
var terminalVelocity = 600

#state Variables
var isGrounded = false
var isJumping = false
var isInAir = true
var isSwinging = false
var isGliding = false
var isDashing = false
var isSliding = false
var oldIsSliding = false
var isYeeting = false

#Input Variables
var mousePosition = Vector2(0,0)
var direction = 0
var spaceJustPressed = false
var spaceHeld = false
var spaceJustReleased = false
var clickJustPressed = false
var clickJustReleased = false
var clickHeld = false
var rightClickJustPressed = false
var rightClickJustReleased = false
var rightClickHeld = false
var shiftJustPressed = false
var shiftJustReleased = false
var shiftHeld = false
var cntrlJustPressed = false
var cntrlJustReleased = false
var cntrlHeld = false

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
var maxGlideSpeed = 600
var stallSpeed = 200

#dash variables
var dashEnabled = true
var dashVelocity = 1200

#slide variables
var slideSpeed = 0

#
var yeetSpeed = 1200

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
		if shiftJustPressed:
			isDashing = true
			isGrounded = false
		if cntrlJustPressed:
			isGrounded = false
			isSliding = true
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
			#keep your lateral movion if youre not pressing inputs. adds to flow of game. no air brakes
			if abs(velocity.x) > SPEED:
				if direction * sign(velocity.x) < 1:
					velocity.x = move_toward(velocity.x, SPEED*direction, 20)
			else:
				velocity.x = move_toward(velocity.x, SPEED*direction, 20)
		
			
		#state transitions
		if clickJustPressed:
			isInAir = false
			isSwinging = true
		if spaceJustPressed:
			isInAir = false
			isGliding = true
		if shiftJustPressed:
			isDashing = true
			isGrounded = false
		if is_on_floor():
			if cntrlHeld:
				isSliding = true
			else:
				isInAir = false
				isGrounded = true
		pass
	if isSliding:
		if !oldIsSliding:
			slideSpeed = velocity.x*2
			print("boost")
		if cntrlHeld:
			$AnimatedSprite2D.scale.y = 0.5
			velocity.x = slideSpeed
			print("still sliding")
			print(isGrounded)
		
		if !is_on_floor():
			isInAir = true
			isSliding = false
			$AnimatedSprite2D.scale.y = 1
		if spaceJustPressed:
			isSliding = false
			isJumping = true
			$AnimatedSprite2D.scale.y = 1
		elif clickJustPressed:
			isSliding = false
			isSwinging = true
			$AnimatedSprite2D.scale.y = 1
		elif cntrlJustReleased:
			isSliding = false
			$AnimatedSprite2D.scale.y = 1
			if is_on_floor():
				isGrounded = true
			else:isInAir = true
		else:
			isInAir = true
			$AnimatedSprite2D.scale.y = 1
		pass
	
	if isGliding:
		var glideAngle
		$AnimatedSprite2D/glider.visible = true 
		$AnimatedSprite2D/glider.play("flap")
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
		if clickJustPressed:
			isGliding = false
			isSwinging = true
		if isGliding == false:
			$AnimatedSprite2D/glider.stop()
			$AnimatedSprite2D/glider.visible = false
		pass
		
	if isDashing:
		if !dashEnabled:
			return
		
		velocity.x += $AnimatedSprite2D.scale.x * dashVelocity
		velocity.y = 0
		
		isDashing = false
		if is_on_floor():
			isGrounded = true
		elif clickJustPressed:
			isSwinging = true
		else:
			isInAir = true
			
	if isSwinging:
		#Hook Update to check if i can swing
		if clickJustPressed:
			hookPos = getHookPos()
			if hookPos:
				hookActive = true
				currentRopeLength = global_position.distance_to(hookPos)
			else:
				hookActive = false
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
				velocity += radius.normalized().rotated(-PI/2) * -rad_vel/(9000+500) * SPEED
				
			elif direction < 0:
				velocity += radius.normalized().rotated(PI/2) * -rad_vel/(9000+500) * SPEED
			
			#velocity += (hookPos - global_position).normalized() * 1000 * delta
			
			#draw the hook
			$Rope.visible = true
			$Rope.look_at(hookPos)
			$Rope.rotate(-PI/2)
			$Rope.region_rect = Rect2(Vector2(0,0),Vector2(125,radius.length()/$Rope.scale.y))

			$AnimatedSprite2D.look_at(hookPos)
			$AnimatedSprite2D.rotate(PI/2)
			
		if clickJustReleased:
			hookActive = false
			$Rope.visible = false
			isSwinging = false
			isInAir = true
			
		if rightClickJustPressed:
			hookActive = false
			isSwinging = false
			isYeeting = true
			
		
	if isYeeting:
		velocity = -radius.normalized() * yeetSpeed
		
		#updating radius
		radius = global_position - hookPos
		
		#Updating Hook Drawing
		$Rope.look_at(hookPos)
		$Rope.rotate(-PI/2)
		$Rope.region_rect = Rect2(Vector2(0,0),Vector2(125,radius.length()/$Rope.scale.y))
			
			
		var proximity = global_position - hookPos
		if proximity.length() < 30 || rightClickJustReleased:
			isYeeting = false
			$Rope.visible = false
			if is_on_floor():
				isGrounded = true
			else:
				isInAir = true
			

	oldIsSliding = isSliding
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
	rightClickJustPressed = Input.is_action_just_pressed("right_click")
	rightClickJustReleased = Input.is_action_just_released("right_click")
	rightClickHeld = Input.is_action_pressed("right_click")
	shiftJustPressed = Input.is_action_just_pressed("shift")
	shiftJustReleased = Input.is_action_just_released("shift")
	shiftHeld = Input.is_action_pressed("shift") 
	cntrlJustPressed = Input.is_action_just_pressed("control")
	cntrlJustReleased = Input.is_action_just_released("control")
	cntrlHeld = Input.is_action_pressed("control") 
#check direction
#check space
#check mousepos
#check click

func Gravity(delta):
	if velocity.y < terminalVelocity:
		if isGrounded||isInAir:
			#do gravity
			velocity.y += gravityConstant*delta
			pass
		if isJumping:
			velocity.y += gravityConstant*delta*0.8
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
