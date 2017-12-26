# Class EnemiesPool
extends Node
onready var CONST = get_node("/root/const")


#spawn max bound in sec, actual is random
var spawn_wait_max = 0.0
var current_spawn_wait
#pool holds packed enemy scene  and baked enemy spawn position
var enemies_pool = []
#currently available onscreen enemies (keys are node names)
var current_enemies = {}
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
#level signals
signal enemy_pool_finished( pool )
signal enemy_pool_enemy_dead(enemy_node)
signal enemy_pool_add_new(enemy_node, global_feet_pos)

func _init(
level,
enemies_data, 
left_x, 
right_x, 
spawn_y_bounds,
spawn_interval_bound = 0.1):
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
	current_enemies = {}
	current_spawn_wait = rand_range(0, spawn_wait_max)
	self.level = level
	
#constnats not initialized before _ready
func _ready():
	finished = enemies_pool.empty()
	#connect level to the signals emitted later
	connect(CONST.SIG_ENEMY_POOL_ADD_NEW, level, "_enemy_created")
	#pool exhausted and over
	connect(CONST.SIG_ENEMY_POOL_FINISHED, level, "_pool_stop_finished")
	connect("enemy_pool_enemy_dead", level, "_enemy_dead")
	
func _process(delta):
	if (finished):
		print("pool %s finished!" % self)
		emit_signal(CONST.SIG_ENEMY_POOL_FINISHED, self)
		queue_free()
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
			emit_signal(CONST.SIG_ENEMY_POOL_ADD_NEW, real_enemy, packed_enemy.position)
			real_enemy.connect_pool_signal(self)
			current_enemies[real_enemy.get_name()] = real_enemy

func _enemy_dead( enemy_node ):
	#ignore indices out of range
	if (current_enemies.has(enemy_node.get_name())):
		print("enemy %s dead, removing..." % enemy_node.get_name())
		current_enemies.erase(enemy_node.get_name())
		emit_signal("enemy_pool_enemy_dead", enemy_node)
	if (current_enemies.empty()):
			finished = true