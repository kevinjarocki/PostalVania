extends CharacterBody2D

# all global variable declarations
const SPEED = 400.0
const JUMP_VELOCITY = -550.0
const gravityConstant = 750
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
var oldIsYeeting = false

var cutsceneActive = false

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
var hookEnabled = false
var hookIsReady = false
var hookActive = false
var hookPos
var maxRopeLength = 500
var currentRopeLength = 0
var rad_vel
var radius

#gliding Variables
var glideEnabled = false
var glideIsReady = false
var maxGlideSpeed = 600
var stallSpeed = 200

#dash variables
var dashEnabled = false
var dashIsReady = false
var dashVelocity = 400

#slide variables
var slideEnabled = false
var slideIsReady = false
var slideSpeed = 0

#yeet variables
var yeetEnabled = false
var yeetIsReady = false
var yeetSpeed = 300

#coyote variables
var coyoteTime = false

#main.gd variables
var frozen = false
var main
var hookProgBar
var dashProgBar
var slideProgBar
var yeetProgBar
var glideProgBar

func _ready() -> void:
	main = $".."
	hookProgBar = $"../Player/Control/HBoxContainer/hook"
	dashProgBar = $"../Player/Control/HBoxContainer/dash"
	slideProgBar = $"../Player/Control/HBoxContainer/slide"
	yeetProgBar = $"../Player/Control/HBoxContainer/yeet"
	glideProgBar = $"../Player/Control/HBoxContainer/glide"
	
	#hookProgBar.color = Color.DARK_RED

func _process(delta: float) -> void:
	$RayCast01.look_at(get_global_mouse_position())
	if Input.is_action_pressed("1"):
		#CHEAT MODE
		enableAbility("hook")
		enableAbility("yeet")
		enableAbility("dash")
		enableAbility("slide")
		enableAbility("glide")
		
	#print($AnimatedSprite2D/slide.animation)
	#print(isSliding)
		
	hookProgBar.value = 100 - ($hookTimer.time_left / $hookTimer.wait_time) * 100
	dashProgBar.value = 100 - ($dashTimer.time_left / $dashTimer.wait_time) * 100
	slideProgBar.value = 100 - ($slideTimer.time_left / $slideTimer.wait_time) * 100
	yeetProgBar.value = 100 - ($yeetTimer.time_left / $yeetTimer.wait_time) * 100
	glideProgBar.value = 100 - ($glideTimer.time_left / $glideTimer.wait_time) * 100
	
