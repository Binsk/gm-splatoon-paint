/// ABOUT
/// The physics system is designed for testing and such is very naive and will
/// process everything w/o any culling. The purpose of the physics is just to
/// help determine basic AABB collisions between the player and the world for
/// paint testing.

#region PROPERTIES
physics_instance_list = ds_list_create();
#endregion

#region METHODS
function add_collidable(collidable){
	// Check that it isn't already in the list; this is potentially slow and could
	// be sped up w/ a hash but it will work for this use case.
	for (var i = ds_list_size(physics_instance_list) - 1; i >= 0; --i){
		if (physics_instance_list[| i].get_index() == collidable.get_index())
			return;
	}
	
	ds_list_add(physics_instance_list, collidable);
}

/// @desc	Returns an array of instances the specified collidable is intersecting
///			with. Simply scans all physics instances in the system.
function get_intesection_array(collidable){
	var array = [];
	for (var i = 0; i < ds_list_size(physics_instance_list); ++i){
		var instance = physics_instance_list[| i];
		if (instance.get_index() == collidable.get_index())
			continue;
			
		if (collidable.get_is_aabb_intersection(instance))
			array_push(array, instance);
	}
	
	return array;
}
#endregion

#region INIT
if (instance_number(obj_physics_controller) > 1){
	instance_destroy();
	return;
}
#endregion