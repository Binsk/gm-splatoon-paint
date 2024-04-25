#region INIT
/// ABOUT
/// A simple 3D test scene that allows you to paint on the surface of a spinning
/// cube. Left-click to paint color A and right-cluck to paint color B

// Spawn the base render controller and generate a cube for us to look at
instance_create_layer(0, 0, "Instances", obj_render_controller);

cube = new SplatBlockMesh(0, 0, 0);
cube.set_scale(16, 16, 16);
cube.set_texture(sprite_get_texture(spr_block, 0));
cube.buffer_collision = SplatBlockMesh.COLLISION; // Use the default dummy collision shape
obj_render_controller.add_renderable(cube); // Add to render pipeline
#endregion