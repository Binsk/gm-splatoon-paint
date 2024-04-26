function SplatBlockMesh(x = 0, y = 0, z = 0, splat_resolution=512) : SplatMesh(x, y, z, splat_resolution) constructor {
	#region PROPERTIES
	static MESH = undefined; // Default mesh and collision for testing
	static COLLISION = undefined;
	#endregion
	
	#region METHODS
	/// @note	We override the parent free so it doesn't free the render/collision
	///			data due to it being shared between all SplatBlockMesh instances.
	function free(){
		if (surface_exists(surface_splat))
			surface_free(surface_splat);
			
		surface_splat = -1;
	}
	
	function set_render_mesh(){
		throw "cannot change render mesh of SplatBlockMesh instance!";
	}
	#endregion
	
	#region INIT
	// Define the basic cube mesh:
	if (is_undefined(MESH)){
		MESH = vertex_create_buffer();
		vertex_begin(MESH, StaticMesh.VFORMAT);
		
			// Positions, when look towards the surface, start top-left
		var position_array = [
			[-0.5, +0.5, +0.5],	// Southern wall
			[+0.5, +0.5, +0.5],	// Eastern wall
			[+0.5, +0.5, -0.5],	// Northern wall
			[-0.5, +0.5, -0.5],	// Western wall
			
			[-0.5, +0.5, -0.5],	// Cap
			[-0.5, -0.5, +0.5]	// Base
		];
		
			// Vectors defining the local x/y axes
		var vectorx_array = [
			[+1, +0, +0],		// Southern wall
			[+0, +0, -1],		// Eastern wall
			[-1, +0, +0],		// Northern wall
			[+0, +0, +1],		// Western wall
			
			[+1, +0, +0],		// Cap
			[+1, +0, +0]		// Base
		];
		
		var vectory_array = [
			[+0, -1, +0],		// Southern wall
			[+0, -1, +0],		// Eastern wall
			[+0, -1, +0],		// Northern wall
			[+0, -1, +0],		// Western wall
			
			[+0, +0, +1],		// Cap
			[+0, +0, -1]		// Base
		];
		
			// Base UV positions and their relative x/y coordinates:
		var uvposition_array = [
			[0.25, 0.50],		// Southern wall
			[0.50, 0.50],		// Eastern wall
			[0.50, 0.25],		// Northern wall
			[0.25, 0.25],		// Western wall
			
			[0.25, 0.25],		// Cap
			[1.00, 0.25]		// Base
		];
		
		var uvx_array = [
			[+0.25, +0.00],
			[+0.00, -0.25],
			[-0.25, +0.00],
			[+0.00, +0.25],
			
			[+0.25, +0.00],
			[+0.00, +0.25]
		];
		
		var uvy_array = [
			[+0.00, +0.25],
			[+0.25, +0.00],
			[+0.00, -0.25],
			[-0.25, +0.00],
			
			[+0.00, +0.25],
			[-0.25, +0.00]
		];
		
		for (var i = 0; i < 6; ++i){
			var position = position_array[i];
			var vectorx = vectorx_array[i];
			var vectory = vectory_array[i];
			var color = c_white;
			var uv = uvposition_array[i];
			var uv_x = uvx_array[i];
			var uv_y = uvy_array[i];
			
			_add_vertex(MESH, position[0], position[1], position[2], uv[0], uv[1], color);
			_add_vertex(MESH, position[0] + vectorx[0], position[1] + vectorx[1], position[2] + vectorx[2], uv[0] + uv_x[0], uv[1] + uv_x[1], color);
			_add_vertex(MESH, position[0] + vectory[0], position[1] + vectory[1], position[2] + vectory[2], uv[0] + uv_y[0], uv[1] + uv_y[1], color);
			
			_add_vertex(MESH, position[0] + vectorx[0], position[1] + vectorx[1], position[2] + vectorx[2], uv[0] + uv_x[0], uv[1] + uv_x[1], color);
			_add_vertex(MESH, position[0] + vectorx[0] + vectory[0], position[1] + vectorx[1] + vectory[1], position[2] + vectorx[2] + vectory[2], uv[0] + uv_x[0] + uv_y[0], uv[1] + uv_x[1] + uv_y[1], color);
			_add_vertex(MESH, position[0] + vectory[0], position[1] + vectory[1], position[2] + vectory[2], uv[0] + uv_y[0], uv[1] + uv_y[1], color);
		}
		
		vertex_end(MESH);
		
		// COLLISION = buffer_create(2 * 60, buffer_fixed, 1);
		// buffer_collision = COLLISION; // Done so we can use the triangle set functions
		generate_collision_buffer(12);
		
		for (var i = 0; i < 6; ++i){
			var position = position_array[i];
			var vectorx = vectorx_array[i];
			var vectory = vectory_array[i];
			var uv = uvposition_array[i];
			var uv_x = uvx_array[i];
			var uv_y = uvy_array[i];
			
			var p1 = point_format_struct(position[0], position[1], position[2]);
			var p2 = point_format_struct(position[0] + vectorx[0], position[1] + vectorx[1], position[2] + vectorx[2]);
			var p3 = point_format_struct(position[0] + vectory[0], position[1] + vectory[1], position[2] + vectory[2]);
			var p4 = point_format_struct(position[0] + vectorx[0] + vectory[0], position[1] + vectorx[1] + vectory[1], position[2] + vectorx[2] + vectory[2]);
			var uv1 = uv_format_struct(uv[0], uv[1]);
			var uv2 = uv_format_struct(uv[0] + uv_x[0], uv[1] + uv_x[1]);
			var uv3 = uv_format_struct(uv[0] + uv_y[0], uv[1] + uv_y[1]);
			var uv4 = uv_format_struct(uv[0] + uv_x[0] + uv_y[0], uv[1] + uv_x[1] + uv_y[1]);
			
			set_collision_triangle(i * 2, p1, p2, p3, uv1, uv2, uv3);
			set_collision_triangle(i * 2 + 1, p2, p4, p3, uv2, uv4, uv3);
		}
		
		COLLISION = buffer_collision;
	}
	
	vbuffer_render = MESH;
	buffer_collision = COLLISION;
	#endregion
}