func _physics_process(delta: float) -> void:
	var space_state = get_world_2d().direct_space_state
	QueryInputs()
	
	################################### GROUNDED GROUNDED
	
	if isGrounded:
		#animation control
		if direction != 0:
			$AnimatedSprite2D.scale.x = direction * abs($AnimatedSprite2D.scale.x)
			$AnimatedSprite2D.play("Walk")
			$AnimatedSprite2D/glider.play("Walk")
			$AnimatedSprite2D/hook.play("Walk")
			$AnimatedSprite2D/slide.play("Walk")
		else:
			$AnimatedSprite2D.play("Idle")
			$AnimatedSprite2D/glider.play("Idle")
			$AnimatedSprite2D/hook.play("Idle")
			$AnimatedSprite2D/slide.play("Idle")
		#physics
		velocity.x = move_toward(velocity.x, SPEED*direction, 200)
		#transitions out of state

		if spaceHeld:
			isGrounded = false
			isJumping = true
		elif shiftJustPressed && dashEnabled && dashIsReady:
			isDashing = true
			isGrounded = false
		elif cntrlJustPressed && slideEnabled && slideIsReady:
			isGrounded = false
			isSliding = true
		elif is_on_floor() == false && coyoteTime == false:
			coyoteTime = true
			$coyoteTime.start()
			
		######################   SLIDING SLIDING
	if isSliding:
		$slideTimer.start()
		slideIsReady = false
		if oldIsSliding != isSliding:
			slideSpeed = velocity.x*1.5 + SPEED*sign(velocity.x)
			$AnimatedSprite2D/slide.play("Slide")
			$AnimatedSprite2D.play("Slide")
			print($AnimatedSprite2D.animation)
			print("animate pls")
		if cntrlHeld:
			velocity.x = slideSpeed

		if !is_on_floor():
			isInAir = true
			isSliding = false
		if spaceJustPressed:
			isSliding = false
			isJumping = true
		elif clickJustPressed && hookEnabled && hookIsReady:
			isSliding = false
			isSwinging = true
		elif cntrlJustReleased:
			isSliding = false
			if is_on_floor():
				isGrounded = true
			else:
				isInAir = true
			
	oldIsSliding = isSliding
	####################################JUMPING JUMPING
	if isJumping:
		
		#animation control
		if direction != 0:
			$AnimatedSprite2D.scale.x = direction * abs($AnimatedSprite2D.scale.x)
		if spaceJustPressed:
			velocity.y = JUMP_VELOCITY
		#maintaining air control on ascent
		if abs(velocity.x) > SPEED/2:
			if direction * sign(velocity.x) < 1:
				velocity.x = move_toward(velocity.x, SPEED*direction/2, 60)
		else:
			velocity.x = move_toward(velocity.x, SPEED*direction/2, 30)
		#transitions out of state
		if velocity.y > 0:
			isJumping = false
			isInAir = true
		if spaceJustReleased:
			velocity.y = move_toward(velocity.y,0,200)
			isJumping = false
			isInAir = true
		################################################## IN AIR IN AIR
	if isInAir:
		#animation control
		$AnimatedSprite2D.play("Idle")
		$AnimatedSprite2D/glider.play("Idle")
		$AnimatedSprite2D/hook.play("Idle")
		$AnimatedSprite2D/slide.play("Idle")
		if velocity.x > 0:
			$AnimatedSprite2D.scale.x = abs($AnimatedSprite2D.scale.x)
		if velocity.x < 0:
			$AnimatedSprite2D.scale.x = -abs($AnimatedSprite2D.scale.x)
		if velocity.y > stallSpeed:
			var fallAngle = 0
			if $AnimatedSprite2D.scale.x > 0:
				fallAngle = move_toward(0,PI,1)
				$AnimatedSprite2D.rotation = fallAngle
			if $AnimatedSprite2D.scale.x < 0:
				fallAngle = move_toward(0,-PI,1)
				$AnimatedSprite2D.rotation = fallAngle
		else:
			$AnimatedSprite2D.rotation = 0
		if direction != 0:
			$AnimatedSprite2D.scale.x = direction * abs($AnimatedSprite2D.scale.x)
			#keep your lateral movion if youre not pressing inputs. adds to flow of game. no air brakes
			if abs(velocity.x) > SPEED/2:
				if direction * sign(velocity.x) < 1:
					velocity.x = move_toward(velocity.x, SPEED*direction/2, 60)
			else:
				velocity.x = move_toward(velocity.x, SPEED*direction/2, 30)
			
		#state transitions
		if clickJustPressed && hookEnabled && hookIsReady:
			isInAir = false
			isSwinging = true
		elif spaceJustPressed && glideEnabled && glideIsReady:
			isInAir = false
			isGliding = true
		elif shiftJustPressed && dashEnabled && dashIsReady:
			isDashing = true
			isInAir = false
		elif is_on_floor():
			isInAir = false
			if cntrlHeld && slideEnabled:
				isSliding = true
			else:
				isGrounded = true
				
				
		################################## GLIDING GLIDING
	if isGliding:
		$glideTimer.start()
		glideIsReady = false
		var glideAngle = 0
		$AnimatedSprite2D/glider.visible = true 
		$AnimatedSprite2D/glider.play("Flap")
		if velocity.x > 0:
			$AnimatedSprite2D.scale.x = abs($AnimatedSprite2D.scale.x)
		if velocity.x < 0:
			$AnimatedSprite2D.scale.x = -abs($AnimatedSprite2D.scale.x)
		if $AnimatedSprite2D.scale.x > 0:
			glideAngle = move_toward(0,velocity.angle(),1)
			$AnimatedSprite2D.rotation = glideAngle
		if $AnimatedSprite2D.scale.x < 0:
			glideAngle = move_toward(0,-PI + velocity.angle(),1)
			$AnimatedSprite2D.rotation = glideAngle
		if velocity.y > 0 && abs(velocity.x) < maxGlideSpeed:
			if abs(velocity.x) != 0:
				velocity.x += abs(velocity.y/2)*velocity.x/abs(velocity.x)
			#elif abs(velocity.x) > maxGlideSpeed:
				#pass
			else:
				isGliding = false
				isInAir = true
		if abs(velocity.x) < stallSpeed:
			isGliding = false
			isInAir = true 
		if spaceJustReleased:
			isGliding = false
			isInAir = true
		if clickJustPressed && hookEnabled && hookIsReady:
			isGliding = false
			isSwinging = true
		if is_on_floor():
			isGrounded = true
			isGliding = false
		if isGliding == false:
			$AnimatedSprite2D/glider.stop()
		
		################################################## DASHING DASHING
		
	if isDashing:
		print("dash")
		$dashTimer.start()
		dashIsReady = false
		if !dashEnabled:
			return
		
		velocity.x += sign($AnimatedSprite2D.scale.x) * dashVelocity + velocity.x
		velocity.y = 0
		
		isDashing = false
		if is_on_floor():
			isGrounded = true
		elif clickJustPressed && hookEnabled && hookIsReady:
			isSwinging = true
		else:
			isInAir = true
			
			############################################# SWINGING SWINGING
			
	if isSwinging:
		$hookTimer.start()
		hookIsReady = false
		if clickJustPressed:
			$AnimatedSprite2D.play("Swing")
			$AnimatedSprite2D/hook.play("Swing")
			$AnimatedSprite2D/glider.play("Swing")
			$AnimatedSprite2D/slide.play("Swing")
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
			#the next line can be used to limit/remove massive reel
			#velocity += radius.normalized() * 40
			
			#draw the hook
			$Rope.visible = true
			$Rope.look_at(hookPos)
			$Rope.rotate(-PI/2)
			$Rope.region_rect = Rect2(Vector2(0,-100),Vector2(125,radius.length()/$Rope.scale.y))

			$AnimatedSprite2D.look_at(hookPos)
			$AnimatedSprite2D.rotate(PI/2)
			
		if clickJustReleased:
			hookActive = false
			$Rope.visible = false
			isSwinging = false
			isInAir = true
			
		if rightClickJustPressed && yeetEnabled && yeetIsReady:
			hookActive = false
			isSwinging = false
			isYeeting = true
			
		
		##########################################  YEETING YEETING
		
	if isYeeting:
		$yeetTimer.start()
		yeetIsReady = false
		var existingVel
