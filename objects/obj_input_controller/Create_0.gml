/// @dependencies   Signaler
/// ABOUT
/// The controller manager handles checking for new / old controllers as well as
/// handling input triggers from each controller. Controllers are accessible via
/// "player 0, player 1, etc" and the system will auto-manage scanning for slots,
/// reserving slots, and assigning new slots to players.

#region SIGNALS
/// "tick" ()                               -   thrown every controller tick scan
/// "connected" (player#)                   -   thrown when a player connects for the first time
/// "reconnected" (player#)                 -   thrown when a player slot is reactivated
/// "disconnected" (player#)                -   thrown when a player's controller is disconnected
/// "slot-changed" (old#, new#)             -   thrown when a controller is shifted to a new player slot
/// [control_state_id] (player#)            -   dot-connected state of the current control
///                                             e.g., "shoulder.left.trigger"
///                                             For 'pressed' and 'released' events just add
///                                             the relevant portion to the signal name.
///                                             e.g., "shoulder.left.trigger.pressed"
/// "joystick.left.axis" (player#, x-value, y-value)  -   x and y values of the left axis
/// "joystick.right.axis" (player#, x-value, y-value) -   x and y values of the right axis

/// NOTE: For all input signals, there is also optionally a signal thrown with the 
///       player number tacked on to the end instead of being thrown as an argument.
///       For example:
///       "joystick.left.axis:0" (x-value, y-value)
///       "shoulder.left.trigger.button.pressed:0" ()
///
///       This is merely added to simplify attaching signals if you have unique
///       player objects and don't want to manually parse each player number,
///		  but both methods work equally well.

/// NOTE: For the layout of buttons, axes, etc. check ControllerMap.get_cleared_input_state()
#endregion

#region SUBCLASSES
enum CONTROLLERMAP_STATE {
    disconnected,	// Controller is currently disconnected
    connected,		// Controller is currently connected
    reserved		// Controller is current disconnected but the slot is being saved
    				// to prevent other controllers from taking it
}

/// Controller map is a simple structure containing the SLOTid and the state of 
/// the controller. A slot ID of -1 represents a 'virtual' controller and will
/// NEVER be automatically disconnected.
function ControllerMap(slot_id=-1) constructor {
	/// @note Digital buttons will contain a bitwised ORed list of the following
	///		  enum values. E.g, when a button was just pressed it will have "down"
	///		  and "pressed" ORed together meaning the value will be 3.
	///		  If you only care about the 'pressed' value, you can strip just that
	///		  value out by using a bitwise AND. E.g.,
	///		  if (my_button_value & CONTROLLERMAP_BUTTON_STATE.pressed > 0){...}
    enum CONTROLLERMAP_BUTTON_STATE {
        down = 1,
        pressed = 2,
        released = 4
    }
    
    self.slot_id = slot_id;
    connection_state = CONTROLLERMAP_STATE.connected;
    input_state = {};
    
    function get_cleared_input_state() {
        return {
            face : {
                left : { // D-pad
                    north : 0,
                    south : 0,
                    east : 0,
                    west : 0
                },
                right : { // Symbols
                    north : 0,
                    south : 0,
                    east : 0,
                    west : 0
                }
            },
            menu : {    // Labels might not be exact, but they should be functionally equivalent
                start : 0,
                select : 0
            },
            shoulder : {
                left : {
                    bumper : {
                    	button : 0	
                    },
                    trigger : {
                    	button : 0,	// Pressed / released / down
                    	axis : 0 // Actual pressure value
                    }
                },
                right : {
                    bumper : {
                    	button : 0
                    },
                    trigger : {
                    	button : 0,	// Pressed / released / down
                    	axis : 0 // Actual pressure value
                    }
                }
            },
            joystick : {
                left : {
                    axis_x : 0,
                    axis_y : 0,
                    button : 0,
                },
                right : {
                    axis_x : 0,
                    axis_y : 0,
                    button : 0,
                }
            }
        };
    }
}
#endregion

