/// ABOUT
/// The collidable class is a simple class for specifying an AABB collidable shape
///	and detecting collisions w/ other Collidable shapes. Collidable shapes have no
/// position and are attached to mesh class to pull position / scale from
function Collidable(point_min, point_max, renderable=undefined) constructor {
	#region PROPERTIES
	static INDEX_COUNTER = 0;
    index = INDEX_COUNTER++; // Used for quick identification in the renderer
	self.renderable = undefined;
	self.point_min = point_min;
	self.point_max = point_max;
	
	#region METHODS
	function get_index(){
        return index;
    }
	function set_renderable(renderable){
		if (is_undefined(renderable[$ "position"]))
			throw "Invalid renderable instance specified!";
		
		self.renderable = renderable;
	}
	
	/// @desc	Checks if this instance is intersectinhg collidable. This does NOT
	///			check if collidable is fully enveloped by this instance for the sake
	///			of speed.
	function get_is_aabb_intersection(collidable){
		var a = [get_point_min(), get_point_max()];
		var b = [collidable.get_point_min(), collidable.get_point_max()];
		
		for (var i = 0; i < 3; ++i){
			if (a[0][$ StaticMesh.AXIS_LABEL[i]] <= b[0][$ StaticMesh.AXIS_LABEL[i]] and a[1][$ StaticMesh.AXIS_LABEL[i]] <= b[0][$ StaticMesh.AXIS_LABEL[i]])
				return false;
			
			if (a[0][$ StaticMesh.AXIS_LABEL[i]] >= b[1][$ StaticMesh.AXIS_LABEL[i]] and a[1][$ StaticMesh.AXIS_LABEL[i]] >= b[1][$ StaticMesh.AXIS_LABEL[i]])
				return false;
		}
		
		return true;
	}
	
	/// @desc	Returns the vector required to push the collidable outside  this instance.
	///			This does NOT check for intersection; so it is assumed there is a collision!
	function get_push_vector(collidable){
		var a = [get_point_min(), get_point_max()];
		var b = [collidable.get_point_min(), collidable.get_point_max()];
		var vector_priority = ds_priority_create();

		if (a[0].x < b[1].x)
			ds_priority_add(vector_priority, vector3_format_struct(a[0].x - b[1].x, 0, 0), abs(a[0].x - b[1].x));
		
		if (a[0].y < b[1].y)
			ds_priority_add(vector_priority, vector3_format_struct(0, a[0].y - b[1].y, 0), abs(a[0].y - b[1].y));
		
		if (a[0].z < b[1].z)
			ds_priority_add(vector_priority, vector3_format_struct(0, 0, a[0].z - b[1].z), abs(a[0].z - b[1].z));
			
		if (a[1].x > b[0].x)
			ds_priority_add(vector_priority, vector3_format_struct(a[1].x - b[0].x, 0, 0), abs(a[1].x - b[0].x));
		
		if (a[1].y > b[0].y)
			ds_priority_add(vector_priority, vector3_format_struct(0, a[1].y - b[0].y, 0), abs(a[1].y - b[0].y));
		
		if (a[1].z > b[0].z)
			ds_priority_add(vector_priority, vector3_format_struct(0, 0, a[1].z - b[0].z), abs(a[1].z - b[0].z));

		var vector = vector3_format_struct(0, 0, 0);
		if (not ds_priority_empty(vector_priority))
			vector = ds_priority_find_min(vector_priority);
		
		ds_priority_destroy(vector_priority);
		
		return vector;
	}
	
	function get_point_min(){
		if (is_undefined(renderable))
			return point_min;
		
		return vector3_add_vector3(renderable.position, vector3_mul_vector3(point_min, renderable.scale));
	}
	
	function get_point_max(){
		if (is_undefined(renderable))
			return point_max;
		
		return vector3_add_vector3(renderable.position, vector3_mul_vector3(point_max, renderable.scale));
	}
	
	function toString(){
		return "Collidable: " + string(get_index());
	}
	#endregion
	
	#region INIT
	if (not is_undefined(renderable))
		set_renderable(renderable);
	#endregion
}