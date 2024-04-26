/// ABOUT
/// Player handling unstance that manages elements relating to the player as well
/// as, for the sake of simplicity, camera controls.
#region PROPERTIES
cam_yaw = 0; // Desired yaw position
cam_pitch = 12;
cam_rigidity = 0.2; // Lower rigidity = more 'bouncy' camera movement
player_rigidity = 0.1;
#endregion

#region METHODS
/// @note	We just ignore the player number and allow any connected controller
///			to move the player.
function input_move(player, x_axis, y_axis){
	if (abs(x_axis) < 0.01 and abs(y_axis) < 0.01)
		return;
		
	var move_2d_vector = vector3_format_struct(-y_axis, 0, -x_axis);
	move_2d_vector = vector3_rotate(move_2d_vector, vector3_format_struct(0, 1, 0), degtorad(-obj_camera.get_yaw()));
	// var angle = vector3_angle_difference(move_2d_vector, vector3_format_struct(1, 0, 0));
	var angle = point_direction(0, 0, move_2d_vector.x, move_2d_vector.z);
	
	var dif = angle_difference(angle, renderable.rotation.y);
	renderable.rotation.y = lerp(renderable.rotation.y, renderable.rotation.y + dif, player_rigidity);
}

function input_look(player, x_axis, y_axis){
	cam_yaw -= x_axis * 3;
	cam_pitch += y_axis * 3;
	cam_pitch = clamp(cam_pitch, -80, 80);
}
#endregion
#region INIT
renderable = new StaticMesh(0, 0, 0);
renderable.set_render_mesh(vertex_duplicate_buffer(SplatBlockMesh.MESH));
renderable.set_texture(sprite_get_texture(spr_player, 0));
renderable.set_scale(1, 2, 1);

// Collidables inherit scaling by their parents
collidable = new Collidable(point_format_struct(-0.5, -0.5, -0.5), point_format_struct(0.5, 0.5, 0.5), renderable);

obj_render_controller.add_renderable(renderable); // Makes the instance visible
obj_physics_controller.add_collidable(collidable); // Not technically needed, but added in the case of multiple characters down the line

// Attach controller inputs
obj_input_controller.signaler.add_signal("joystick.left.axis", method(id, id.input_move));
obj_input_controller.signaler.add_signal("joystick.right.axis", method(id, id.input_look));
#endregion