#region PROPERTIES
signaler = undefined;
max_allowed_connections = 4;    // Maximum number of controller IDs to connect at any time
tick_timestamp = current_time;  // Used to handle scanning for new controllers
tick_length = 5000;             // How often to scan for controllers (in ms)
player_array = [];              // Contains a ControllerMap for every player; array index equates to player number
allow_slot_reassigning = true;  // If true, allows new controllers to take over player slots; if not slots are reserved and must be manually cleared
virtual_input_function = undefined; // Function to call to process a virtual controller's input
is_processing = true;	// Used to pause controller processing w/o needing to destroy the system
#endregion

#region METHODS
/// @desc Set maximum number of controller connections at any time:
function set_maximum_connections(maximum=4){
    max_allowed_connections = clamp(int64(maximum), 0, infinity);
}

/// @desc Whether or not to allow new controllers into an old player slot after
///       the player's controller disconnected.
/// @note The state of allowing reassigning only affects controllers disconnected
///       AFTER the change; any disconnected controllers BEFORE will still remain
///       as 'reserved' and can be cleared with `clear_disconnected(true)`
function set_allow_slot_reassigning(can_reassign=true){
    allow_slot_reassigning = bool(can_reassign);
}

/// @desc   Sets the controller scan refresh rate. It may be useful to increase the
///         scan rate during the "press X to join" stage and then lower it again
///         once the game has started.
/// @param {real}   rate=5000       scan delay in ms
function set_scan_refresh_rate(rate=5000){
    // Clamp between 1 frame and 1 minute
    tick_length = clamp(real(rate), 1000 / room_speed, room_speed * 1000);
}

/// @desc   Sets the function to call to determine the new state of a virtual controller.
///			The function will be called when a virtual controller's new input state is
///			required (once a frame). The function will be provided with the following
///			arguments:
///			-	player number
///			-	empty input state generated by ControllerMap.get_cleared_input_state()
///			The function should return any edits to the provided input state.
///			
///			NOTE: All 'digital' values should be explicitly marked as int64 values.
///				  All 'analogue' values should be explicitly marked as real values.
///
///			The signaler checks datatypes to determine if a value should be constantly
///			signaled or only signaled when changed.
///
///			Virtual function are useful if you wish to mix keyboard, mouse, touch,
///			or other input types with native controller support.
function set_virtual_input_function(func){
    virtual_input_function = func;
}

/// @desc	Allows you to pause / run the system without destroying it and requiring
///			reconnecting signals. When paused controller connections / disconnections
///			WILL still be processed, but no input from the controllers will be processed.
function set_system_active(active=true){
	is_processing = bool(active);
}

/// @desc   Given a player index, returns the slot ID of the currently paired
///         controller (or -1 if virtual). undefined is returned if the player
///         doesn't exist.
function get_player_slot(player_index){
    if (clamp(player_index, 0, array_length(player_array) - 1) != player_index)
        return undefined;
    
    return player_array[player_index].slot_id;
}

/// @desc Given the player index, returns the current connection state as an enum.
///       undefined is returned if the player doesn't exist.
function get_player_state(player_index){
    if (clamp(player_index, 0, array_length(player_array) - 1) != player_index)
        return undefined;
        
    return player_array[player_index].connection_state;
}

/// @desc   Given the player index, returns the current name of the controller
///         connected. If the controller is disconnected or reserved then "disconnected"
///         will be returned. Virtual controllers will return as "virtual".
///         If the player doesn't exist, undefined is returned.
function get_player_controller_description(player_index){
    if (clamp(player_index, 0, array_length(player_array) - 1) != player_index)
        return undefined;
        
    var data = player_array[player_index];
    if (data.connection_state != CONTROLLERMAP_STATE.connected)
        return "disconnected";
    
    if (data.slot_id < 0)
        return "virtual";
    else if (not gamepad_is_connected(data.slot_id)) // If disconnected between ticks
        return "disconnected"
    
    return gamepad_get_description(data.slot_id);
}

