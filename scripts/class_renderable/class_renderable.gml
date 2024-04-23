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
    #endregion
    
    #region METHODS
    function get_index(){
        return index;
    }
    
    /// @desc   Render the object to the scene.
    function render(){};
    
    /// @desc   Cleans up any dynamic resources that may be tied to this instance.
    function free(){};
    #endregion
}