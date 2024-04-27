/// ABOUT
/// A static mesh is a simple mesh that has one unchanging render state and has
/// a colidable instance tied to it.
function StaticMesh(x = 0, y = 0, z = 0) : Renderable() constructor{
    #region PROPERTIES
    static VFORMAT = undefined;
    static AXIS_LABEL = ["x", "y", "z"];
    
    position = point_format_struct(x, y, z);
    rotation = point_format_struct(0, 0, 0); // Euler angles (in degrees)
    scale = point_format_struct(1, 1, 1);
    model_matrix = matrix_build_identity();
    model_matrix_inv = matrix_build_identity();
    vbuffer_render = undefined;     // Vertex buffer for rendering to the screen
    	/// @note buffer_collision is NOT used by the physics system; only for paint splats
    buffer_collision = undefined;   // Regular buffer for calculating splat collisions (in the format per-triangle [p1,p2,p3,uv1,uv2,uv3,n])
    texture_render = -1;
    is_model_matrix_changed = true;
    #endregion
    
    #region METHODS
    
    function set_position(x, y, z){
        var data = [x, y, z];
        for (var i = 0; i < 3; ++i){
            if (position[$ AXIS_LABEL[i]] == data[i])
                continue;
            
            position[$ AXIS_LABEL[i]] = data[i];
            is_model_matrix_changed = true;
        }
    }
    
    function set_rotation(x, y, z){
        var data = [x, y, z];
        for (var i = 0; i < 3; ++i){
            if (rotation[$ AXIS_LABEL[i]] == data[i])
                continue;
            
            rotation[$ AXIS_LABEL[i]] = data[i];
            is_model_matrix_changed = true;
        }
    }
    
    function set_scale(x, y, z){
        var data = [x, y, z];
        for (var i = 0; i < 3; ++i){
            if (scale[$ AXIS_LABEL[i]] == data[i])
                continue;
            
            scale[$ AXIS_LABEL[i]] = data[i];
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
    
    function update_matrices(force=false){
        if (not is_model_matrix_changed and not force)
            return;
        
        is_model_matrix_changed = false;
        model_matrix = matrix_build(position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, scale.x, scale.y, scale.z);
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
    
    function generate_collision_buffer(triangle_count){
        if (not is_undefined(buffer_collision))
            buffer_delete(buffer_collision);
        
        buffer_collision = buffer_create(60 * triangle_count, buffer_fixed, 1);
    }
    
    /// @desc   Sets the properties of a triangle in the collision mesh, refered to
    ///         by index.
    function set_collision_triangle(index, p1, p2, p3, uv1, uv2, uv3){
        var triangle_count = buffer_get_size(buffer_collision) / 60;
        if (index >= triangle_count or index < 0) // Out-of-bounds
            return undefined;
        
        var start_byte = index * 60;
            // Vertex coordinates:
        buffer_write_series(buffer_collision, buffer_f32, [p1.x, p1.y, p1.z]);
        buffer_write_series(buffer_collision, buffer_f32, [p2.x, p2.y, p2.z]);
        buffer_write_series(buffer_collision, buffer_f32, [p3.x, p3.y, p3.z]);
            // UV coordinates:
        buffer_write_series(buffer_collision, buffer_f16, [uv1.u, uv1.v]);
        buffer_write_series(buffer_collision, buffer_f16, [uv2.u, uv2.v]);
        buffer_write_series(buffer_collision, buffer_f16, [uv3.u, uv3.v]);
            // Normal
        
        var n = vector3_cross(vector3_sub_vector3(p1, p2), vector3_sub_vector3(p1, p3));
        n = vector3_normalize(n);
        buffer_write_series(buffer_collision, buffer_f32, [n.x, n.y, n.z]);
    }
    
    function get_triangle_points(index){
        if (index < 0 or index >= buffer_get_size(buffer_collision) / 60)
            return undefined;
        
        var start_byte = index * 60;
        buffer_seek(buffer_collision, buffer_seek_start, start_byte);
        var array = buffer_read_series(buffer_collision, buffer_f32, 9);
        return [
            point_format_struct(array[0 + 0], array[1 + 0], array[2 + 0]),
            point_format_struct(array[0 + 3], array[1 + 3], array[2 + 3]),
            point_format_struct(array[0 + 6], array[1 + 6], array[2 + 6])
        ];
    }
    
    function get_triangle_uvs(index){
        if (index < 0 or index >= buffer_get_size(buffer_collision) / 60)
            return undefined;
        
        var start_byte = index * 60 + 36;
        buffer_seek(buffer_collision, buffer_seek_start, start_byte);
        var array = buffer_read_series(buffer_collision, buffer_f16, 6);
        return [
            uv_format_struct(array[0 + 0], array[1 + 0]),
            uv_format_struct(array[0 + 2], array[1 + 2]),
            uv_format_struct(array[0 + 4], array[1 + 4])
        ];
    }
    
    function get_triangle_normal(index){
        if (index < 0 or index >= buffer_get_size(buffer_collision) / 60)
            return undefined;
        
        var start_byte = index * 60 + 36 + 12;
        buffer_seek(buffer_collision, buffer_seek_start, start_byte);
        var array = buffer_read_series(buffer_collision, buffer_f32, 3);
        return vector3_format_struct(array[0], array[1], array[2]);
    }
    
    /// @desc   Returns an array of all triangle collisions w/ the ray.
    ///         The ray should be in world space.
    ///         If 'early_exit' is set to true, only the first intersection is returned
    ///         If 'culling' is set to true, the ray will not collide with the 'back side' of the triangle
    function get_ray_intersections(ray, early_exit=false, culling=false){
		update_matrices();
        var array = [];
        var triangle_count = buffer_get_size(buffer_collision) / 60;
        
            // Convert the ray into local model space for quicker triangle calculations:
        var position_inv = matrix_transform_vertex(model_matrix_inv, ray.position.x, ray.position.y, ray.position.z, 1);
        var direction_inv = matrix_transform_vertex(model_matrix_inv, ray.direction.x, ray.direction.y, ray.direction.z, 0);
        var ray_inv = {
            position : point_format_struct(position_inv[0], position_inv[1], position_inv[2]),
            direction : vector3_normalize(vector3_format_struct(direction_inv[0], direction_inv[1], direction_inv[2])),
        }
        
            // Check against each triangle (SLOW)
        for (var i = 0; i < triangle_count; ++i){
            var tpoints = get_triangle_points(i);
            var tnormal = get_triangle_normal(i);
            var intersection = get_ray_triangle_intersection(ray_inv, tpoints[0], tpoints[1], tpoints[2], tnormal, culling);
            if (is_undefined(intersection))
                continue;

            var tuvs = get_triangle_uvs(i); // UV points of the triangle vertices
                // Calculate UV coord that our ray actually hits:
            var barycentric_weights = get_barycentric_weights(intersection, tpoints[0], tpoints[1], tpoints[2]);
            var uv = {
                u : tuvs[0].u * barycentric_weights.u + tuvs[1].u * barycentric_weights.v + tuvs[2].u * barycentric_weights.w,
                v : tuvs[0].v * barycentric_weights.u + tuvs[1].v * barycentric_weights.v + tuvs[2].v * barycentric_weights.w
            }
            var intersection_world = matrix_transform_vertex(model_matrix, intersection.x, intersection.y, intersection.z, 1);
            
            var data = {
                index : i, // Triangle index
                    // Local to model:
                vertices : tpoints, // Array of triangle vertices
                uvs : tuvs,         // Array of triangle UVs
                normal : tnormal,   // Triangle normal
                intersection_local : intersection,
                    // Local to world:
                intersection : point_format_struct(intersection_world[0], intersection_world[1], intersection_world[2]),    // Point of intersection
                    // UV point of collision:
                uv
            }
            
            array_push(array, data);
            
            if (early_exit)
                break;
        }
        
        return array;
    }
    
    /// @desc   A local convenience function for defining shapes.
    function _add_vertex(buffer, x, y, z, u = 0, v = 0, color=c_white){
        vertex_position_3d(buffer, x, y, z);
        vertex_texcoord(buffer, u, v);
        vertex_color(buffer, color, 1.0);
    }
    
    function free(){
        if (not is_undefined(buffer_collision))
            buffer_delete(buffer_collision);
        
        buffer_collision = -1;
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