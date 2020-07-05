extends Spatial

export var collisionMode = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$StaticBody/CollisionShape.disabled=collisionMode
	$StaticBody/CollisionShape2.disabled=!collisionMode


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
