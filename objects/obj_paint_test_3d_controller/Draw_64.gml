var mx = mouse_x;
var my = mouse_y;
var preview_size = 386; // Size of texture preview
if (surface_exists(cube.surface_splat)){ // Render splat preview UV map
	var team_color_a = ink_get_color(1);
	var team_color_b = ink_get_color(2);
	shader_set(shd_render_splat);
	shader_set_uniform_f(SplatMesh.SHADER_U_FCOLORA, 1.0 / 255 * color_get_red(team_color_a), 
										   1.0 / 255 * color_get_green(team_color_a),
										   1.0 / 255 * color_get_blue(team_color_a));
	shader_set_uniform_f(SplatMesh.SHADER_U_FCOLORB, 1.0 / 255 * color_get_red(team_color_b), 
										   1.0 / 255 * color_get_green(team_color_b),
										   1.0 / 255 * color_get_blue(team_color_b));
	texture_set_stage(SplatMesh.SHADER_U_TEAMDATA, surface_get_texture(cube.surface_splat));
	draw_sprite_stretched(spr_block, 0, 0, room_height - preview_size, preview_size, preview_size);
	shader_reset();
}

draw_circle_color(mx, my, 32, c_lime, c_lime, true); // Render 'cursor'

var mouse_ray = screen_to_ray(mx, room_height - my, matrix_get_inverse(obj_camera.get_view_matrix()), matrix_get_inverse(obj_camera.get_projection_matrix()));

draw_text_color(12, 12, "Mouse: " + string(mx) +" x " + string(my), c_white, c_white, c_white, c_white, 1.0);
draw_text_color(12, 12, "\nRay: " + string(mouse_ray), c_white, c_white, c_white, c_white, 1.0);
draw_text_color(12, 12, "\n\nCam: " + string(obj_camera.x) +" x " + string(obj_camera.y) + " x " + string(obj_camera.z), c_white, c_white, c_white, c_white, 1.0);

var splat_mask_color = undefined;

	// Determine if we are painting a splat and for which team
if (mouse_check_button(mb_left) or mouse_check_button_released(mb_left))
	splat_mask_color = ink_get_mask_color(1);
else if (mouse_check_button(mb_right) or mouse_check_button_released(mb_right))
	splat_mask_color = ink_get_mask_color(2);
	
if (is_undefined(splat_mask_color))
	return;

var collisions = cube.get_ray_intersections(mouse_ray, true, true);
var collision = undefined;
if (array_length(collisions) > 0){
	var closest_index = -1;
	var closest_distance = infinity;
	// Determine which collision is closest (if > 1)
	for (var i = 0; i < array_length(collisions); ++i){
		var distance = point_distance_3d(obj_camera.x, obj_camera.y, obj_camera.z, collisions[i].intersection.x, collisions[i].intersection.y, collisions[i].intersection.z);
		if (distance < closest_distance){
			closest_distance = distance;
			closest_index = i;
		}
	}
	
	collision = collisions[closest_index];
	
	// Render some debugging info:
	draw_text_color(12, 12, "\n\n\n  Triangle Index: " + string(collision.index) + " : " + string(collision.intersection), c_white, c_white, c_white, c_white, 1.0)
	draw_text_color(12, 12, "\n\n\n\n  Collision UV: " + string(collision.uv), c_white, c_white, c_white, c_white, 1.0);
}

// Handle paint splatter application:
if (is_undefined(collision) and mouse_x < preview_size and mouse_y > room_height - preview_size) // Allow painting on the preview
	collision = {
		uv : {
			u : mouse_x / preview_size,
			v : (mouse_y - (room_height - preview_size)) / preview_size
		}
	};
	
if (not is_undefined(collision) and surface_exists(cube.surface_splat)){
	surface_set_target(cube.surface_splat);
	draw_circle_color(collision.uv.u * surface_get_width(cube.surface_splat), collision.uv.v * surface_get_height(cube.surface_splat), 16, splat_mask_color, splat_mask_color, false);
	surface_reset_target();
}