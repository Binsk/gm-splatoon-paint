if (not is_undefined(position_previous)){
	var collisions = obj_physics_controller.get_line_collision_array(position_previous, renderable.position);
	if (array_length(collisions) > 0){
		
		var splat_mask_color = (renderable.color == SplatMesh.COLOR_A ? make_color_rgb(128, 0, 0) : make_color_rgb(255, 0, 0));
		
		// Draw ink marks
		for (var i = 0; i < array_length(collisions); ++i){
			var data = collisions[i];
			var surface = data.renderable.surface_splat;
			var cx = surface_get_width(surface) * data.data.uv.u;
			var cy = surface_get_height(surface) * data.data.uv.v;
			
			surface_set_target(surface);
			draw_circle_color(cx, cy, 8, splat_mask_color, splat_mask_color, false);
			surface_reset_target();
		}
		
		instance_destroy();
		return;
	}
}

position_previous = renderable.position;
	