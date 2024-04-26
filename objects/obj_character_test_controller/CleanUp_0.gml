/// @description 
for (var i = 0; i < array_length(renderable_terrain_array); ++i){
	renderable_terrain_array[i].free();
	delete renderable_terrain_array[i];
}
