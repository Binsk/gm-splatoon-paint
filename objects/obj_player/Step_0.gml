/// @description Update Camera
with (obj_camera){
	look_x = lerp(look_x, other.renderable.position.x, other.cam_rigidity);
	look_y = lerp(look_y, other.renderable.position.y - 1, other.cam_rigidity);
	look_z = lerp(look_z, other.renderable.position.z, other.cam_rigidity);
	
	x = lerp(x, other.renderable.position.x + dcos(other.cam_yaw + 180) * 8 * dcos(other.cam_pitch), other.cam_rigidity);
	y = lerp(y, other.renderable.position.y + 8 * dsin(other.cam_pitch), other.cam_rigidity);
	z = lerp(z, other.renderable.position.z - dsin(other.cam_yaw + 180) * 8 * dcos(other.cam_pitch), other.cam_rigidity);
}

if (state != PLAYER_STATE.swimming){
	renderable.set_visible(true);
	renderable_billboard.set_visible(false);
}
else{
	renderable.set_visible(false);
	renderable_billboard.set_visible(true);
}