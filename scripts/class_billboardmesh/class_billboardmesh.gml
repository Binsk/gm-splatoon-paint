/// ABOUT
/// Opted to make this design specifically for ink billboards since there was
/// no plan to have other billboarded elements. If more are to come about then
/// this should likely be converted to a more generic billboard system.
function BillboardMesh(x = 0, y = 0, z = 0, color=c_white, scale=1.0) : Renderable() constructor{
	#region PROPERTIES
	static MESH = undefined;
	static VFORMAT = undefined;
	static SHADER_U_FSCALE = shader_get_uniform(shd_billboard_ink, "u_fScale");
	static SHADER_U_VCOLOR = shader_get_uniform(shd_billboard_ink, "u_vColor");
	
	texture_render = -1;
	position = point_format_struct(x, y, z);
	self.scale = scale;
	self.color = color;
	model_matrix = matrix_build_identity();
	is_model_matrix_changed = true;
	#endregion
	
	#region METHODS
	function set_position(x, y, z){
        var data = [x, y, z];
        for (var i = 0; i < 3; ++i){
            if (position[$ StaticMesh.AXIS_LABEL[i]] == data[i])
                continue;
            
            position[$ StaticMesh.AXIS_LABEL[i]] = data[i];
            is_model_matrix_changed = true;
        }
    }
    
    function set_texture(texture){
        texture_render = texture;
    }
    
    function update_matrices(){
        if (not is_model_matrix_changed)
            return;
        
        is_model_matrix_changed = false;
        model_matrix = matrix_build(position.x, position.y, position.z, 0, 0, 0, 1, 1, 1);
    }
    
    function _add_vertex(buffer, x, y, u = 0, v = 0){
        vertex_position(buffer, x, y);
        vertex_texcoord(buffer, u, v);
    }
    
	function render(){
		update_matrices();
		gpu_set_cullmode(cull_noculling);
		shader_set(shd_billboard_ink);
		shader_set_uniform_f(SHADER_U_FSCALE, scale);
		shader_set_uniform_f(SHADER_U_VCOLOR, 1 / 255 * color_get_red(color), 1 / 255 * color_get_green(color), 1 / 255 * color_get_blue(color));
		matrix_set(matrix_world, model_matrix);
		vertex_submit(MESH, pr_trianglelist, texture_render);
		matrix_set(matrix_world, Renderable.MATRIX_IDENTITY);
		shader_reset();
	}
	#endregion
	
	#region INIT
	if (is_undefined(VFORMAT)){
        vertex_format_begin();
        vertex_format_add_position();
        vertex_format_add_texcoord();
        VFORMAT = vertex_format_end();
    }
	
	if (is_undefined(MESH)){
		MESH = vertex_create_buffer();
		vertex_begin(MESH, BillboardMesh.VFORMAT);
		_add_vertex(MESH, -0.5, -0.5, 0, 0);
		_add_vertex(MESH, +0.5, -0.5, 1, 0);
		_add_vertex(MESH, -0.5, +0.5, 0, 1);
		
		_add_vertex(MESH, +0.5, -0.5, 1, 0);
		_add_vertex(MESH, +0.5, +0.5, 1, 1);
		_add_vertex(MESH, -0.5, +0.5, 0, 1);
		vertex_end(MESH);
	}
	#endregion
}