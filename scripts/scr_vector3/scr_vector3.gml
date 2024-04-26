/// ABOUT
/// Basic vector functions to make life less hellish. None of these functions
/// work in-place and will always return the new calculated value.

function vector3_format_struct(x, y, z){
	return point_format_struct(x, y, z);
}

/// @desc	Returns the cross product (as a struct) between two vectors:
///	@param	{vector3}	vector1		vector a to multiply (as a struct)
///	@param	{vector3}	vector2		vector b to multiply (as a struct)
function vector3_cross(v1, v2) {
	return vector3_format_struct(v1.y * v2.z - v1.z * v2.y,
								 v1.z * v2.x - v1.x * v2.z,
								 v1.x * v2.y - v1.y * v2.x);
}

/// @desc	Return the dot-product between two vectors:
function vector3_dot(v1, v2){
	return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
}

/// @desc	Subtract vector components
function vector3_sub_vector3(v1, v2){
	return vector3_format_struct(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z);
}


/// @desc	Add vector components.
function vector3_add_vector3(v1, v2){
	return vector3_format_struct(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z);
}

/// @desc	Multiplies components of two vectors directly across.
function vector3_mul_vector3(v1, v2){
	return vector3_format_struct(v1.x * v2.x, v1.y * v2.y, v1.z * v2.z);
}

/// @desc	Multiplies each component of a vector by a scalar.
function vector3_mul_scalar(v1, scalar){
	return vector3_format_struct(v1.x * scalar, v1.y * scalar, v1.z * scalar);
}

function vector3_normalize(v){
	var m = vector3_magnitude(v);
	return vector3_format_struct(v.x / m, v.y / m, v.z / m);
}

function vector3_magnitude(v){
	return sqrt(sqr(v.x) + sqr(v.y) + sqr(v.z));
}

function vector3_rotate(vector, axis, radians) {
	var par = vector3_mul_scalar(axis, vector3_dot(vector, axis) / vector3_dot(axis, axis));
	var perp = vector3_sub_vector3(vector, par);

	if (vector3_magnitude(perp) <= 0) // Nothing to rotate
		return vector;
	
	// Find orth vector:
	var orth = vector3_cross(axis, perp);

	if (vector3_magnitude(orth) <= 0) // Nothing to rotate
		return vector;
	
	// Calculate linear combination:
	var s1 = cos(radians) / vector3_magnitude(perp);
	var s2 = sin(radians) / vector3_magnitude(orth);

	var lin = vector3_add_vector3(vector3_mul_scalar(perp, s1),
								  vector3_mul_scalar(orth, s2));
	lin = vector3_mul_scalar(lin, vector3_magnitude(perp));

	return vector3_add_vector3(lin, par);
}

function vector3_angle_difference(vector1, vector2) {
	vector1 = vector3_normalize(vector1);
	vector2 = vector3_normalize(vector2);
	return arccos(vector3_dot(vector1, vector2));
}