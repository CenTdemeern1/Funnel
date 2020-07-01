extends Spatial

var position_on_screen
var collected_by_player
var collected = false
export var invisible = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Collectable.visible=!invisible


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	if body.is_in_group('Player'):
		position_on_screen = get_viewport().get_camera().unproject_position(self.transform.origin)
		$Collectable/Area.collision_layer = 0
		$Collectable/Area.collision_mask = 0
		$Collectable.visible=false
		$Sprite.visible=true
		$Sprite.position = position_on_screen
		var tween = get_node("Tween")
		tween.interpolate_property($Sprite, "position",
				$Sprite.position, Vector2(32, 32), 0.25,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		tween.interpolate_property($Sprite, "scale",
				$Sprite.scale, $Sprite.scale*0.5, 0.25,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		collected_by_player = body
		collected = true
		if !Global.SINGLEPLAYER:
			pass


func _on_Tween_tween_all_completed():
	collected_by_player.blueCollectablesCollected += 1
	if Global.SINGLEPLAYER:
		self.queue_free()
	else:
		self.visible=false
