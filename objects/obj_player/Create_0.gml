/// ABOUT
/// Player handling unstance that manages elements relating to the player as well
/// as, for the sake of simplicity, camera controls.

enum PLAYER_STATE {
	walking,
	swimming
}

#region PROPERTIES
cam_yaw = 0; // Desired yaw position
cam_pitch = 12;
cam_rigidity = 0.2; // Lower rigidity = more 'bouncy' camera movement
player_rigidity = 0.15;
player_walk_speed = 0.15; // Movement speed
player_swim_speed = 0.25;
velocity_current = vector3_format_struct(0, 0, 0);
input_velocity = vector3_format_struct(0, 0, 0); // Velocity calculated by the controller input
gravity_strength = 0.0005;
gravity_current = 0;
is_on_ground = false;
state = PLAYER_STATE.walking;
#endregion

#region METHODS
/// @note	We just ignore the player number and allow any connected controller
///			to move the player.
function input_move(player, x_axis, y_axis){
	if (abs(x_axis) < 0.01 and abs(y_axis) < 0.01){
		input_velocity.x = 0;
		input_velocity.z = 0;
		return;
	}
		
	// Calculate rotation relative to the camera
	var move_2d_vector = vector3_format_struct(-y_axis, 0, -x_axis);
	move_2d_vector = vector3_rotate(move_2d_vector, vector3_format_struct(0, 1, 0), degtorad(-obj_camera.get_yaw()));
	var angle = point_direction(0, 0, move_2d_vector.x, move_2d_vector.z);
	var dif = angle_difference(angle, renderable.rotation.y);
	renderable.rotation.y = lerp(renderable.rotation.y, renderable.rotation.y + dif, player_rigidity);
	
	// Calculate desired player velocity
		// Note: We re-calculate vector due to the rotation lerp not using our exact rotation value
	var input_mag = sqrt(sqr(x_axis) + sqr(y_axis));
	input_velocity.x = dcos(renderable.rotation.y) * player_walk_speed * input_mag
	input_velocity.z = dsin(renderable.rotation.y) * player_walk_speed * input_mag;
}

function input_look(player, x_axis, y_axis){
	cam_yaw -= x_axis * 3;
	cam_pitch += y_axis * 3;
	cam_pitch = clamp(cam_pitch, -80, 80);
}

function input_jump(player){
	if (not get_is_on_ground())
		return;
		
	// Simple 1-height jump
	velocity_current.y = 0.15;
}

function get_is_on_ground(){
	return is_on_ground;
}
#endregion
#region INIT
renderable = new StaticMesh(0, 1, 0);
renderable.set_render_mesh(vertex_duplicate_buffer(SplatBlockMesh.MESH));
renderable.set_texture(sprite_get_texture(spr_player, 0));
renderable.set_scale(1, 2, 1);

// Collidables inherit scaling by their parents
	// We make the x/z axes a little larger so the corners don't clip when rotating
collidable = new Collidable(point_format_struct(-0.7, -0.5, -0.7), point_format_struct(0.7, 0.5, 0.7), renderable);

obj_render_controller.add_renderable(renderable); // Makes the instance visible
obj_physics_controller.add_collidable(collidable); // Not technically needed, but added in the case of multiple characters down the line

// Attach controller inputs
obj_input_controller.signaler.add_signal("joystick.left.axis", method(id, id.input_move));
obj_input_controller.signaler.add_signal("joystick.right.axis", method(id, id.input_look));
obj_input_controller.signaler.add_signal("face.right.south.pressed", method(id, id.input_jump));
#endregion