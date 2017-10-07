extends Sprite

onready var bounds_poly = get_node("bounds")

var x_range = Vector2() #min and max X to check against scene bounds
var y_range = Vector2() #min and max Y to check generic scene bounds
export(Vector2) var points_from_to = Vector2(0, 19)
export(Vector2) var texture_extents
var average_heights = Array() #average heights to clamp the walking
var poly_points
var idx_range

func _ready():
	poly_points = Array()
	texture_extents = get_texture().get_size() / 2
	#adjus points for scale and position of transform
	for point in bounds_poly.get_polygon():
		poly_points.append(point * get_scale() + get_pos())
	idx_range = range(points_from_to.x + 1, points_from_to.y)
	#setup max x and min x
	for point in poly_points:
		if (x_range.x > point.x):
			x_range.x = point.x
		if (y_range.x > point.y):
			y_range.x = point.y
		if (x_range.y < point.x):
			x_range.y = point.x
		if (y_range.y < point.y):
			y_range.y = point.y
	
	for idx in range(points_from_to.x + 1, points_from_to.y + 1):
		average_heights.append((poly_points[idx].y + poly_points[idx - 1].y) / 2)

func nearest_in_general_bounds(point):
	var good_x = clamp(point.x, x_range.x, x_range.y)
	var good_y = clamp(point.y, y_range.x, y_range.y)
	return point_or_better(point, good_x, good_y)

#check poly bounds for point and release closest
func nearest_in_bounds(point):
	var general = nearest_in_general_bounds(point)
	var good_x = general.x
	var good_y = general.y
	for idx in idx_range:
		#found polygon segment where this point is in width, adjust height
		if (good_x < poly_points[idx].x):
			#return height with slight offset not to make it look bad
			good_y = clamp(good_y, average_heights[idx-1] + 0.5, y_range.y)
			break
	
	return point_or_better(point, good_x, good_y)
	
func point_or_better(point, good_x, good_y):
	if (point.x == good_x and point.y == good_y):
		return point
	else:
		return Vector2(good_x, good_y)
