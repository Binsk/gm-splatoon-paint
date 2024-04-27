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
var collisions = obj_physics_controller.get_line_collision_array(vector3_add_vector3(renderable.position, vector3_format_struct(0, -0.75, 0)), vector3_add_vector3(renderable.position, vector3_format_struct(0, -1.25, 0)));
if (array_length(collisions) > 0){
	// We are only going to care about the first collision since >1 would be extremely rare
	ink_floor_color = collisions[0].renderable.get_splat_index(collisions[0].data.uv);
}

// Check for collisions w/ terrain:
collisions = obj_physics_controller.get_intesection_array(collidable);
if (array_length(collisions) <= 0)
	return;
	
var push_vector = vector3_format_struct(0, 0, 0); // Direction to push outside of the instances
for (var i = 0; i < array_length(collisions); ++i)
	push_vector = vector3_add_vector3(push_vector, collisions[i].get_push_vector(collidable));

renderable.position = vector3_add_vector3(renderable.position, push_vector);
velocity_current = vector3_add_vector3(velocity_current, push_vector);

if (push_vector.y > 0){
	is_on_ground = true;
	gravity_current = 0;
}