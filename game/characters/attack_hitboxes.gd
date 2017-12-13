extends Node2D

#quick access to constnats
onready var CONST = get_node("/root/const")
#list gets populated from configuration file
var attacks_hitboxes = []
#access to main character node
var parent
var attacks_conf_file = "<empty>"
var enemy_group

func _ready():
	#load attacks data from attacks.INI file
	config_attacks()
	reset_attacks()
	set_process(true)


func config_attacks():
	var attacks_config = ConfigFile.new()
	var err = attacks_config.load(attacks_conf_file)
	#only do this if loaded attacks OK
	if err == OK:
		var attack_names = attacks_config.get_sections()
		for attack_name in attack_names:
			var attack_node = get_node(attack_name)
			#add found attack node to hitboxes list
			attacks_hitboxes.append(attack_node)
			attack_node.attack_info.attack_name = attack_name
			for prop in attacks_config.get_section_keys(attack_name):
				attack_node.attack_info[prop] = attacks_config.get_value(
				attack_name, 
				prop, 
				attack_node.attack_info[prop])
			if (attack_node.attack_info.disloge_x != null and attack_node.attack_info.disloge_y != null):
				attack_node.attack_info.disloge_vector = Vector2(attack_node.attack_info.disloge_x, attack_node.attack_info.disloge_y)
		for i in range(0, attacks_hitboxes.size()):
			print("idx %s %s: %s" % [i, attacks_hitboxes[i].get_name(), attacks_hitboxes[i].attack_info])
	else:
		print("problem opening %s: %s" % [attacks_conf_file, err])
	
func _process (delta):
	for attack_node in attacks_hitboxes:
		if (attack_node.active):
			attack_node.process_bodies()
			
			
#return true if the body was in enemy group so attack connected
func do_attack( body, attack_info ):
	#handle an enemy getting hit
	if (body.is_in_group(enemy_group)):
		var enemy = body
		#cant hit an enemy twice while they are being hit
		if (enemy.getting_hit):
			return
		#Z of enemy to see if they in attack range
		var enemy_z = enemy.get_z()
		var diff = abs(parent.get_z() - enemy_z)
		if (diff <= attack_info.attack_z):
			enemy.get_hit(parent, attack_info)
		return true
	else:
		return false

#returns mutated attack state for further processing
func doing_attack(idx, doing = true):
	var attack = attacks_hitboxes[idx]
	attack.active = doing
	return attack

func reset_attacks():
	for attack_node in attacks_hitboxes:
		attack_node.active = false
