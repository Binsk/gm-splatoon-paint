matrix_set(matrix_view, obj_camera.get_view_matrix());
matrix_set(matrix_projection, obj_camera.get_projection_matrix());

// Render each element in-order:
var loop = ds_list_size(render_instance_list)
for (var i = 0; i < loop; ++i){
	var renderable = render_instance_list[| i];
	if (not renderable.is_visible)
		continue;
	
	renderable.render();
}