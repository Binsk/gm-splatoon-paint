renderable = new StaticMesh(0, 0, 0);
renderable.set_render_mesh(vertex_duplicate_buffer(SplatBlockMesh.MESH));
renderable.set_texture(sprite_get_texture(spr_player, 0));
renderable.set_scale(1, 2, 1);

// Collidables inherit scaling by their parents
collidable = new Collidable(point_format_struct(-0.5, -0.5, -0.5), point_format_struct(0.5, 0.5, 0.5), renderable);

obj_render_controller.add_renderable(renderable);
obj_physics_controller.add_collidable(collidable);