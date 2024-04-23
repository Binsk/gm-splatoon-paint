/// ABOUT
/// A static mesh is a simple mesh that has one unchanging render state.
function StaticMesh(x = 0, y = 0, z = 0) : Renderable() constructor{
    #region PROPERTIES
    static VFORMAT = undefined;
    
    position = [x, y, z];
    rotation = [0, 0, 0]; // Euler angles (in degrees)
    scale = [1, 1, 1];
    model_matrix = matrix_build_identity();
    model_matrix_inv = matrix_build_identity();
    vbuffer_render = undefined;     // Vertex buffer for rendering to the screen
    buffer_collision = undefined;   // Regular buffer for calculating collisions
    texture_render = -1;
    is_model_matrix_changed = true;
    #endregion
    
    #region METHODS
    
    function set_position(x, y, z){
        var data = [x, y, z];
        for (var i = 0; i < 3; ++i){
            if (position[i] == data[i])
                continue;
            
            position[i] = data[i];
            is_model_matrix_changed = true;
        }
    }
    
    function set_rotation(x, y, z){
        var data = [x, y, z];
        for (var i = 0; i < 3; ++i){
            if (rotation[i] == data[i])
                continue;
            
            rotation[i] = data[i];
            is_model_matrix_changed = true;
        }
    }
    
    function set_scale(x, y, z){
        var data = [x, y, z];
        for (var i = 0; i < 3; ++i){
            if (scale[i] == data[i])
                continue;
            
            scale[i] = data[i];
            is_model_matrix_changed = true;
        }
    }
    
    function set_render_mesh(mesh){
        vbuffer_render = mesh;
    }
    
    function set_collision_mesh(mesh){
        buffer_collision = mesh;
    }
    
    function set_texture(texture){
        texture_render = texture;
    }
    
    function update_matrices(){
        if (not is_model_matrix_changed)
            return;
        
        model_matrix = matrix_build(position[0], position[1], position[2], rotation[0], rotation[1], rotation[2], scale[0], scale[1], scale[2]);
        model_matrix_inv = matrix_get_inverse(model_matrix);
    }
    
    function render(){
        update_matrices();
        if (is_undefined(vbuffer_render))
            return;
        
        matrix_set(matrix_world, model_matrix);
        vertex_submit(vbuffer_render, pr_trianglelist, texture_render);
        matrix_set(matrix_world, Renderable.MATRIX_IDENTITY);
    }
    
    /// @desc   A local convenience function for defining shapes.
    function _add_vertex(buffer, x, y, z, u = 0, v = 0, color=c_white){
        vertex_position_3d(buffer, x, y, z);
        vertex_texcoord(buffer, u, v);
        vertex_color(buffer, color, 1.0);
    }
    #endregion
    
    #region INIT
    if (is_undefined(VFORMAT)){
        vertex_format_begin();
        vertex_format_add_position_3d();
        vertex_format_add_texcoord();
        vertex_format_add_color();
        
        VFORMAT = vertex_format_end();
    }
    #endregion
}

// Done to generate the VFORMAT value for easy static calls
var foo = new StaticMesh();
delete foo;