/// ABOUT
/// A 3D scene involving some basic platforms and a movable character that can
/// shoot ink.

#region INIT
// Generate primary controller systems:
instance_create_layer(0, 0, "Instances", obj_render_controller);
instance_create_layer(0, 0, "Instances", obj_physics_controller);

// Create the player:
instance_create_layer(0, 0, "Instances", obj_player);

// Create static terrain:
renderable_terrain_array = [];
collidable_terrain_array = [];

	// Floor
var renderable = new SplatBlockMesh(0, -8, 0);
renderable.set_scale(16, 16, 16);
renderable.set_texture(sprite_get_texture(spr_block, 0));
array_push(renderable_terrain_array, renderable);
obj_render_controller.add_renderable(renderable);

var collidable = new Collidable(point_format_struct(-0.5, -0.5, -0.5), point_format_struct(0.5, 0.5, 0.5), renderable);
array_push(collidable_terrain_array, collidable);
obj_physics_controller.add_collidable(collidable);

	// Paintable spinning block
renderable = new SplatBlockMesh(12, 4, 0);
renderable.set_scale(4, 4, 4, 128);
renderable.set_texture(sprite_get_texture(spr_block, 0));
array_push(renderable_terrain_array, renderable)
obj_render_controller.add_renderable(renderable);

	// Wall block
renderable = new SplatBlockMesh(4, 4, -12, 256);
renderable.set_scale(8, 8, 8);
renderable.set_texture(sprite_get_texture(spr_block, 0));
array_push(renderable_terrain_array, renderable);
obj_render_controller.add_renderable(renderable);
#endregion