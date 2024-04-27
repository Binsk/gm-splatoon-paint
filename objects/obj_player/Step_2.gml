/// @description Scan Physics
is_on_ground = false;

if (renderable.position.y < -20){ // Reset falling out of the world
	renderable.set_position(0, 4, 0);
	velocity_current.y = 0;
	gravity_current = 0;
}

// Check for collisions w/ ink:
ink_floor_color = 0;

	// Check floor first:
var vector_base = vector3_add_vector3(renderable.position, vector3_format_struct(0, -0.5, 0));
var collisions = obj_physics_controller.get_line_collision_array(vector_base, vector3_sub_vector3(vector_base, vector_up));
if (array_length(collisions) > 0){
	// We are only going to care about the first collision since >1 would be extremely rare
	ink_floor_color = collisions[0].renderable.get_splat_index(collisions[0].data.uv);
}

	// Check movement vector:
if (state == PLAYER_STATE.swimming){
	collisions = [];
	var velocity_onfloor = vector3_project(velocity_current, vector_up);
	if (vector3_magnitude(velocity_onfloor) > 0)
		collisions = obj_physics_controller.get_line_collision_array(vector_base, vector3_add_vector3(vector_base, vector3_normalize(velocity_onfloor)));
	
	if (array_length(collisions) > 0){
		if (ink_team_color == collisions[0].renderable.get_splat_index(collisions[0].data.uv)){
/// @fixme	Noticed the normal vectors are backwards; flipping them causes a host of issues so
///			the relevant systems need to be changed as well.
			vector_up = vector3_mul_scalar(collisions[0].data.normal, -1);
			gravity_current = 0;
			ink_floor_color = ink_team_color;
		}
	}
}

if (state == PLAYER_STATE.swimming and ink_floor_color != ink_team_color) // If not in ink; gravity goes back to normal
	vector_up = vector3_format_struct(0, 1, 0);

// Swimming position:
var swim_position = vector_base;
renderable_billboard.set_position(swim_position.x, swim_position.y, swim_position.z);

// Check for collisions w/ terrain:
collisions = obj_physics_controller.get_intesection_array(collidable);
if (array_length(collisions) <= 0)
	return;
	
var push_vector = vector3_format_struct(0, 0, 0); // Direction to push outside of the instances
for (var i = 0; i < array_length(collisions); ++i)
	push_vector = vector3_add_vector3(push_vector, collisions[i].get_push_vector(collidable));

renderable.position = vector3_add_vector3(renderable.position, push_vector);
velocity_current = vector3_add_vector3(velocity_current, push_vector);

if (sign(vector3_dot(push_vector, vector_up)) == sign(vector3_dot(vector_up, vector_up))){
	is_on_ground = true;
	gravity_current = 0;
}