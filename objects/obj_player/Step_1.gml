/// @description Scan Physics
var collisions = obj_physics_controller.get_intesection_array(collidable);

if (array_length(collisions) <= 0)
	return;
	
var push_vector = vector3_format_struct(0, 0, 0); // Direction to push outside of the instances
for (var i = 0; i < array_length(collisions); ++i)
	push_vector = vector3_add_vector3(push_vector, collisions[i].get_push_vector(collidable));

renderable.position = vector3_add_vector3(renderable.position, push_vector);