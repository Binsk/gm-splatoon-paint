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
	return matrix_build_lookat(x, y, z, look_x, look_y, look_z, 0, os_type == os_windows ? -1 : 1, 0);
}

function get_projection_matrix(){
	var fov = 60;
	var aspect = room_width / room_height;
	var znear = 0.01;
	var zfar = 1024;
	var yfov = -2 * arctan(dtan(fov/2) * aspect);
	
	if (os_type = os_windows)
		aspect = -aspect;
	
	var h = 1 / tan(yfov * 0.5);
	var w = h / aspect;
	var a = zfar / (zfar - znear);
	var b = (-znear * zfar) / (zfar - znear);
	var matrix = [
		w, 0, 0, 0,
		0, h, 0, 0,
		0, 0, a, 1,
		0, 0, b, 0
		];
	return matrix;
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