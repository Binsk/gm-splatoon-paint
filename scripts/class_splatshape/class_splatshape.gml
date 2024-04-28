/// ABOUT
/// A splat shape is a splat sprite to apply to a splat mesh when painting.
/// Splatshapes also contain special buffers based on the image in order to 
/// apply quick updates to the required buffers
///
///	Splats are assumed to be centered and will render centered.
/// The sprites themselves are alpha and color masked in that they must be white
/// and only contain alpha values of 0 or 1.
function SplatShape(sprite, subimage, xscale=1.0, yscale=1.0) constructor{
	#region PROPERTIES
	self.sprite = sprite;
	self.subimage = subimage;
	self.xscale = xscale;
	self.yscale = yscale;
	
	buffer_shape = -1;
	#endregion
	
	#region METHODS
	function set_sprite(sprite){
		if (self.sprite != sprite)
			free(); // Will need to regen buffer
			
		self.sprite = sprite;
		
	}
	
	function set_subimage(subimage){
		if (self.subimage != subimage)
			free();
			
		self.subimage = subimage;
	}
	
	function set_scale(xscale, yscale){
		self.xscale = xscale;
		self.yscale = yscale;
	}
	
	function free(){
		if (buffer_shape >= 0)
			buffer_delete(buffer_shape);
		
		buffer_shape = -1;
	}
	
	/// @desc	Renders the splat to a renderable.
	function render(renderable, uv, team_id=0){
		var surface = renderable[$ "surface_splat"];
		var buffer = renderable[$ "buffer_splat"];
		if (is_undefined(surface) or is_undefined(buffer)) // Not a paintable surface
			return;
		
		// Render the visual element first:
		if (surface_exists(surface)){
			var px = surface_get_width(surface) * uv.u;
			var py = surface_get_height(surface) * uv.v;
			var w = sprite_get_width(sprite) * xscale;
			var h = sprite_get_height(sprite) * yscale;
			var xoff = sprite_get_xoffset(sprite) * xscale;
			var yoff = sprite_get_yoffset(sprite) * yscale;
			
			var color = c_white;
			if (team_id > 0)
				color = (team_id == 1 ? make_color_rgb(128, 0, 0) : make_color_rgb(255, 0, 0));
			
			surface_set_target(surface);
			if (team_id = 0) // If no team we need to erase part of the surface instead
				gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
				
			// Render while keeping it centered
			draw_sprite_ext(sprite, subimage, px + xoff - w * 0.5, py + yoff - h * 0.5, xscale, yscale, 0, color, 1.0);
			
			gpu_set_blendmode(bm_normal);
			surface_reset_target();
		}
		
		if (buffer_shape < 0){ // No shape created yet; generate it into a buffer
			var surface = surface_create(sprite_get_width(sprite), sprite_get_height(sprite), surface_r8unorm);
			surface_set_target(surface);
			draw_sprite(sprite, subimage, sprite_get_xoffset(sprite), sprite_get_yoffset(sprite));
			surface_reset_target();
			
			buffer_shape = buffer_create(sprite_get_width(sprite) * sprite_get_height(sprite) + 1, buffer_fixed, 1);
			buffer_get_surface(buffer_shape, surface, 0);
			
			surface_free(surface);
		}
		
		if (buffer < 0)
			return;
		
		// Paint data into buffer:
		var splat_buffer_size = buffer_get_size(buffer); // Data of buffer we are modifying
		var splat_size = floor(sqrt(splat_buffer_size));
		var buffer_size = {
			width : sprite_get_width(sprite),
			height : sprite_get_height(sprite)
		}
		
		var start_x = floor(splat_size * uv.u - buffer_size.width * 0.5 * xscale); // Coordinates on buffer we are modifying
		var start_y = floor(splat_size * uv.v - buffer_size.height * 0.5 * yscale);
		var width = floor(buffer_size.width * xscale);
		var height = floor(buffer_size.height * yscale);
		
		for (var j = 0; j < height; ++j){
			for (var i = 0; i < width; ++i){
				var sx = start_x + i; // Which coordinates to modify
				var sy = start_y + j;
				var splat_index = splat_size * sy + sx;
				if (splat_index < 0 or splat_index >= splat_buffer_size) // Out of bounds mesh surface
					continue;
				
				var px = floor(i / xscale); // Which coordinates we are pulling new data from
				var py = floor(j / yscale);
				var index = py * buffer_size.width + px;
				if (index < 0 or index >= width * height) // Out of bounds splat shape
					continue;
				
				buffer_seek(buffer, buffer_seek_start, splat_index);
				buffer_seek(buffer_shape, buffer_seek_start, index);
				
				var color = buffer_read(buffer_shape, buffer_u8);
				if (color == 0) // No mask data
					continue;
				
				if (team_id == 0) // No team gets data wiped
					color = 0;
				else
					color = (team_id == 1 ? 128 : 255); // Team data gets set to appropriate shader mask values
				
				buffer_write(buffer, buffer_u8, color);
			}
		}
	}
	#endregion
}