function makeMP4Movies(info, data)

%This function will make a movie of the EBS data.  It is called by
%cadetDroneCNNMakeFiles.m

% We have to remove all the bad events that have x,y pixels out of bounds.
% This is to avoid breaking the moviemaker.
events = data(find(data(:, 1) < info.numXPixels & ...
    data(:, 2) < info.numYPixels), :);
events = double(events);

%Now make the movies.
%makeMP4Movie(info, events, 'Positive');
%makeMP4Movie(info, events, 'Negative');
makeMP4Movie(info, events, 'PosNeg');

end  %End of the function makeMP4Movies.m