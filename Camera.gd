extends Camera

var centerBehindTimer = 0
const maxCenterBehind = 1
export(NodePath) var player
var previousPosition = Vector3(0,0,0)
const maxDistanceToPlayer = 4
var upVector = Vector3(0,1,0)
const moveAwayToNotClipPlayer = 2
const maxFOV = 139#179
onready var INITIAL_POSITION = self.transform
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("soft_restart"):
		self.transform=INITIAL_POSITION
	var playerObject = get_node(player)
	if Global.SINGLEPLAYER:
		self.current=!get_viewport().arvr
	else:
		self.current=(!get_viewport().arvr) and (playerObject.get_name()==str(get_tree().get_network_unique_id()))#playerObject.MAIN_PLAYER#
#		if self.current:
#			print(playerObject.get_name())
#	print(playerObject.get_name(),self.current,self.name,playerObject.get_name()==str(get_tree().get_network_unique_id()))
	
	var rotCamLeft = Input.get_action_strength("rotateCameraLeft")
	var rotCamRight = Input.get_action_strength("rotateCameraRight")
	var rotCamUp = Input.get_action_strength("rotateCameraUp")
	var rotCamDown = Input.get_action_strength("rotateCameraDown")
#	self.translation=playerObject.translation.direction_to(self.translation).rotated(Vector3(0,1,0),45)*self.translation.distance_to(playerObject.translation)
	
	if self.translation.distance_to(playerObject.translation)>maxDistanceToPlayer:
		var distanceToMove = self.translation.distance_to(playerObject.translation)-maxDistanceToPlayer
		self.translation+=self.translation.direction_to(playerObject.translation+Vector3(0,1,0))*distanceToMove
	var lookAt = playerObject.translation
	#print(self.translation.direction_to(lookAt).normalized())
	var normDir = lookAt.direction_to(self.translation).normalized()
	if normDir==upVector or normDir.length()==0:
		self.translation+=Vector3(0,2,-3)
	self.look_at(lookAt,upVector)#playerObject.translation
	self.rotation+=Vector3((rotCamUp-rotCamDown)*.5,(rotCamLeft-rotCamRight)*.5,0)
	if self.translation.distance_to(playerObject.translation)<=moveAwayToNotClipPlayer:
		var distanceFromPlayer=self.translation.distance_to(playerObject.translation)
		self.translation+=self.translation.direction_to(playerObject.translation).normalized()*(distanceFromPlayer-moveAwayToNotClipPlayer)
	if previousPosition!=self.translation:
		centerBehindTimer=0
	else:
		centerBehindTimer+=delta
		if centerBehindTimer>=maxCenterBehind:
			centerBehindTimer=maxCenterBehind
			centerBehindPlayer()
	var targetFOV = 70+(self.translation-previousPosition).length()*200
	if abs(targetFOV-self.fov)>=1:
		var fFOV = self.fov+sign(targetFOV-self.fov)*.5
		#fFOV = sqrt(fFOV)
		self.fov = min(maxFOV,fFOV)
	previousPosition=self.translation

func centerBehindPlayer():
	pass
