/// ABOUT
/// The 3D camera that is used by the render controller. This is only an object
/// in order to simplify more complex camera motions.
#region PROPERTIES
x = 0;
y = 0;
z = 0;

look_x = 0;
look_y = 0;
look_z = 0;
#endregion

#region METHODS
function get_view_matrix(){
	return matrix_build_lookat(x, y, z, look_x, look_y, look_z, 0, 1, 0);
}

function get_projection_matrix(){
	return matrix_build_projection_perspective_fov(os_type != os_windows ? -60 : 60, room_width / room_height, 0.01, 1024);
}
#endregion

#region INIT
// Only allow one instance of this object
if (instance_number(obj_camera) > 1){
	instance_destroy();
	return;
}

gpu_set_cullmode(cull_counterclockwise);
gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
#endregion