/// @description Player Movement
gravity_current -= gravity_strength;

velocity_current.x = lerp(velocity_current.x, input_velocity.x, player_rigidity);
if (state == PLAYER_STATE.walking or state == PLAYER_STATE.shooting)
	velocity_current.y += gravity_current;
/// @stub handle climbing walls when swimming

velocity_current.z = lerp(velocity_current.z, input_velocity.z, player_rigidity);
renderable.set_position(
	renderable.position.x + velocity_current.x,
	renderable.position.y + velocity_current.y,
	renderable.position.z + velocity_current.z
)

var velocity_mag = vector3_magnitude(velocity_current);
renderable_billboard.set_position(renderable.position.x, renderable.position.y - 1.0 + cos(pi * current_time / 250) * velocity_mag, renderable.position.z);