extends Line2D

class_name Edge

func configurar(pos_a: Vector2, pos_b: Vector2):
	clear_points()
	add_point(to_local(pos_a))
	add_point(to_local(pos_b))
	
