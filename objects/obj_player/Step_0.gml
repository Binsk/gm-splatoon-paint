/// @description Update Camera
with (obj_camera){
	look_x = other.renderable.position.x;
	look_y = other.renderable.position.y - 1;
	look_z = other.renderable.position.z;
	
	x = other.renderable.position.x + dcos(other.renderable.rotation.y + 180) * 8;
	y = other.renderable.position.y + 4;
	z = other.renderable.position.z - dsin(other.renderable.rotation.y + 180) * 8;
}