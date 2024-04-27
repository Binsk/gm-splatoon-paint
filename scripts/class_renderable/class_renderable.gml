/// ABOUT
/// The Renderable class is effectively a virtual class that defines what all
/// renderable elements should have at the minimum.
///
/// Inheriting classes will need to create / manage any modified states such as
/// animation, rotation, and the like.

function Renderable() constructor {
    #region PROPERTIES
    static MATRIX_IDENTITY = matrix_build_identity();
    static INDEX_COUNTER = 0;
    index = INDEX_COUNTER++; // Used for quick identification in the renderer
    is_visible = true;
    #endregion
    
    #region METHODS
    function get_index(){
        return index;
    }
    
    function set_visible(visible){
        is_visible = visible;
    }
    
    function get_barycentric_weights(p, a, b, c){
        var v0 = vector3_sub_vector3(b, a);
        var v1 = vector3_sub_vector3(c, a);
        var v2 = vector3_sub_vector3(p, a);
        var d00 = vector3_dot(v0, v0);
        var d01 = vector3_dot(v0, v1);
        var d11 = vector3_dot(v1, v1);
        var d20 = vector3_dot(v2, v0);
        var d21 = vector3_dot(v2, v1);
        var d = d00 * d11 - sqr(d01);
        
        var v = (d11 * d20 - d01 * d21) / d;
        var w = (d00 * d21 - d01 * d20) / d;
        var u = 1.0 - v - w;
        return {
            u, v, w
        }
        
    }
    
    /// @desc   Render the object to the scene.
    function render(){};
    
    /// @desc   Cleans up any dynamic resources that may be tied to this instance.
    function free(){};
    #endregion
}


// Done to generate the static variables for easy access:
var foo = new StaticMesh();
foo.free();
delete foo;

foo = new SplatMesh();
foo.free();
delete foo;

foo = new SplatBlockMesh();
foo.free();
delete foo;

foo = new BillboardMesh();
foo.free();
delete foo;