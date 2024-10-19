extends Node


const PREFIX = "user://"
const SUFFIX = "_save"

var save_data = {}
var init_config = ConfigFile.new()
var game_data = {}
enum MENU_STATES {UPGRADE, DIARY, OPTIONS, LEVEL_END, DIALOG, NONE}
var menu_state = MENU_STATES.NONE


func saveGame():
	var saveGame = File.new()
	saveGame.open(_get_file_name(save_data["player"]), File.WRITE)
	saveGame.store_var(save_data)
	saveGame.close()

func my_free(node):
	node.free()

	
func loadGame(name):
	var save = File.new()
	if not save.file_exists(_get_file_name(name)):
		save_data = {}
		save_data["player"] = name
		saveGame()
	save.open(_get_file_name(name),File.READ)
	save_data = save.get_var()
	save.close()
	init_config.load("init_save.ini")


func getCharacters():
	var files = []
	var dir = Directory.new()
	dir.open(PREFIX)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.find("_save")!=-1:
			files.append(file.replace("_save",""))

	dir.list_dir_end()
	return files

func createPlayer(name):
	loadGame(name)	

func get(key,fromGame = false):
	if(fromGame):
		if game_data.has(key): return game_data[key]
		return false
	if save_data.has(key): return save_data[key]
	return init_config.get_value("data",key)

func set(key,value,fromGame = false):
	if(fromGame): game_data[key] = value
	else:save_data[key] = value
	
func _get_file_name(name):
	return PREFIX+name+SUFFIX
	
func characterExists(name):
	return name in getCharacters()
	
	
func deleteCharacters(characters):
	var dir = Directory.new()
	for character in characters:
		dir.remove(_get_file_name(character))
		
func resetGame():
	loadGame(save_data["player"])
	
func completedCount():
	var n = 0
	var levels = ["LivelloTutorial","Livello1","Livello2"]
	for l in levels:
		if save_data.has(l) and save_data[l][0]: n+=1
	return n
