/// @description process controllers
if (not is_processing)
	return;
	
var player_len = array_length(player_array);
for (var i = 0; i < player_len; ++i){
    var data = player_array[i];
    if (data.connection_state != CONTROLLERMAP_STATE.connected) continue;
    var input_state;
    
    if (data.slot_id >= 0) // Actual controller
        input_state = process_controller_inputs(data);
    else if (not is_undefined(virtual_input_function)) // Virtual controller
        input_state = virtual_input_function(i, data.get_cleared_input_state());
    else // Virtual but no input detection defined
        continue;
    
    signal_controller_inputs(data, i, input_state);
    
    // Perform some extra explicit calls for the joystick axes together to allow for some simpler movement / look
    // code that isn't split across two signals:
	signaler.signal("joystick.left.axis", i, input_state.joystick.left.axis_x, input_state.joystick.left.axis_y);
	signaler.signal("joystick.right.axis", i, input_state.joystick.right.axis_x, input_state.joystick.right.axis_y);
	
	signaler.signal(string_ext("joystick.left.axis:{0}", [i]), input_state.joystick.left.axis_x, input_state.joystick.left.axis_y);
	signaler.signal(string_ext("joystick.right.axis:{0}", [i]), input_state.joystick.right.axis_x, input_state.joystick.right.axis_y);

    data.input_state = input_state; // Update the state for next frame
}