/// @desc   Wipes all data for disconnected players and shifts players down
///         to fit the empty spots, returns the number of players removed and will
///			signal 'slot-changed' for any players who's position was changed.
/// @param  {bool}  include_reserved=false      if set to true, reserved slots will be wiped as well
function clear_disconnected(include_reserved=false){
    var disconnected_count = 0;
    var player_len = array_length(player_array);
    
    var slot_id_reference_array = array_create(player_len);
    for (var i = 0; i < player_len; ++i)
        slot_id_reference_array[i] = player_array[i].slot_id;
    
    for (var i = 0; i < player_len; ++i){
        var controller = player_array[i];
        var is_disconnected = (controller.connection_state == CONTROLLERMAP_STATE.disconnected);
        is_disconnected |= (include_reserved and controller.connection_state == CONTROLLERMAP_STATE.reserved);
        
        if (not is_disconnected) continue;
        
        delete player_array[i];
        array_delete(player_array, i, 1);
        --i;
        --player_len;
        ++disconnected_count;
    }
    
    // Throw signals for all adjusted slots:
    for (var i = 0; i < array_length(player_array); ++i){
        var data = player_array[i];
        var index = array_get_index(slot_id_reference_array, data.slot_id);
        if (index != i)
            signaler.signal("slot-changed", index, i);
    }
    
    return disconnected_count;
}

/// @desc   Will connect a 'virtual' controller to reserver a slot if possible.
///         The assigned player number will be returned, or -1 if there was a problem.
function connect_virtual_controller(){
    var player_len = array_length(player_array);
    // All slots are taken:
    if (player_len >= max_allowed_connections){
       for (var i = 0; i < player_len; ++i){
           var data = player_array[i];
           if (data.connection_state != CONTROLLERMAP_STATE.disconnected) continue;
           
           signaler.signal("reconnected", i);
           data.slot_id = -1;
           data.connection_state = CONTROLLERMAP_STATE.connected;
           return i;
       }
       
       return -1; // Nothing available; we can't connect
    }
    
    // Just add as a new player:
    var data = new ControllerMap();
    array_push(player_array, data);
    signaler.signal("connected", player_len);
    return player_len;
}

/// @desc   Forces a player's state to be marked as disconnected. This is generally
///         only useful for virtual controllers as physical controllers will 'reconnect'
///         at the next tick. If 'allow reserved' then slots will be saved if the settings
///         are set to do so.
function disconnect_player(player_index, allow_reserved=true){
    if (clamp(player_index, 0, array_length(player_array) - 1) != player_index)
        return;
        
    var data = player_array[player_index];
    
    if (data.connection_state == CONTROLLERMAP_STATE.connected)
        signaler.signal("disconnected", player_index);
    
    data.connection_state = (allow_reserved and allow_slot_reassigning ? CONTROLLERMAP_STATE.reserved : CONTROLLERMAP_STATE.disconnected);
}

/// @desc   Forces a player's state to be marked as connected. This is generally
///         only useful for virtual controllers as physical controllers will 'disconnect'
///         at the next tick.
function connect_player(player_index){
    if (clamp(player_index, 0, array_length(player_array) - 1) != player_index)
        return;
    
    var data = player_array[player_index];
    
    if (data.connection_state != CONTROLLERMAP_STATE.connected)
        signaler.signal("reconnected", player_index);
    
    data.connection_state = CONTROLLERMAP_STATE.connected;
}

/// @desc	Scan for new devices as well as newly disconnected devices. Player slots
///			will be added automatically and signals thrown when a connection change
///			occurs.
function scan(){
    var device_count = gamepad_get_device_count();
    var player_count = array_length(player_array);
    
    for (var i = 0; i < device_count; ++i){
        // Gamepad is connected; scan existing controllers for a change of state:
        if (gamepad_is_connected(i)){
            // Check if the player exists; if so determine if it is a reconnect:
            var j = 0;
            for (; j < player_count; ++j){
                var data = player_array[j];
                if (data.slot_id != i) continue;
                if (data.connection_state == CONTROLLERMAP_STATE.disconnected or 
                    data.connection_state == CONTROLLERMAP_STATE.reserved)
                    signaler.signal("reconnected", j);
                    
                data.connection_state = CONTROLLERMAP_STATE.connected;
                break;
            }
            
            // If no reconnect, next test for reassignments.
            // NOTE: the state will be 'reserved' if reassigning is disabled
            for (var k = 0; k < player_count; ++k){
                var data = player_array[k];
                if (data.connection_state != CONTROLLERMAP_STATE.disconnected) continue;
                signaler.signal("reconnected", k);
                data.connection_state = CONTROLLERMAP_STATE.connected;
                data.slot_id = i; // Update controller slot number
            }
            
            // No player found, so we may need to create a new one
            if (j >= player_count and player_count < max_allowed_connections){
                var data = new ControllerMap(i);
                array_push(player_array, data);
                signaler.signal("connected", player_count++);
            }
        }
        // If the gamepad is NOT connected; 
        else{
            for (var j = 0; j < player_count; ++j){
                var data = player_array[j];
                if (data.slot_id != i) continue;
                
                if (data.connection_state == CONTROLLERMAP_STATE.connected)
                    signaler.signal("disconnected", j);
                
                data.connection_state = (allow_slot_reassigning ? CONTROLLERMAP_STATE.disconnected : CONTROLLERMAP_STATE.reserved);
            }
        }
    }
}

