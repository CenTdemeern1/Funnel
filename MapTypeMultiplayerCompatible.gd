extends Spatial

const mapType = 1
export var startWithBlueCollectibles = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print('multiplayer type map ready fire')
	Global.set_scene_step_two()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
