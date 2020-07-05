extends Spatial

var bumpAnimation = -1
#var bodies = []
#var bodytimers = []
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass#connect("body_entered",self,"_on_RoundPinBallBumper_body_entered")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.bumpAnimation>=0:
		bumpAnimation+=delta
		if bumpAnimation>=0.25:
			bumpAnimation=-1
			$roundPinballBumper.scale=Vector3.ONE
		else:
			$roundPinballBumper.scale=Vector3.ONE+Vector3.ONE*sin(bumpAnimation*PI*4)*0.2
#	for body in bodies:
#		body.BOUNCE_POINT = self.translation
#		body.BOUNCE = true


func _on_RoundPinBallBumper_body_entered(body):
	#print('fire!')
	#print(body.is_in_group('Player'))
	if body.is_in_group('Player'):
#		if not body in bodies:
		body.BOUNCE_POINT = self.translation
		body.BOUNCE = true
		bumpAnimation=0
		#bodies.append(body)




#func _on_RoundPinBallBumper_body_exited(body):
#	if body in bodies:
#		bodies.remove(bodies.find(body))
