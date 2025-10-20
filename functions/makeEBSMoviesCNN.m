function makeEBSMoviesCNN(info, data)

%This function will make a movie of the EBS data.  It is called by
%cadetDroneCNNMakeFiles.m

% We have to remove all the bad events that have x,y pixels out of bounds.
% This is to avoid breaking the moviemaker.
events = data(find(data(:, 1) < info.numXPixels & ...
    data(:, 2) < info.numYPixels), :);
events = double(events);

%Now make the movies.
%makeMovieCNN(info, events, 'Positive');
%makeMovieCNN(info, events, 'Negative');
%makeMovieCNN(info, events, 'PosNeg');
makeMovie(info, events, 'PosNeg');

end  %End of the function makeEBSMovies1.m
