/// ABOUT
/// A SplatMesh is a static mesh that can have ink dynamically splatted on its
/// surface. This requires significantly more RAM/vRAM.
function SplatMesh(x = 0, y = 0, z = 0, splat_resolution=512) : StaticMesh(x, y, z) constructor{
	#region PROPERTIES
	static SHADER_U_FCOLORA = shader_get_uniform(shd_render_splat, "u_vColorA");
	static SHADER_U_FCOLORB = shader_get_uniform(shd_render_splat, "u_vColorB");
	static SHADER_U_TEAMDATA = shader_get_sampler_index(shd_render_splat, "u_sTeamData");
	static COLOR_A = c_orange;
	static COLOR_B = c_purple;
	
	surface_splat = -1;	// A surface of splat info in vRAM
	buffer_splat = -1;	// Regular RAM copy of surface_splat for sampling / regen
	
	p_free = free;
	#endregion
	
	#region METHODS
	function free(){
		p_free();
		if (surface_exists(surface_splat))
			surface_free(surface_splat);
			
		surface_splat = -1;
		
		buffer_delete(buffer_splat);
		buffer_splat = undefined;
	}
	
	function render(){
		update_matrices();
		if (is_undefined(vbuffer_render))
			return;

		matrix_set(matrix_world, model_matrix);
		
		if (not surface_exists(surface_splat)){
			var resolution = sqrt(buffer_get_size(buffer_splat));
			surface_splat = surface_create(resolution, resolution, surface_r8unorm);
			buffer_set_surface(buffer_splat, surface_splat, 1);
		}
		
		shader_set(shd_render_splat);
		shader_set_uniform_f(SHADER_U_FCOLORA,	1.0 / 255 * color_get_red(COLOR_A),
												1.0 / 255 * color_get_green(COLOR_A),
												1.0 / 255 * color_get_blue(COLOR_A));	
		shader_set_uniform_f(SHADER_U_FCOLORB,	1.0 / 255 * color_get_red(COLOR_B),
												1.0 / 255 * color_get_green(COLOR_B),
												1.0 / 255 * color_get_blue(COLOR_B));
		texture_set_stage(SHADER_U_TEAMDATA, surface_get_texture(surface_splat));
		vertex_submit(vbuffer_render, pr_trianglelist, texture_render);
		shader_reset();
		
		matrix_set(matrix_world, Renderable.MATRIX_IDENTITY);
	}
	#endregion
	
	#region INIT
		// The +1 gets around a small GM bug where == size to surface will fail to set
	buffer_splat = buffer_create(sqr(splat_resolution) + 1, buffer_fixed, 1);
	buffer_fill(buffer_splat, 0, buffer_u8, 0, sqr(splat_resolution));
	#endregion
}