/// @desc   Processes the inputs of the specified controller and returns the new
///			updated controller state for processing.
function process_controller_inputs(data){
    var new_input_state = data.get_cleared_input_state();
    var slot_id = data.slot_id;
    
    	// Arrows
    new_input_state.face.left.north = int64(gamepad_button_check(slot_id, gp_padu) | (gamepad_button_check_pressed(slot_id, gp_padu) * 2) | (gamepad_button_check_released(slot_id, gp_padu) * 4));
    new_input_state.face.left.south = int64(gamepad_button_check(slot_id, gp_padd) | (gamepad_button_check_pressed(slot_id, gp_padd) * 2) | (gamepad_button_check_released(slot_id, gp_padd) * 4));
    new_input_state.face.left.east = int64(gamepad_button_check(slot_id, gp_padr) | (gamepad_button_check_pressed(slot_id, gp_padr) * 2) | (gamepad_button_check_released(slot_id, gp_padr) * 4));
    new_input_state.face.left.west = int64(gamepad_button_check(slot_id, gp_padl) | (gamepad_button_check_pressed(slot_id, gp_padl) * 2) | (gamepad_button_check_released(slot_id, gp_padl) * 4));
    
        // Symbols
    new_input_state.face.right.north = int64(gamepad_button_check(slot_id, gp_face4) | (gamepad_button_check_pressed(slot_id, gp_face4) * 2) | (gamepad_button_check_released(slot_id, gp_face4) * 4));
    new_input_state.face.right.south = int64(gamepad_button_check(slot_id, gp_face1) | (gamepad_button_check_pressed(slot_id, gp_face1) * 2) | (gamepad_button_check_released(slot_id, gp_face1) * 4));
    new_input_state.face.right.east = int64(gamepad_button_check(slot_id, gp_face2) | (gamepad_button_check_pressed(slot_id, gp_face2) * 2) | (gamepad_button_check_released(slot_id, gp_face2) * 4));
    new_input_state.face.right.west = int64(gamepad_button_check(slot_id, gp_face3) | (gamepad_button_check_pressed(slot_id, gp_face3) * 2) | (gamepad_button_check_released(slot_id, gp_face3) * 4));
    
        // Start / Select
    new_input_state.menu.start = int64(gamepad_button_check(slot_id, gp_start) | (gamepad_button_check_pressed(slot_id, gp_start) * 2) | (gamepad_button_check_released(slot_id, gp_start) * 4));
    new_input_state.menu.select = int64(gamepad_button_check(slot_id, gp_select) | (gamepad_button_check_pressed(slot_id, gp_select) * 2) | (gamepad_button_check_released(slot_id, gp_select) * 4));
    
        // Shoulder buttons
    new_input_state.shoulder.left.bumper.button = int64(gamepad_button_check(slot_id, gp_shoulderl) | (gamepad_button_check_pressed(slot_id, gp_shoulderl) * 2) | (gamepad_button_check_released(slot_id, gp_shoulderl) * 4));
    new_input_state.shoulder.left.trigger.button = int64(gamepad_button_check(slot_id, gp_shoulderlb) | (gamepad_button_check_pressed(slot_id, gp_shoulderlb) * 2) | (gamepad_button_check_released(slot_id, gp_shoulderlb) * 4));
    new_input_state.shoulder.right.bumper.button = int64(gamepad_button_check(slot_id, gp_shoulderr) | (gamepad_button_check_pressed(slot_id, gp_shoulderr) * 2) | (gamepad_button_check_released(slot_id, gp_shoulderr) * 4));
    new_input_state.shoulder.right.trigger.button = int64(gamepad_button_check(slot_id, gp_shoulderrb) | (gamepad_button_check_pressed(slot_id, gp_shoulderrb) * 2) | (gamepad_button_check_released(slot_id, gp_shoulderrb) * 4));
    
    	// Shoulder axes:
    new_input_state.shoulder.left.trigger.axis = real(gamepad_button_value(slot_id, gp_shoulderlb));
	new_input_state.shoulder.right.trigger.axis = real(gamepad_button_value(slot_id, gp_shoulderrb));
	
        // Joysticks
    new_input_state.joystick.left.axis_x = real(gamepad_axis_value(slot_id, gp_axislh));
    new_input_state.joystick.left.axis_y = real(gamepad_axis_value(slot_id, gp_axislv));
    new_input_state.joystick.left.button = int64(gamepad_button_check(slot_id, gp_stickl) | (gamepad_button_check_pressed(slot_id, gp_stickl) * 2) | (gamepad_button_check_released(slot_id, gp_stickl) * 4));
    
    new_input_state.joystick.right.axis_x = real(gamepad_axis_value(slot_id, gp_axisrh));
    new_input_state.joystick.right.axis_y = real(gamepad_axis_value(slot_id, gp_axisrv));
    new_input_state.joystick.right.button = int64(gamepad_button_check(slot_id, gp_stickr) | (gamepad_button_check_pressed(slot_id, gp_stickr) * 2) | (gamepad_button_check_released(slot_id, gp_stickr) * 4));

    return new_input_state;
}

