extends Spatial

var position_on_screen
var collected_by_player
var collected = false
export var invisible = false
export var bounce = true
var bounceTime = 0
export var bouncePointIndex = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	$Collectable.visible=!invisible
	var point
#	if bouncePointIndex == 0:
#
#	else:
	for bp in get_tree().get_nodes_in_group('bouncePoint'):
		if bp.pointIndex==bouncePointIndex:
			point=bp.translation
			break
	if not point:
		point = Vector3.ZERO
	bounceTime=-self.translation.distance_to(point)/8


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if bounce:
		bounceTime+=delta*2
		bounceTime=fmod(bounceTime,1)
		var t = Vector3(0,abs(sin(bounceTime*PI))/2,0)
		$Collectable.translation=t
		$Collectable/Area.translation=-t
	if Global.MANUAL_BILLBOARD:
		var dir = Global.current_camera.rotation#self.translation.direction_to(Global.current_camera.translation)
		self.rotation=dir#look_at(self.translation-dir,Global.current_camera.upVector)


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
