extends Node

var current_scene = null

func _ready():
	var root = get_tree().get_root()
	#save the current scene
	current_scene = root.get_child(root.get_child_count()-1)
	
func goto_scene(path: String):
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path: String):
	current_scene.free()
	var x = ResourceLoader.load(path)
	current_scene = x.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
