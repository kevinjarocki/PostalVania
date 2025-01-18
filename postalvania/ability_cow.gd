extends Area2D
var abilityEnable = "placeholder"
@export var characterSprite:PackedScene
var animationInstance: AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load(characterSprite.resource_name)
	abilityEnable = $".".name
	print(abilityEnable)
	animationInstance = characterSprite.instantiate()
	add_child(animationInstance)

	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func _on_body_entered(body: Node2D) -> void:
	body.enableAbility(abilityEnable)
	animationInstance.play("Idle")
	$Timer.start()


func _on_timer_timeout() -> void:
	animationInstance.stop()
