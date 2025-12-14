extends Resource
class_name DataUtilities

static func world_to_screen(node: Node2D) -> Vector2:
	if node == null:
		return Vector2.ZERO

	var vp: Viewport = node.get_viewport()
	if vp == null:
		return node.global_position

	var world_pos: Vector2 = node.global_position
	var cam: Camera2D = vp.get_camera_2d()

	if cam == null:
		return world_pos - vp.get_visible_rect().position

	var cam_inv: Transform2D = cam.global_transform.affine_inverse()
	var cam_space: Vector2 = cam_inv * world_pos

	var zoom: Vector2 = cam.zoom
	cam_space.x *= zoom.x
	cam_space.y *= zoom.y

	var screen_size: Vector2 = vp.get_visible_rect().size
	var screen_pos: Vector2 = cam_space + screen_size * 0.5

	return screen_pos
