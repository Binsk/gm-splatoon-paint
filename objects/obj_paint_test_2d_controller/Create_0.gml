/// ABOUT
/// This object is a simple 2D test object to test the splat painting shader.
/// Left-click somewhere to paint `color_a` and right-click somewhere to paint
/// `color_b`

#region PROPERTIES
surface_splat = -1; // Surface used to store splat indices + alpha
color_a = c_orange;	// Team colors; can be any color
color_b = c_purple;

shader_u_fcolora = shader_get_uniform(shd_render_splat, "u_vColorA");
shader_u_fcolorb = shader_get_uniform(shd_render_splat, "u_vColorB");
shader_u_steamdata = shader_get_sampler_index(shd_render_splat, "u_sTeamData");

mouse_x_last = mouse_x; // Used for rendering 'strokes' between splats
mouse_y_last = mouse_y;
#endregion
