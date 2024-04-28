/// ABOUT
/// This object is a simple 2D test object to test the splat painting shader.
/// Left-click somewhere to paint `color_a` and right-click somewhere to paint
/// `color_b`

#region PROPERTIES
surface_splat = -1; // Surface used to store splat indices + alpha

mouse_x_last = mouse_x; // Used for rendering 'strokes' between splats
mouse_y_last = mouse_y;
#endregion
