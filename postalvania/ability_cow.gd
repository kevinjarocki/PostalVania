extends Area2D
var abilityEnable = "placeholder"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	abilityEnable = $".".name
	print(abilityEnable)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func _on_body_entered(body: Node2D) -> void:
	body.enableAbility(abilityEnable)
	$AnimatedSprite2D.play("Idle")
