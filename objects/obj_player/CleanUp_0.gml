renderable.free();
delete renderable;

renderable_billboard.free();
delete renderable_billboard;

for (var i = 0; i < array_length(splat_shape_array); ++i){
	splat_shape_array[i].free();
	delete splat_shape_array[i];
}