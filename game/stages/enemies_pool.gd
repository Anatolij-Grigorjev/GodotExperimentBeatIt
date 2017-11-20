# Class EnemiesPool

extends Node

#spawn max bound in sec, actual is random
var spawn_wait_max = 0.0
var current_spawn_wait
#pool holds packed enemy scene  and baked enemy spawn position
var enemies_pool = []
#currently available onscreen enemies
var current_enemies = []
#left side spanw X and rightside spawn X
var x_bounds = Vector2()
#coninuous range of spawn-ready Ys
var y_bounds = Vector2()

var finished = false #pool over

#enemy code in JSON translation to packed scene enemy
var code_to_enemy_scene = {
	"thug" : preload("res://characters/enemies/thug/thug.tscn")
}
var level

func _init(
level,
enemies_data, 
left_x, 
right_x, 
spawn_y_bounds,
spawn_interval_bound = 0.75):
	spawn_wait_max = spawn_interval_bound
	x_bounds = {
		"left": left_x,
		"right": right_x
	}
	y_bounds = Vector2(spawn_y_bounds.x, spawn_y_bounds.y)
	enemies_pool = []
	#bake enemies pool
	for enemy in enemies_data:
		enemies_pool.append({
			"scene": code_to_enemy_scene[enemy.code],
			"position": Vector2(x_bounds[enemy.from], 
			rand_range(y_bounds.x, y_bounds.y))
		})
	current_enemies = []
	current_spawn_wait = rand_range(0, spawn_wait_max)
	#level passed as arg becasue this script is just an object with no access to scene tree
	self.level = level
	
func _process(delta):
	if (finished):
		return
	#still have enemies to release, check in with timer and do it
	if (!enemies_pool.empty()):
		if (current_spawn_wait > 0):
			current_spawn_wait -= delta
		else:
			current_spawn_wait = rand_range(0, spawn_wait_max)
			var packed_enemy = enemies_pool.back()
			enemies_pool.pop_back()
			var real_enemy = packed_enemy.scene.instance()
			level.add_child(real_enemy)
			real_enemy.set_pos_by_feet(packed_enemy.position)
			print("Created enemy " + str(real_enemy) + " at position " + str(real_enemy.get_pos()))
			current_enemies.append(real_enemy)
	else:
		if (current_enemies.empty()):
			finished = true
		else:
			#prune freed enemies
			for enemy in current_enemies:
				if (enemy.is_queued_for_deletion()):
					current_enemies.remove(enemy)