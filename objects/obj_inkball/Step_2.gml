if (not is_undefined(position_previous) and not is_undefined(splatshape)){
	var collisions = obj_physics_controller.get_line_collision_array(position_previous, renderable.position);
	if (array_length(collisions) > 0){
		
		// Draw ink marks
		for (var i = 0; i < array_length(collisions); ++i){
			var data = collisions[i];
			var surface = data.renderable.surface_splat;
			splatshape.render(data.renderable, data.data.uv, team_id);
		}
		
		instance_destroy();
		return;
	}
}

position_previous = renderable.position;
	