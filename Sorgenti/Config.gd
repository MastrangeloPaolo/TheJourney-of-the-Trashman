extends Node

var configManager

func _ready():
	configManager = ConfigFile.new()
	configManager.load("properties.ini")

	
func getProperty(section, key):
	return configManager.get_value(section, key) if configManager.has_section_key(section,key) else null

func getAllProperties(section):
	var props = {}
	for key in configManager.get_section_keys(section):
		props[key] = getProperty(section,key)
	return props
