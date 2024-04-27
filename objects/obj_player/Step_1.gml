/// @description Player Movement
gravity_current -= gravity_strength;

for (var i = 0; i < 3; ++i){
	if (vector_up[$ StaticMesh.AXIS_LABEL[i]] == 0)
		velocity_current[$ StaticMesh.AXIS_LABEL[i]] = lerp(velocity_current[$ StaticMesh.AXIS_LABEL[i]], input_velocity[$ StaticMesh.AXIS_LABEL[i]], player_rigidity);
}
velocity_current = vector3_add_vector3(velocity_current, vector3_mul_scalar(vector_up, gravity_current)) // Add gravity

renderable.set_position(
	renderable.position.x + velocity_current.x,
	renderable.position.y + velocity_current.y,
	renderable.position.z + velocity_current.z
)

var velocity_mag = vector3_magnitude(velocity_current);
// renderable_billboard.set_position(renderable.position.x, renderable.position.y - 1.0 + cos(pi * current_time / 250) * velocity_mag * 0.6, renderable.position.z);
var bob_position = vector3_add_vector3(renderable.position, vector3_mul_scalar(vector_up, -1.0 + cos(pi * current_time / 250) * velocity_mag * 0.6));
renderable_billboard.set_position(bob_position.x, bob_position.y, bob_position.z);