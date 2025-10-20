close all;
fclose('all');
nf = java.text.DecimalFormat;

%Set the date of the data.
year = 2022;
month = 8;
day = 30;

%Set the time of the data.
hour = 16;
minute = 13;
second = 41;

%Generate an information structure that will hold all of the sundry bits of
%information used by functions.
info.year = year;
info.month = month;
info.day = day;
info.hour = hour;
info.minute = minute;
info.second = second;
info.nf = nf;

%Create time and date strings for later use.
timeStr = [num2str(hour, '%02d'), ':', num2str(minute, '%02d'), ...
    ':', num2str(second, '%02d')];
dateStr = ['EBS', num2str(year), num2str(month, '%02d'), num2str(day, '%02d'), '_'];

info.timeStr = timeStr;
info.dateStr = dateStr;

%Set the root and data directories.
rootDir = '/home/jdw/Prophesee/';
dataDir = '/home/jdw/Prophesee/Data/';

%Generate a file name.  We use the directory function to get the only file
%corresponding to the time and date in the Data directory.
fileName =  dir([dataDir, num2str(year), '-', num2str(month, '%02d'), '-', ...
    num2str(day, '%02d'), 'T', num2str(hour, '%02d'), '-', ...
    num2str(minute, '%02d'), '-', num2str(second, '%02d'), '*.es']);

%Generate the full path with file name.
inFileName = [dataDir, fileName.name];
inFileName = [dataDir, 'Video2_93ft_2022-11-02_13-04-59-Cut_cd.dat'];

%Generate a full path with file name for the output directory.
outFileDir = [dataDir, num2str(year), '-', num2str(month, '%02d'), '-', ...
    num2str(day, '%02d'), 'T', num2str(hour, '%02d'), '-', ...
    num2str(minute, '%02d'), '-', num2str(second, '%02d'), '/'];

%Check to see if the directory exists.  If it does not then create it.
if(~isfolder(outFileDir))
    dirCreationStatus = mkdir(outFileDir);
end


outFileName = [outFileDir, 'Summary_', dateStr, '.png'];

info.dataDir = dataDir;
info.rootDir = rootDir;
info.inFileName = inFileName;
info.outFileName = outFileName;
info.outFileDir = outFileDir;
info.movieName = [dateStr, timeStr];

%Set up a flag that determines if we want to print the individual movie
%frames to .png files.
printFrames = 0;
info.printFrames = printFrames;

%Set up a location for where the propeller is rotating.  The coordinate
%system will be in camera pixels.
propellerPositionX = 430;
propellerPositionY = 350;
info.propellerPositionX = propellerPositionX;
info.propellerPositionY = propellerPositionY;

%Set up variables for the number of pixels in the x and y direction.
info.numXPixels = 1280;
info.numYPixels = 720;

%info.stockTimeBins = 1.0;
info.stockTimeBins = 0.0001; % array containing time bins in seconds.
% EXAMPLE stocktimebins=[0.01,0.001] generates time series and Fourier
% plots with time samples of 10 milliseconds and 1 millisecond.

info.movieFrames = 0.05;
%info.movieFrames = 1.0;
%info.movieFrames = 0.1; % seconds for each movie frame.
% EXAMPLE info.movieFrames=[0.01,0.05] produces two movies, one with frame
% length 10 milliseconds, one with frame length 50 milliseconds.

info.movieStartTime = 120.8; 
%info.movieStartTime = 1.0; % seconds from the first event.
% EXAMPLE info.movieStartTime=0.07 starts the movie 70 milliseconds in.

info.movieLength = 2; % seconds in length
% EXAMPLE info.movieLength=0.1 uses 100 milliseconds of acqusitions (starting
% from info.movieStartTime

info.makeMovie = true; % skip the movie or not.


% load the custom colormap for EBS work
load('EBSjw');

clims=[0 4]; % TODO: agree on what the limits should be for sparse events.
info.clims = clims;

%Read in the data.
if (~exist('Events') == 1)
    [Events] = getEventsArray(info);
end

% Fix the problem with (x,y) being zero-indexed
Events(:,1) = Events(:,1) + 1;
Events(:,2) = Events(:,2) + 1;

[a,b] = size(Events);
if b == 1 %We do not have a proper 4D array
    error('Not a 4D array.');
end


% We replace (elapsed microseconds from START OF ACQUSITION) with (elapsed
% microseconds from FIRST EVENT).  The FPGA can leave long (~hundreds of
% milliseconds) gaps before the first event is clocked in, and this plays
% merry hell with the FFTs later.
Events(:,4) = Events(:,4) - Events(1,4);

% Elapsed time in (float) seconds.
TimeInSecs = double(Events(:,4))/1.0E6;


% Calculate time series.
delt = info.stockTimeBins;
if delt>max(TimeInSecs) % it breaks the histogram...
    error('Time bin is greater than length of acquisition.'); %... so abort this particular stocktimebin
end
bins=0:delt:max(TimeInSecs);
bins=[bins (max(bins)+delt)];


%Make summary plots of the events.
%EventBasedSummaryPlot(Events, info)

%Make fourier transforms of the data.
%EBSFourierTransformPlots(Events, info)

%Make movies of the data.
makeEBSMovies(Events, info)

%Generate a structure containing the location of the object and the 
%time associated with that location for both positive and negative events.
xyObjectPosition = getObjectPosition(info, Events);