#something weird happened here but it seems to be fine? causes huge exponential accel when yeeting but its fun at least. Used to use oldIsYeet to get speed at time of yeet and assign that as a variable and use the new var so speed doesnt go exponential but it was craching
		existingVel = velocity
	
		#I want to add something here to take existing momentum into account because yeeting while really fast acts as an airbrake rn
		velocity.x = existingVel.x + move_toward(0,-radius.normalized().x * yeetSpeed,50)
		velocity.y = existingVel.y + move_toward(0,-radius.normalized().y * yeetSpeed,50)
		
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
			


	oldIsYeeting = isYeeting
	if !frozen:
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
	if velocity.y < (terminalVelocity+30):
		if isGrounded||isInAir:
			#do gravity
			velocity.y += gravityConstant*delta
		elif isJumping:
			velocity.y += gravityConstant*delta*1.2
		elif isSwinging:
			velocity.y += gravityConstant*delta 
	if isGliding:
		#gravity problems do not have anything to do with this line
		velocity.y = move_toward(velocity.y,(maxGlideSpeed/velocity.x) + 5000*delta , 30)
		#print("glide gravity", (maxGlideSpeed/velocity.x) + 200*delta)
		# <- second term
		
func getHookPos():
	if $RayCast01.is_colliding():
		return $RayCast01.get_collision_point()
	else:
		print("couldnt find raycast collision")
		
		########################## Signals and Enable Methods #######################################
func enableAbility(abilityName):
	
		if abilityName == "hook" && !hookEnabled:
			morph()
			hookIsReady = true
			hookProgBar.visible = true
			hookEnabled = true
			main._dBox("You just got the HOOK ability! Point and click to swing on a terrain while in the air!")
			$AnimatedSprite2D/hook.visible = true
		elif abilityName == "yeet" && !yeetEnabled:
			morph()
			yeetEnabled = true
			yeetIsReady = true
			yeetProgBar.visible = true
			main._dBox("You just got the YEET ability! While swinging right click!")
		elif abilityName == "dash" && !dashEnabled:
			morph()
			dashEnabled = true
			dashIsReady = true
			dashProgBar.visible = true
			main._dBox("You just got the DASH ability! Press Shift for a quick speed boost!")
		elif abilityName == "slide" && !slideEnabled:
			morph()
			slideEnabled = true
			slideIsReady = true
			slideProgBar.visible = true
			main._dBox("You just got the SLIDE ability! Press ctrl just before landing to keep up your speed!")
			$AnimatedSprite2D/slide.visible = true
		elif abilityName == "glide" && !glideEnabled:
			morph()
			glideEnabled = true
			glideIsReady = true
			glideProgBar.visible = true
			$AnimatedSprite2D/glider.visible = true
			main._dBox("You just got the GLIDE ability! Hold space while in the air to traverse horizontally!")
		else:
			print("no ability name match found")
			
func morph():
	if !$Cacoon.is_playing():
		$Cacoon.visible = true
		$Cacoon.play("morph")


func _on_hook_timer_timeout() -> void:
	hookIsReady = true


func _on_glide_timer_timeout() -> void:
	glideIsReady = true


func _on_dash_timer_timeout() -> void:
	dashIsReady = true
	print("dash ready again")


func _on_slide_timer_timeout() -> void:
	slideIsReady = true


func _on_yeet_timer_timeout() -> void:
	yeetIsReady = true


func _on_coyote_time_timeout() -> void:
	coyoteTime = false
	isGrounded = false
	isInAir = true


func _on_cacoon_animation_finished() -> void:
		$cacoonParticles.emitting = true
		$Cacoon.visible = false
		cutsceneActive = false
		position.y += 50


func _on_cacoon_frame_changed() -> void:
	position .y += -2
	cutsceneActive = true
