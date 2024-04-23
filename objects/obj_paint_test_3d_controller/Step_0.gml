with (obj_camera){
	y = 12;
	
	var angle = pi * current_time / 2000; // 1 revolution ever 4 seconds
	x = cos(angle) * 32;
	z = -sin(angle) * 32;
}