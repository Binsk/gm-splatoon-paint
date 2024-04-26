/// @desc	Takes simple ray data and returns it in struct form for
///			easier argument passing.
function ray_format_struct(x, y, z, dx, dy, dz){
	return {
		position : point_format_struct(x, y, z),
		direction : point_format_struct(dx, dy, dz)
	};
}

function uv_format_struct(u, v){
	return {
		u, v
	}
}

function point_format_struct(x, y, z){
	return {
		x, y, z
	};
}

/// @desc	Returns the point of collision on the specified plane given a ray,
///			or undefined if no collision occurs.
/// @param	{ray}		ray		ray to check collisions with
/// @param	{point}		origin	origin point of the plane
/// @param	{vector3}	normal	normal vector of the plane
/// @param	{bool} culling? whether or not to cull back-face ray checks
function get_ray_plane_intersection(ray, origin, normal, culling=false){
	var dot_direction = vector3_dot(normal, ray.direction);
	var dot_location = -vector3_dot(normal, vector3_sub_vector3(ray.position, origin));
	
	// Check if parallel (where no collision would occur)
	if (abs(dot_direction) < 0.00001)
		return undefined;
	
	if (culling and dot_direction < 0)
		return undefined;
	
	// Check if we are behind the plane and pointing away:
	var d = dot_location / dot_direction;
	if (d < 0)
		return undefined;
	
	
	var delta = vector3_mul_scalar(ray.direction, d);
	return vector3_add_vector3(ray.position, delta);
}

/// @desc	Given a ray and three points that form a triangle, retruns
///			the point of collision (or undefined of none)
/// @param	{ray}	ray		ray to check collisions with
/// @param	{point} p1		first point of the triangle
/// @param	{point} p2		second point of the triangle
/// @param	{point} p3		third point of the triangle
/// @param	{vector3} n?	normal of the triangle; if unspecified it is auto-calculated
/// @param	{bool} culling? whether or not to cull back-face ray checks
function get_ray_triangle_intersection(ray, p1, p2, p3, n=undefined, culling=false){
	// Calculate the normal if needed
	if (is_undefined(n)){
		n = vector3_cross(vector3_sub_vector3(p1, p2), vector3_sub_vector3(p3, p2));
		n = vector3_normalize(n);
	}
	
	// First check for basic plane intersection:
	var point_intersection = get_ray_plane_intersection(ray, p1, n, culling);
	if (is_undefined(point_intersection))
		return undefined;
	
	// Check that our collision falls within the bounds of the triangle:
		// Edge 1
	var point = vector3_sub_vector3(point_intersection, p1);
	var cross = vector3_cross(vector3_sub_vector3(p2, p1), point);
	if (vector3_dot(n, cross) < 0)
		return undefined;
	
		// Edge 2
	point = vector3_sub_vector3(point_intersection, p2);
	cross = vector3_cross(vector3_sub_vector3(p3, p2), point);
	if (vector3_dot(n, cross) < 0)
		return undefined;
		
		// Edge 3
	point = vector3_sub_vector3(point_intersection, p3);
	cross = vector3_cross(vector3_sub_vector3(p1, p3), point);
	if (vector3_dot(n, cross) < 0)
		return undefined;
	
	return point_intersection;
}

/// @desc	Takes a screen-space point and converts it into a world-space ray.
function screen_to_ray(x, y, matrix_view_inv, matrix_projection_inv){
	var px = (x / room_width)  * 2.0 - 1.0;
	var py = (1.0 - y / room_height)  * 2.0 - 1.0;
	
	if (os_type == os_windows)
		py = -py;
	
	var point_far = matrix_transform_vertex(matrix_projection_inv, px, py, 1, 1);
	var point_near = matrix_transform_vertex(matrix_projection_inv, px, py, 0, 1);

	// Undo the w component
	for (var i = 0; i < 3; ++i){
		point_far[i] /= point_far[3];
		point_near[i] /= point_near[3];
	}
	
	point_far = matrix_transform_vertex(matrix_view_inv, point_far[0], point_far[1], point_far[2], 1);
	point_near = matrix_transform_vertex(matrix_view_inv, point_near[0], point_near[1], point_near[2], 1);
	
	var vector_direction = vector3_format_struct(point_far[0] - point_near[0], point_far[1] - point_near[1], point_far[2] - point_near[2]);
	vector_direction = vector3_normalize(vector_direction);

	return ray_format_struct(point_near[0], point_near[1], point_near[2], vector_direction.x, vector_direction.y, vector_direction.z);
}

function point_in_aabb(point, point_min, point_max){
	if (clamp(point.x, point_min.x, point_max.x) != point.x)
		return false;
	
	if (clamp(point.z, point_min.z, point_max.z) != point.z)
		return false;
	
	if (clamp(point.y, point_min.y, point_max.y) != point.y)
		return false;
		
	return true;
}