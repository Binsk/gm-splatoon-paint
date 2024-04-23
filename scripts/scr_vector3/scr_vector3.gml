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
	return vector3_format_struct(v1.y * v1.z - v1.z * v1.y,
								 v1.z * v1.x - v1.x * v1.z,
								 v1.x * v1.y - v1.y * v1.x);
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