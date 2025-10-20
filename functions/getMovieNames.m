function [outputMovieName, dataFileName, figFrameName] = ...
    getMovieNames(info, eventType)

%This function will simply generate movie file names, data file names and a
%portion of the frame plot names. 
%It is called by makeMovie.m

%Generate a movie and data file names.
if strcmp(eventType, 'Positive')
    fname = 'Pos';
    dataDir = info.outputPositiveEventsDir;
    framePlotDir = info.positiveFramePlotsDir;
    frameFName = 'PF';
end

if strcmp(eventType, 'Negative')
    fname = 'Neg';
    dataDir = info.outputNegativeEventsDir;
    framePlotDir = info.negativeFramePlotsDir;
    frameFName = 'NF';
end

if strcmp(eventType, 'PosNeg')
    fname = 'PosNeg';
    dataDir = info.outputNegativeEventsDir;
    framePlotDir = info.posNegFramePlotsDir;
    frameFName = 'PNF';
end


outputMovieName = [info.outputMovieDir, fname, '_', ...    
    info.dateTimeStr, '_', ...
    num2str(info.dataPartition, '%03d'), '_', ...
    num2str(info.movieStartTime, '%03d'), ...
    '-', num2str(info.movieEndTime, '%03d'), '.avi'];

dataFileName = [dataDir, fname, 'Events', '_', info.dateTimeStr, '_', ...
    num2str(info.dataPartition, '%03d'), '_', ...
    num2str(info.movieStartTime, '%03d'), ...
    '-', num2str(info.movieEndTime, '%03d'), '.h5'];

figFrameName = [framePlotDir, frameFName, '_', info.dateTimeStr, '_', ...
    num2str(info.dataPartition, '%03d'), '_', ...
    num2str(info.movieStartTime, '%03d'), '-', ...
    num2str(info.movieEndTime, '%03d'), '_'];

end %End of the function getMovieNames.m