/// ABOUT
/// Player handling unstance that manages elements relating to the player as well
/// as, for the sake of simplicity, camera controls.

enum PLAYER_STATE {
	walking,
	swimming,
	shooting
}

#region PROPERTIES
cam_yaw = 0; // Desired yaw position
cam_pitch = 12; // Desired pitch where positive = down
cam_rigidity = 0.2; // Lower rigidity = more 'bouncy' camera movement
player_rigidity = 0.15; // Affects both movement & rotation
player_walk_speed = 0.15;
player_swim_speed = 0.25;
velocity_current = vector3_format_struct(0, 0, 0);
input_velocity = vector3_format_struct(0, 0, 0); // Velocity calculated by the controller input
gravity_strength = 0.0005;
gravity_current = 0;
is_on_ground = false; // Auto-updated after physics checks
state = PLAYER_STATE.walking;
firing_length = 8;
firing_cooldown = 10;
firing_timer = firing_length;
ink_color = SplatMesh.COLOR_B; // Can be swapped w/ L1 button
							   // For this test, COLOR_A is 'enemy' and COLOR_B is 'friendly'
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
	var rotation;
	var move_2d_vector = vector3_format_struct(-y_axis, 0, -x_axis);
	move_2d_vector = vector3_rotate(move_2d_vector, vector3_format_struct(0, 1, 0), degtorad(-obj_camera.get_yaw()));
	var angle = point_direction(0, 0, move_2d_vector.x, move_2d_vector.z);
	var dif = angle_difference(angle, renderable.rotation.y);
	if (state == PLAYER_STATE.walking){
		rotation = lerp(renderable.rotation.y, renderable.rotation.y + dif, player_rigidity);
		renderable.rotation.y = rotation;
	}
	else if (state == PLAYER_STATE.shooting)
		rotation = renderable.rotation.y + dif;
	
	// Calculate desired player velocity
		// Note: We re-calculate vector due to the rotation lerp not using our exact rotation value
	var input_mag = sqrt(sqr(x_axis) + sqr(y_axis));
	input_velocity.x = dcos(rotation) * player_walk_speed * input_mag
	input_velocity.z = dsin(rotation) * player_walk_speed * input_mag;
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

function input_fire(player, color){
	state = PLAYER_STATE.shooting;
	
	var dif = angle_difference(-obj_camera.get_yaw(), renderable.rotation.y);
	renderable.rotation.y = lerp(renderable.rotation.y, renderable.rotation.y + dif, player_rigidity);
	renderable.is_model_matrix_changed = true; // Forces the model to physically update next render
	
	--firing_timer;
	if (firing_timer <= 0){
		if (firing_timer < -firing_cooldown)
			firing_timer = firing_length;
		return;
	}
	
	if (firing_timer % 2) // Only fire every other frame
		return;
	
	var instance = instance_create_layer(0, 0, "Instances", obj_inkball);
	instance.renderable.position.x = renderable.position.x + dcos(renderable.rotation.y);
	instance.renderable.position.z = renderable.position.z + dsin(renderable.rotation.y);
	instance.renderable.position.y = renderable.position.y;
	
	var vector = obj_camera.get_lookat_vector();
	var rvector = get_right_vector();
	vector = vector3_rotate(vector, rvector, pi / 4);
	
	instance.velocity_current = vector3_mul_scalar(vector, 1.2);
	instance.velocity_current = vector3_rotate(instance.velocity_current, vector3_format_struct(0, 1, 0), random_range(-pi / 60, pi / 60))
	instance.velocity_current = vector3_rotate(instance.velocity_current, rvector, random_range(-pi / 60, pi / 60))
	instance.renderable.set_color(ink_color);
	instance.renderable.set_scale(0.35 + random(0.5));
}

function input_fire_released(){
	state = PLAYER_STATE.walking;
	fire_timer = 8;
}

function input_swim(){
	state = PLAYER_STATE.swimming;
}

function input_swim_released(){
	state = PLAYER_STATE.walking;
}

function get_forward_vector(){
	return vector3_normalize(vector3_format_struct(dcos(renderable.rotation.y), 0, dsin(renderable.rotation.y)));
}

function get_right_vector(){
	return vector3_cross(get_forward_vector(), vector3_format_struct(0, 1, 0));
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
obj_input_controller.signaler.add_signal("shoulder.right.trigger.button", method(id, id.input_fire));
obj_input_controller.signaler.add_signal("shoulder.right.trigger.button.released", method(id, id.input_fire_released));
obj_input_controller.signaler.add_signal("face.right.west", method(id, id.input_swim));
obj_input_controller.signaler.add_signal("face.right.west.released", method(id, id.input_swim_released));
obj_input_controller.signaler.add_signal("shoulder.right.bumper.button.pressed", method(id, function(){
	ink_color = (ink_color == SplatMesh.COLOR_A ? SplatMesh.COLOR_B : SplatMesh.COLOR_A);
}));
#endregion