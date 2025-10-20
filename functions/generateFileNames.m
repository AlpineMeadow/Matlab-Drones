function [outputMovieName, dataFileName] = generateFileNames(info, ...
    eventType)

%This function will simply generate some file names needed for the files we
%will produce.  It is called by makeMovieCNN.m

fStr = [info.dateTimeStr, ...
    '_', num2str(info.movieStartTime, '%03d'), ...
    '-', num2str(info.movieEndTime, '%03d'), ...
    '_', num2str(info.dataPartition, '%03d')];

if strcmp(eventType, 'Positive')
    outputMovieName = [info.outputMovieDir, 'Pos_', fStr, '.avi'];
    dataFileName = [info.outputPositiveEventsDir, ...
        'PosEvents', '_', fStr, '.h5'];        
end

if strcmp(eventType, 'Negative')
    outputMovieName = [info.outputMovieDir, 'Neg_', fStr, '.avi'];
    dataFileName = [info.outputNegativeEventsDir, ...
        'NegEvents', '_', fStr, '.h5'];
end

if strcmp(eventType, 'PosNeg')
    outputMovieName = [info.outputMovieDir, 'PosNeg_', fStr, '.avi'];
    dataFileName = [info.outputNegativeEventsDir, ...
        'PosNegEvents', '_', fStr, '.h5'];
end

end  %End of the function generateFileNames.m