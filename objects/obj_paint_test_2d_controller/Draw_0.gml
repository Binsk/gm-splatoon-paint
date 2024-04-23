// We create a surface that simply spans the whole room for this test
if (not surface_exists(surface_splat)){
    surface_splat = surface_create(room_width, room_height, surface_r8unorm);
    surface_set_target(surface_splat);
    draw_clear_alpha(0, 0);
    surface_reset_target();
}

/// @note	We assume that the splat sprite (or in this case circle) alpha values
///			are always either 0 or 1. Anything inbetween will break the blend.

/// @note	Much of this is over-the-top to make the effect look more like a splatter.
///			Simply calling draw_circle_color() with the splat_mask_color is enough
///			to create a splatter on the surface.
var splat_mask_color = undefined;

	// Determine if we are painting a splat and for which team
if (mouse_check_button(mb_left) or mouse_check_button_released(mb_left))
	splat_mask_color = make_color_rgb(128, 0, 0); // 128 equates to 'team 1' in the shader
else if (mouse_check_button(mb_right) or mouse_check_button_released(mb_right))
	splat_mask_color = make_color_rgb(255, 0, 0); // 255 equates to 'team 2' in the shader

if (not is_undefined(splat_mask_color)){
	surface_set_target(surface_splat);
	var radius = irandom_range(24, 48); // Random center splat size
		// Calculate mouse movement direction so we actually 'stroke' the splat across the surface:
	var distance = point_distance(mouse_x, mouse_y, mouse_x_last, mouse_y_last);
	
	if (mouse_check_button_pressed(mb_any) or distance >= 1) // Only draw init splat if just pressed or the mouse moved
		draw_circle_color(mouse_x, mouse_y, radius, splat_mask_color, splat_mask_color, false);
	
	#region EXTRA SPLATTER
	
	// If a long stroke, fill the empty space to make it look like a 'stroke'
	if (distance > radius){
		draw_circle_color(mouse_x_last, mouse_y_last, radius, splat_mask_color, splat_mask_color, false); // Draw at the 'start' of the stroke
		var rotation = point_direction(mouse_x_last, mouse_y_last, mouse_x, mouse_y)
			// Draw a rectangle between the two main splatter marks; we use a matrix to rotate the shape easily
		matrix_set(matrix_world, matrix_build(mouse_x_last, mouse_y_last, 0, 0, 0, rotation, 1.0, 1.0, 1.0))
		draw_rectangle_color(0, -radius, distance, radius, splat_mask_color, splat_mask_color, splat_mask_color, splat_mask_color, false);
		matrix_set(matrix_world, matrix_build_identity());
	}
	
	// For the fun of it, add some miscelanious 'splat marks' to make it look sike extra splatter
	if (mouse_check_button_pressed(mb_any) or mouse_check_button_released(mb_any) or distance > radius){
		var count = irandom_range(1, 6);
		for (var i = 0; i < count; ++i){
			var theta = random(pi * 2);
			var splat_radius = irandom_range(6, 12);
			distance = radius + splat_radius + irandom_range(-4, 12);
			draw_circle_color(mouse_x + cos(theta) * distance, mouse_y - sin(theta) * distance, splat_radius, splat_mask_color, splat_mask_color, false);
		}
	}
	#endregion
	surface_reset_target();
}

mouse_x_last = mouse_x; // Update our mouse coordinates for the next stroke
mouse_y_last = mouse_y;

// Set our splat shader so it knows how to interpret the colors
shader_set(shd_render_splat);
shader_set_uniform_f(shader_u_fcolora, 1.0 / 255 * color_get_red(color_a), 
									   1.0 / 255 * color_get_green(color_a),
									   1.0 / 255 * color_get_blue(color_a));
shader_set_uniform_f(shader_u_fcolorb, 1.0 / 255 * color_get_red(color_b), 
									   1.0 / 255 * color_get_green(color_b),
									   1.0 / 255 * color_get_blue(color_b));
texture_set_stage(shader_u_steamdata, surface_get_texture(surface_splat));
draw_surface(surface_splat, 0, 0); // Surface here not really used; overlayed by second sampler
shader_reset();