signaler.clear();
delete signaler;
signaler = undefined;

for (var i = 0; i < array_length(player_array); ++i)
    delete player_array[i];
    
player_array = [];