/// ABOUT
/// A ball of ink that will fly through the air and hit terrain, causing an
/// ink 'splat'.
#region PROPERTIES
velocity_current = vector3_format_struct(0, 0, 0);
gravity_strength = 0.0005;
gravity_current = 0.0;
position_previous = undefined;
#endregion

#region INIT
renderable = new BillboardMesh();
renderable.set_texture(sprite_get_texture(spr_inkball, 0));
obj_render_controller.add_renderable(renderable);
#endregion