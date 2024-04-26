/// @description process tick
while (current_time - tick_timestamp > tick_length){
	signaler.signal("tick");
    tick_timestamp += tick_length;
}