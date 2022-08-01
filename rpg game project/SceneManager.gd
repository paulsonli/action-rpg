extends Node2D

onready var sceneAnimation = $ScreenTransition/AnimationPlayer
onready var currentScene = $CurrentScene

var next_scene = null
var player_location = Vector2.ZERO
var player_direction = Vector2.ZERO


func transition_to_scene(new_scene: String, spawn_location, spawn_direction):
	next_scene = new_scene
	player_location = spawn_location
	player_direction = spawn_direction

	sceneAnimation.play("FadeToBlack")
	
	
func finished_fading():
	currentScene.get_child(0).queue_free()
	currentScene.add_child(load(next_scene).instance())
	
	var player = currentScene.get_children().back().find_node("Player")
	player.set_spawn(player_location, player_direction)
	
	sceneAnimation.play("FadeToNormal")