/// @desc Compares the existing state of a controller to the updated state and 
///       signals accordingly. This is recursive and will signal each input as a 
///		  "."-connected string. int64 values are treated as digital while real values
///		  are treated as analogue.
function signal_controller_inputs(data, player_index, new_input_state, key_array=[]){
    var old_state = data.input_state;
    for (var i = 0; i < array_length(key_array); ++i)
        old_state = variable_struct_get(old_state, key_array[i]);

    var keys = variable_struct_get_names(old_state);
    for (var i = 0; i < array_length(keys); ++i){
        var old_value = old_state[$ keys[i]];
        var new_value = new_input_state[$ keys[i]];
        
        // If there is a sub-state, process that itself
        if (is_struct(old_value)){
            var array = array_create(array_length(key_array));
            array_copy(array, 0, key_array, 0, array_length(key_array));
            array_push(array, keys[i]);
            signal_controller_inputs(data, player_index, new_value, array);
            continue;
        }
        // Calculate the base signal label. E.g.: "face.left.east"
        var label = string_join(".", key_array) + string_ext(".{0}", [keys[i]]);
        // If not a sub-state, compare values and signal as needed
        if (is_int64(old_value)){
                // State change, signal.
                // E.g., "face.left.east.pressed"
            if (old_value != new_value and (old_value & 1 == 0 or new_value & 1 == 0)){
                signaler.signal(string_ext("{0}.{1}", [label, new_value & 2 ? "pressed" : "released"]), player_index);
                signaler.signal(string_ext("{0}.{1}:{2}", [label, new_value & 2 ? "pressed" : "released", player_index]));
            }
            
                // If down, signal:
                // E.g., "face.left.east"
            if (new_value){
                signaler.signal(label, player_index);
                signaler.signal(label + ":" + string(player_index));
            }
        }
        // If not int, it is an axis and we constantly signal
        else{
            signaler.signal(label, player_index, new_value);
            signaler.signal(label + ":" + string(player_index), new_value);
        }
    }
}
#endregion

#region INIT
signaler = new Signaler();
signaler.add_signal("tick", method(id, scan)); // Attach the scan code to our ticker
#endregion