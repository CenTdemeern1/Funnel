extends RigidBody

const BASE_TERMINAL_VELOCITY = 6
var TERMINAL_VELOCITY = 6
export(NodePath) var camera# = ''
var blueCollectablesCollected = 0
var levelCollectibleAmount = 0
const mPSPerOrb = 0.1
var MAIN_PLAYER = true
var MP_NEXT_STATE
onready var INITIAL_POSITION = self.transform
var BOUNCE = false
var BOUNCE_POINT
var BOOST_PAD = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass#get_tree().get_nodes_in_group('Collectable')

func _integrate_forces(state):
	if Input.is_action_just_pressed("soft_restart"):
		state.set_angular_velocity(Vector3.ZERO)
		state.set_linear_velocity(Vector3.ZERO)
		state.set_transform(INITIAL_POSITION)
		self.transform=INITIAL_POSITION
		BOUNCE=false
	if !MAIN_PLAYER:
		for player in get_tree().get_nodes_in_group('Player'):
			self.add_collision_exception_with(player)
	if !MAIN_PLAYER and MP_NEXT_STATE:
		state.set_angular_velocity(MP_NEXT_STATE['angvel'])
		self.translation = MP_NEXT_STATE['position']
	if !camera or !MAIN_PLAYER:
		return
	if BOUNCE:
		BOUNCE=false
		var v = state.get_linear_velocity().bounce((BOUNCE_POINT-self.translation).normalized())
		state.set_linear_velocity(v)
	TERMINAL_VELOCITY = BASE_TERMINAL_VELOCITY + blueCollectablesCollected*mPSPerOrb
	var cameraObject = get_node(camera)
	var cameraDirection = cameraObject.get_global_transform().basis#cameraObject.translation.direction_to(self.translation)
	#print(cameraDirection)
	var forward = Input.get_action_strength("forward")*-cameraDirection[0]
	var back = Input.get_action_strength("back")*cameraDirection[0]
	var left = Input.get_action_strength("left")*cameraDirection[2]
	var right = Input.get_action_strength("right")*-cameraDirection[2]
	var ang = forward+back+left+right#Vector3(forward-back,0,right-left)*0.5
	var EFFECTIVE_TERMINAL_VELOCITY = 0
	var effective_ang = 0
	if BOOST_PAD:
		effective_ang = ang*2
		EFFECTIVE_TERMINAL_VELOCITY=TERMINAL_VELOCITY*2
	else:
		effective_ang = ang
		EFFECTIVE_TERMINAL_VELOCITY=TERMINAL_VELOCITY
	var angvel = state.get_angular_velocity()
	var tangvel = (angvel+effective_ang)
	if tangvel.length()>=EFFECTIVE_TERMINAL_VELOCITY or Input.is_action_pressed('dbgSpeed'):
		tangvel = tangvel.normalized()*EFFECTIVE_TERMINAL_VELOCITY
	var brake = 1-Input.get_action_strength("brake")*0.5
	var angularvel = tangvel*brake
	state.set_angular_velocity(angularvel)
	#print('force ',tangvel)
	if !Global.SINGLEPLAYER:
		if MAIN_PLAYER:
			#print(self.name,' main')
			rpc_unreliable('update_player',{'state':state,'position':self.translation,'angvel':angularvel})#_global

remote func update_player(playerdata):
	if !MAIN_PLAYER: #sanity check
		MP_NEXT_STATE = playerdata
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$CanvasLayer/Label.text=self.name
	var cam = get_viewport().get_camera()
	var pos = cam.unproject_position(self.translation+Vector3(0,1.5,0))
	pos-=$CanvasLayer/Label.rect_size*$CanvasLayer/Label.rect_scale*0.5
	$CanvasLayer/Label.rect_position=pos
	#debug thing for fun
	if Input.is_action_pressed("debugCollect"):
		blueCollectablesCollected+=10000




func _on_nametag_camera_entered(camera):
	$CanvasLayer/Label.visible=true


func _on_nametag_camera_exited(camera):
	$CanvasLayer/Label.visible=false
