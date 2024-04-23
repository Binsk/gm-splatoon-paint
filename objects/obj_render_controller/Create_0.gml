/// ABOUT
/// The render controller handles the entire render pipeline and generating the
/// 3D scene. The rendering system is y-up.
///
/// This rendering pipeline is VERY basic and is only as complicated as needed
/// to display this demo. It does no instance culling of any kind and simply
/// renders everything in the rendering list from front to back.

#region PROPERTIES
render_instance_list = ds_list_create(); // List of Renderable instances to render
#endregion

#region METHODS
function add_renderable(renderable){
	// Check that it isn't already in the list; this is potentially slow and could
	// be sped up w/ a hash but it will work for this use case.
	for (var i = ds_list_size(render_instance_list) - 1; i >= 0; --i){
		if (render_instance_list[| i].get_index() == renderable.get_index())
			return;
	}
	
	ds_list_add(render_instance_list, renderable);
}
#endregion

#region INIT
if (instance_number(obj_render_controller) > 1){
	instance_destroy();
	return;
}

instance_create_layer(0, 0, "Instances", obj_camera);
#endregion