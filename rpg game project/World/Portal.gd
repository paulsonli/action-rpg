extends Area2D

export(String, FILE) var next_scene_path = ""

export(Vector2) var spawn_location = Vector2.ZERO
export(Vector2) var spawn_direction = Vector2.ZERO


func _input(event):
	if event.is_action_pressed("ui_accept"):
		if !next_scene_path:
			print("no scene in this portal")
			return
		
		if(get_overlapping_bodies().size()) > 0:
			get_node(NodePath("/root/SceneManager")).transition_to_scene(next_scene_path, spawn_location, spawn_direction)
