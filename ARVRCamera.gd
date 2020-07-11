extends ARVRCamera

var upVector
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var normalCamera = get_parent().get_parent()
	var upVector = normalCamera.upVector
	#self.fov = normalCamera.fov
	get_parent().translation=Vector3(0,0,(normalCamera.fov-70)/(normalCamera.maxFOV-70)*9)
	#self.current=get_viewport().arvr
	if Global.SINGLEPLAYER:
		self.current=get_viewport().arvr
	else:
		self.current=(get_viewport().arvr) and (normalCamera.playerObject.get_name()==str(get_tree().get_network_unique_id()))#normalCamera.playerObject.MAIN_PLAYER#
