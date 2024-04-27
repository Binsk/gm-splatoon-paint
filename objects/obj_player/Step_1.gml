/// @description Player Movement
if (state != PLAYER_STATE.swimming)
	vector_up = vector3_format_struct(0, 1, 0);

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