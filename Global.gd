extends Node

var playerType
var cameraType
var peer
var MULTIPLAYER_STARTED = false
var players = {}
var player_info = {}
var SINGLEPLAYER = true
var MANUAL_BILLBOARD = false
onready var current_camera = get_viewport().get_camera()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	MANUAL_BILLBOARD = VisualServer.get_video_adapter_vendor() == "ATI Technologies Inc."
	playerType = preload("res://Player.tscn")
	cameraType = preload("res://Camera.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_camera = get_viewport().get_camera()
	if Input.is_action_just_pressed("vr"):
		var arvr_interface = ARVRServer.find_interface("Native mobile")
		if get_viewport().arvr:
			if arvr_interface:
				get_viewport().arvr = false
				arvr_interface.uninitialize()
		else:
			if arvr_interface and arvr_interface.initialize():
				get_viewport().arvr = true
	if Input.is_action_just_pressed("restart"):
		Input.action_release("restart")
		get_tree().call_group("MainScene","free")
		get_node("/root").add_child(load("MainScene.tscn").instance())
	if Input.is_action_just_pressed("dbgMultiplayerServer"):
		start_multiplayer_server()
	if Input.is_action_just_pressed("dbgMultiplayerClient"):
		start_multiplayer_client('localhost')#'172.0.0.1')#

func start_multiplayer_server(port=41917,max_players=8):
	if not MULTIPLAYER_STARTED:
		start_multiplayer()
	peer = NetworkedMultiplayerENet.new()
	var err = peer.create_server(port, max_players)
	get_tree().network_peer = peer
	if err:
		print('Error starting server: ',err)
	else:
		print('Server Started! Running on port ',port,' with a maximum amount of ',max_players,' players.')

func start_multiplayer_client(server_ip,port=41917):
	if not MULTIPLAYER_STARTED:
		start_multiplayer()
	peer = NetworkedMultiplayerENet.new()
	var err = peer.create_client(server_ip, port)
	get_tree().network_peer = peer
	if err:
		print('Error starting client: ',err)
	else:
		print('Client Started! Targeting IP ',server_ip,' on port ',port,'.')

func start_multiplayer():
	get_tree().connect("network_peer_connected", self, "network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "network_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	MULTIPLAYER_STARTED = true

func _connected_ok():
	print('Connection to server successful!')
	Global.SINGLEPLAYER = false
#	var myID = get_tree().get_network_unique_id()
#	get_tree().current_scene.get_node("MPPlayers/Player").set_name(str(myID))
#	get_tree().current_scene.get_node("MPPlayers/"+str(myID)).set_network_master(myID)

func _connected_fail():
	print('Connection to server failed!')
	Global.SINGLEPLAYER = true

func _server_disconnected():
	print('Connection to server lost: You\'ve (probably) been kicked!')
	Global.SINGLEPLAYER = true

func network_peer_connected(id):
	print('Player ',id,' wants to connect! Performing sanity check.')
	if id<1:
		print('Sanity check failed!')
		peer.disconnect_peer(id)
		print('Invalid player ID ',id,' has been kicked.')
		return
	else:
		print('Sanity check success!')
	print('ID ',id,' connected!')
	rpc_id(id, "spawn_player", player_info)
	
remote func spawn_player(info):
	var id = get_tree().get_rpc_sender_id()
	players[id] = info
	var new_player = preload("res://Player.tscn").instance()
	new_player.MAIN_PLAYER = false
	new_player.set_name(str(id))
	new_player.set_network_master(id)
	get_tree().current_scene.get_node('MPPlayers').add_child(new_player,true)

func network_peer_disconnected(id):
	print('ID ',id,' disconnected!')

remote func update_player_global(playerdata):
	var id = get_tree().get_rpc_sender_id()
	get_tree().current_scene.get_node("MPPlayers/"+str(id)).update_player(playerdata)

func set_scene(scenePath=null,sceneObject=null):
	if scenePath:
		sceneObject = load(scenePath)
	var scene = sceneObject#.instance()
	print('Scene load OK: ',get_tree().change_scene_to(scene)==OK)

func set_scene_step_two():
	var setScene = get_tree().current_scene#scene#
	print(setScene.mapType)
	if setScene.mapType==0:
		return
	if setScene.mapType==1:
		var MPPlayers = setScene.get_node('MPPlayers')
		var MPCameras = setScene.get_node('MPCameras')
		var playerNode = playerType.instance()
		var id = get_tree().get_network_unique_id()
		playerNode.set_name(str(id))
		playerNode.set_network_master(id)
		MPPlayers.add_child(playerNode)
		var MPPlayerNode = MPPlayers.get_node(str(id))
		var playerStart = get_tree().get_nodes_in_group('PlayerStart')
		if len(playerStart)!=0:
			MPPlayerNode.translation=playerStart[0].translation
			MPPlayerNode.INITIAL_POSITION=MPPlayerNode.transform
		MPPlayerNode.blueCollectablesCollected = setScene.startWithBlueCollectibles
		var cameraNode = cameraType.instance()
		cameraNode.set_name(str(id))
		cameraNode.set_network_master(id)
		cameraNode.player = MPPlayerNode.get_path()
		MPCameras.add_child(cameraNode)
		var MPCameraNode = MPCameras.get_node(str(id))
		playerNode.camera = MPCameraNode.get_path()
		if len(playerStart)!=0:
			MPCameraNode.translation=playerStart[0].translation+Vector3(0,2,-3)
		setScene.get_node('UI').player=MPPlayerNode.get_path()
