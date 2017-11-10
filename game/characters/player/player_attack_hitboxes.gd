extends Node2D

#quick access to constnats
onready var CONST = get_node("/root/const")
onready var attacks_hitboxes = [
	get_node("attack_1"),
	get_node("attack_2"),
	get_node("attack_3"),
	get_node("attack_4"),
	get_node("attack_jump_asc"),
	get_node("attack_jump_desc")
]
#access to main character node
onready var parent = get_node("../")
onready var attacks = get_node("../player_attack")

func _ready():
	#load attacks data from attacks.INI file
	config_attacks()
	reset_attacks()
	set_process(true)


func config_attacks():
	var attacks_config = ConfigFile.new()
	var err = attacks_config.load(CONST.PLAYER_ATTACKS_CONFIG_FILE_PATH)
	#only do this if loaded attacks OK
	if err == OK:
		var attack_names = attacks_config.get_sections()
		for attack_name in attack_names:
			var attack_node = get_node(attack_name)
			attack_node.attack_info.attack_name = attack_name
			for prop in attacks_config.get_section_keys(attack_name):		
				attack_node.attack_info[prop] = attacks_config.get_value(
				attack_name, 
				prop, 
				attack_node.attack_info[prop])
			attack_node.dump()
	else:
		print("problem opening attacks.ini: " + str(err))
	
func _process (delta):
	for attack_node in attacks_hitboxes:
		if (attack_node.active):
			attack_node.process_bodies()
	
func do_attack( body, attack_info ):
	#handle an enemy getting hit
	if (body.is_in_group(CONST.GROUP_ENEMIES)):
		var enemy = body
		#touched enemt body with combo, therefore registers as 
		#hit to continue combo regardless of damage done
		attacks.hitting = true
		#cant hit an enemy twice while they are being hit
		if (enemy.getting_hit):
			return
		#lower center of enemy to see if they in attack range
		var enemy_z = enemy.get_z()
		var diff = abs(parent.get_z() - enemy_z)
		var current_attack = attack_info.attack_name
		print(str(current_attack) + "|" + str(parent.get_z()) + "|" + str(enemy_z))
		if (diff < attack_info.attack_z):
			print("attack hit true! Hitting: " + str(enemy))
			enemy.get_hit(attack_info)
		else:
			print("attack went wide! Difference: " + 
			str(diff) + "|Required: " + str(attack_info.attack_z))
			
func doing_attack(idx, doing = true):
	var attack = attacks_hitboxes[idx]
	attack.active = doing
	#initialize possibility of combo hit connecting
	#this is later changed in actual hit processing
	#and then reset at combo end
	if (attack.active):
		attacks.hitting = false

func reset_attacks():
	for attack_node in attacks_hitboxes:
		attack_node.active = false
