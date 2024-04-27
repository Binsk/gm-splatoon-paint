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

// To make things less convoluted, this check only checks the first collision
// of each instance.
function get_line_collision_array(point_from, point_to){
	var dir = vector3_format_struct(point_to.x - point_from.x, point_to.y - point_from.y, point_to.z - point_from.z);
	var length = vector3_magnitude(dir);
	dir = vector3_normalize(dir);
	var ray = ray_format_struct(point_from.x, point_from.y, point_from.z, dir.x, dir.y, dir.z);
	var array = [];
	
	for (var i = 0; i < ds_list_size(physics_instance_list); ++i){
		var instance = physics_instance_list[| i];
		var renderable = instance.renderable;
		if (is_undefined(renderable.buffer_collision))
			continue;
		
		var collisions = renderable.get_ray_intersections(ray, true, true);
		
		if (array_length(collisions) > 0){
			var distance = vector3_magnitude(vector3_sub_vector3(collisions[0].intersection, point_from));
			if (distance > length) // Too far away; the ray hit but not our line
				continue;
			
			array_push(array, {
				renderable,
				data : collisions[0]
			});
		}
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