/// ABOUT
/// Ink data has a bit of a 'magic number' element to it so, to make things easier
/// to understand and organize, it has been added into a few functions to go
/// from a team index to the relevant data.
/// Team 0 = "Clear data" (or 'no team')
/// Team 1 = "Team A"
/// Team 2 = "Team B"
///
/// Much of these magic numbers could easily be modified / expanded to support
/// more than 2 teams. You would simply need to modify the magic values here and
/// compensate in the shd_render_splat

// @desc	Returns the GameMaker color given the team id. Invalid IDs return -1.
function ink_get_color(team_id){
	if (team_id == 1)
		return SplatMesh.COLOR_A;
	if (team_id == 2)
		return SplatMesh.COLOR_B;
	
	return -1;
}

/// @desc	Sets the color for a team index; returns if successful.
function ink_set_color(team_id, color){
	if (team_id == 0){
		SplatMesh.COLOR_A = color;
		return true;
	}
	if (team_id == 1){
		SplatMesh.COLOR_B = color;
		return true;
	}
	return false;
}

/// @desc	Returns the shader mask for the specified team. Invalid IDs return 0.
function ink_get_mask(team_id){
	// Masks are chosen for easy math + enough distance to avoid precision problems.
	// In the shader we get ceil(mask / 128.f)
	if (team_id == 1)
		return 128;
	if (team_id == 2)
		return 255;
	
	return 0;
}

/// @desc	The same as ink_get_mask() only it is the format of a GameMaker color
function ink_get_mask_color(team_id){
	return make_color_rgb(ink_get_mask(team_id), 0, 0);
}

/// @desc	Given a shader / buffer team mask, it returns the team index.
function ink_get_team_from_mask(mask){
	return ceil(mask / 128);
}