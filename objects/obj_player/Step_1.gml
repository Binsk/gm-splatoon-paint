/// @description Player Movement
gravity_current -= gravity_strength;
velocity_current.x = lerp(velocity_current.x, input_velocity.x, player_rigidity);
if (state == PLAYER_STATE.walking)
	velocity_current.y += gravity_current;
/// @stub handle climbing walls when swimming

velocity_current.z = lerp(velocity_current.z, input_velocity.z, player_rigidity);
renderable.position.x += velocity_current.x;
renderable.position.y += velocity_current.y;
renderable.position.z += velocity_current.z;