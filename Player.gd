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
	if !MAIN_PLAYER and MP_NEXT_STATE:
		state.set_angular_velocity(MP_NEXT_STATE['state'].get_angular_velocity())
		self.translation = MP_NEXT_STATE['position']
	if !camera:
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
	var angvel = state.get_angular_velocity()
	var tangvel = (angvel+ang)
	if tangvel.length()>=TERMINAL_VELOCITY or Input.is_action_pressed('dbgSpeed'):
		tangvel = tangvel.normalized()*TERMINAL_VELOCITY
	var brake = 1-Input.get_action_strength("brake")*0.5
	state.set_angular_velocity(tangvel*brake)
	#print('force ',tangvel)
	if !Global.SINGLEPLAYER:
		if MAIN_PLAYER:
			rpc_unreliable('update_player_global',{'state':state,'position':self.translation})

func update_player(playerdata):
	if !MAIN_PLAYER: #sanity check
		MP_NEXT_STATE = playerdata
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#debug thing for fun
	if Input.is_action_pressed("debugCollect"):
		blueCollectablesCollected+=10000


