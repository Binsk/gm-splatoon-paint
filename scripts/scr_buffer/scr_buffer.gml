function buffer_write_series(buffer, type, array){
	var loop = array_length(array);
	for (var i = 0; i < loop; ++i){
		if (buffer_write(buffer, type, array[i]) != 0)
			return -1;
	}
	return 0;
}

function buffer_read_series(buffer, type, count){
	var array = [];
	for (var i = 0; i < count; ++i)
		array_push(array, buffer_read(buffer, type));
	
	return array;
}