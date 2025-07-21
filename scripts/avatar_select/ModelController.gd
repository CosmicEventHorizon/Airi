extends Node3D

#
@onready var anim_player = get_node("/root/AvatarSelect/Preview/Model/AvatarSample_E/AnimationPlayer")


func _ready():
	anim_player.play("idle")
	anim_player.get_animation("idle").loop = true
	
	
