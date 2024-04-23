#region INIT
// Spawn the base render controller and generate a cube for us to look at
instance_create_layer(0, 0, "Instances", obj_render_controller);

cube = new StaticBlockMesh(0, 0, 0);
cube.set_scale(16, 16, 16);
obj_render_controller.add_renderable(cube);
#endregion