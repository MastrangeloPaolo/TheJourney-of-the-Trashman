extends Node

var keys = {}
var props = {}
var keysFile = "user://customKeys"
var propsFile = "user://customSettings"

func _ready():
	loadKeys()
	loadProps()
	
func getKey(action):
	var l = InputMap.get_action_list(action)
	return  "" if l.size() == 0 or l[0].scancode == 0  else l[0].as_text()
	
func setKey(action,event):
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action,event)
	keys[action] = event.scancode

func getProp(prop):
	return props[prop]

func setProp(prop,value):
	props[prop] = value

func loadKeys():
	var file = File.new()
	if file.file_exists(keysFile):
		file.open(keysFile,File.READ)
		keys = file.get_var()
		file.close()
	else:
		keys = Config.getAllProperties("keys")
	setKeys()

func loadProps():
	var file = File.new()
	if file.file_exists(propsFile):
		file.open(propsFile,File.READ)
		props = file.get_var()
		file.close()
	else:
		props = Config.getAllProperties("settings")
	setProps()

func setProps():

	OS.window_fullscreen = props["fullscreen"]
	var idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(idx,props["volume"])

func resetKeys():
	keys = Config.getAllProperties("keys")
	var file = File.new()
	if file.file_exists(keysFile):
		var dir = Directory.new()
		dir.remove(keysFile)
	setKeys()	
	
func saveKeys():
	var file = File.new()
	file.open(keysFile, File.WRITE)
	file.store_var(keys)
	file.close()
	
func saveProps():
	var file = File.new()
	file.open(propsFile, File.WRITE)
	file.store_var(props)
	file.close()
	
func setKeys():
	for key in keys.keys():
		var event = InputEventKey.new()
		event.scancode = keys[key]	
		setKey(key,event)
		
func emptyPrev(_action,event):
	for key in keys:
		if keys[key] == event.scancode:
			InputMap.action_erase_events(key)
			keys[key] = 0
			break
