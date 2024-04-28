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
player_swim_speed = 0.20;
player_enemyink_speed = 0.02; // When in bad ink, your speed
velocity_current = vector3_format_struct(0, 0, 0);
input_velocity = vector3_format_struct(0, 0, 0); // Velocity calculated by the controller input
gravity_strength = 0.0005;
gravity_current = 0;
is_on_ground = false; // Auto-updated after physics checks
state = PLAYER_STATE.walking;
firing_length = 8;
firing_cooldown = 10;
firing_timer = firing_length;
ink_fire_color = 2; // Can be swapped w/ L1 button'
ink_team_color = 2;	// Our color
ink_floor_color = 0; // Counts for floor and walls (when swimming)

vector_up = vector3_format_struct(0, 1, 0); // Used for swimming
#endregion


#region METHODS
/// @note	We just ignore the player number and allow any connected controller
///			to move the player.
function input_move(player, x_axis, y_axis){
	if (abs(x_axis) < 0.01 and abs(y_axis) < 0.01){
		// We can cheat since our up-vector will always be axis aligned. Whatever
		// axis is 0 doesn't have gravity so we can apply 'friction' by setting it to 0
		if (vector_up.x == 0)
			input_velocity.x = 0;
		
		if (vector_up.y == 0)
			input_velocity.y = 0;
		
		if (vector_up.z == 0)
			input_velocity.z = 0;
		return;
	}
		
	// Calculate rotation relative to the camera & surface:
	var vector_right;
	var vector_look = vector3_normalize(vector3_project(obj_camera.get_lookat_vector(), vector_up)); 
		// We don't want to actually treat walls 'equally' singe we always want 'up' to ve y-up, even though
		// the surface's 'up' may be on x or z. As such, force the y-axis always to be one direction:
	if (vector_look.y < 0)
		vector_look.y = -vector_look.y;
		
	vector_right = vector3_normalize(vector3_cross(vector_look, vector_up)); 
		
	var vector_forward = vector3_normalize(vector3_cross(vector_up, vector_right));
	var movement_vector = vector3_add_vector3(vector3_mul_scalar(vector_right, x_axis), vector3_mul_scalar(vector_forward, -y_axis));
	
	/// Calculate visual rotation (only applicable when not swimming)
	var rotation, move_speed = player_walk_speed;
	var angle = point_direction(0, 0, movement_vector.x, -movement_vector.z);
	var dif = angle_difference(angle, renderable.rotation.y);

	if (state == PLAYER_STATE.walking){
		rotation = lerp(renderable.rotation.y, renderable.rotation.y + dif, player_rigidity);
		renderable.rotation.y = rotation;
	}
	else if (state == PLAYER_STATE.shooting)
		rotation = renderable.rotation.y + dif;
	else if (state == PLAYER_STATE.swimming){
		rotation = lerp(renderable.rotation.y, renderable.rotation.y + dif, player_rigidity);
		renderable.rotation.y = rotation;
		move_speed = (ink_floor_color == ink_team_color ? player_swim_speed : player_enemyink_speed);
		if (not is_on_ground)
			move_speed = player_walk_speed;
	}
	
	// Override movement speed in bad ink
	if (ink_floor_color > 0 and ink_floor_color != ink_team_color)
		move_speed = player_enemyink_speed;
	
	// Calculate desired player velocity; we use a slerp to properly account
	// for player rigidity
	var input_mag = sqrt(sqr(x_axis) + sqr(y_axis));
	if (vector3_magnitude(input_velocity) == 0)
		input_velocity = vector3_mul_scalar(vector3_normalize(movement_vector), move_speed * input_mag);
	else 
		input_velocity = vector3_mul_scalar(vector3_normalize(vector3_slerp(vector3_normalize(input_velocity), vector3_normalize(movement_vector), player_rigidity)), move_speed * input_mag);
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
	velocity_current = vector3_add_vector3(velocity_current, vector3_mul_scalar(vector_up, 0.15));
	
	if (state == PLAYER_STATE.swimming and vector_up.y != 1) // Bit of a special case for jumping off walls
		state = PLAYER_STATE.walking;
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
	
	if (ink_fire_color == 0)
		instance.renderable.set_color(c_white)
	else
		instance.renderable.set_color(ink_fire_color == 1 ? SplatMesh.COLOR_A : SplatMesh.COLOR_B);
		
	instance.renderable.set_scale(0.35 + random(0.5));
	instance.set_splat_shape(splat_shape_array[irandom_range(0, array_length(splat_shape_array) -1)]);
	instance.set_team_id(ink_fire_color);
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

renderable_billboard = new BillboardMesh(); // Just used so we see SOMETHING when swimming
renderable_billboard.set_texture(sprite_get_texture(spr_inkball, 0));
renderable_billboard.set_color(make_color_rgb(170, 0, 255)); // Match the cap of the player sprite
renderable_billboard.set_visible(false);

// Collidables inherit scaling by their parents
	// We make the x/z axes a little larger so the corners don't clip when rotating
collidable = new Collidable(point_format_struct(-0.7, -0.5, -0.7), point_format_struct(0.7, 0.5, 0.7), renderable);

obj_render_controller.add_renderable(renderable); // Makes the instance visible
obj_render_controller.add_renderable(renderable_billboard);
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
	ink_fire_color = (ink_fire_color + 1) % 3;
}));

// Generate possible splat shapes for our ink:
splat_shape_array = [];
for (var i = 0; i < sprite_get_number(spr_splat); ++i){
	var shape = new SplatShape(spr_splat, i);
	array_push(splat_shape_array, shape)
}
#endregion