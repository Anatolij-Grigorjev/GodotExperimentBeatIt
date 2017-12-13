extends "../attack_hitboxes.gd"


#access to main character attack node
onready var attacks = get_node("../../player_attack")

func _ready():
	parent = get_node("../../")
	attacks_conf_file = CONST.PLAYER_ATTACKS_CONFIG_FILE_PATH
	enemy_group = CONST.GROUP_ENEMIES
	._ready()
	
	
func do_attack( body, attack_info ):
	print(attack_info.attack_name)
	#handle an enemy getting hit
	var connected = .do_attack(body, attack_info)
	if (connected):
		#touched enemt body with combo, therefore registers as 
		#hit to continue combo regardless of damage done
		attacks.hitting = true


func doing_attack(idx, doing = true):
	var attack = .doing_attack(idx, doing)
	#initialize possibility of combo hit connecting
	#this is later changed in actual hit processing
	#and then reset at combo end
	if (attack.active):
		attacks.hitting = false
