
gravity_current -= gravity_strength;
velocity_current.y += gravity_current; 
renderable.position = vector3_add_vector3(renderable.position, velocity_current);
renderable.update_matrices(true);


// Simple 'out of world' check:
if (renderable.position.y < -10)
	instance_destroy();