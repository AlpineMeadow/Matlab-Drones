%This script will generate the various files needed to run a CNN for the
%drones observed using the Event Based Sensor cameras.
%This script is written for the cadets who are working on analyzing the
%data.

close all;
clearvars;

dbstop if error; 

%Create a date and time for the input and output filenames.
%The original octocopter movie has year = 2024, month = 06, day = 10, hour
%= 00, minute = 00, second = 00.
year = 2024;
month = 6;
dayOfMonth = 10;
hour = 0;
minute = 0;
second = 0;

%Here we send in the root path.  This is the path where you want the files
%to be generated and where you store the data.  For example, if you put the
%.dat file in the path : C:\Users\Fred\Desktop\, where Fred is your user
%name then you would set the root path to be : 
%rootPath = 'C:\Users\Fred\Desktop\'; 

%Once this is set all of the generated files will be found here.  Here are
%the directories that will be made.

%outputPath = C:\Users\Fred\Desktop\Date_Time\Output\
%inputPath = C:\Users\Fred\Desktop\Date_Time\Input\

%Movies will be stored in : 
%outputMovieDir = C:\Users\Fred\Desktop\Date_Time\Output\Movies

%Postive Frame plots will be stored in : 
%positiveFramePlotsDir =
%C:\Users\Fred\Desktop\Date_Time\Output\PositiveFramePlots\

%Negative Frame Plots will be stored in : 
%negativeFramePlotsDir =
%C:\Users\Fred\Desktop\Date_Time\Output\NegativeFramePlots\

%Positive+Negative Frame Plots will be stored in : 
%posnegFramePlotsDir = 
%C:\Users\Fred\Desktop\Date_Time\Output\PosNegFramePlots\

%Frame Events will be stored in : 
%frameEventsDir = 
%C:\Users\Fred\Desktop\Date_Time\Output\FrameEvents\

%H5 files will be stored in : 
%saveFileDir = 
%C:\Users\Fred\Desktop\Date_Time\Input\h5\
rootPath = 'C:\Users\Fred\Desktop\'; 

%Set up a flag that determines if we want to print the individual movie
%frames to .png files.
printFrames = 1;

%Set up a flag that tells the program if we want to save the movie frames
%to a file.  This is so that we can run a CNN model on the data.
writeH5 = 1;

%Set the frame length for each frame in the movie.  The units are in
%seconds.  EXAMPLE movieFrameLength = [0.01,0.05] produces two movies, one
%with  frame length 10 milliseconds, one with frame length 50 milliseconds.
movieFrameLength = 0.001;

%Do we want to make a movie.
makeMovie = true;

%Set the color limits. There are always more negative events so we will set
%two different limits.
positiveCLims = [0 5]; 
negativeCLims = [0 5];

%Set the movie starting time in seconds from the first event.
%EXAMPLE info.movieStartTime=0.07 starts the movie 70 milliseconds in.
movieStartTime = 0.0; 

%Now generate the information structure.
info = generateEBSInformationStructure(year, month, dayOfMonth, ...
    hour, minute, second, printFrames, movieFrameLength, movieStartTime, ...
    makeMovie, positiveCLims, negativeCLims, writeH5, rootPath);

%Read in the data from the .dat file.  We will also write out the data as a
%.h5 file for further use.
data = getEBSDatData(info);

%Lets find the potential length of the data set.  We do not know this
%apriori since each movie is different.
[events, rows] = size(data);
movieLength = events/1.0e7;

%Choose the length of the movie to be made in seconds.
info.movieLength = movieStartTime + 60.0; 
% EXAMPLE info.movieLength=0.1 uses 100 milliseconds of acqusitions

%Make movies of the data.
makeEBSMoviesCNN(info, data)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%  generateEBSInformationStructure %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info = generateEBSInformationStructure(year, month, dayOfMonth, ...
    hour, minute, second, printFrames, movieFrameLength, movieStartTime, ...
    makeMovie, positiveCLims, negativeCLims, writeH5, rootPath);

%This function will fill the information structure for the EBS data
%analysis.  I am keeping this seperate from all of the other
%generateInformationStructure functions because it is likely that this will
%be used by others who will not care or need the rest of the generalized
%generateInformationStructure function and the extra information will only
%serve to confuse them.

%This function is called by cadetDroneCNNMakeFiles.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%  Instrument Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Set up variables for the number of pixels in the x and y direction.
info.numXPixels = 1280;
info.numYPixels = 720;

%Create the Instrument name.
Instrument = 'EBS';
info.instrument = Instrument;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Plotting Movies and Frames  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

info.printFrames = printFrames;
info.writeH5 = writeH5;

info.movieFrameLength = movieFrameLength;
info.movieStartTime = movieStartTime;
info.makeMovie = makeMovie;

info.positiveCLims = positiveCLims;
info.negativeCLims = negativeCLims; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%  Time Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Take care of the date and time information.
yearStr = num2str(year);
monthStr = num2str(month, '%02d');
dayOfMonthStr = num2str(dayOfMonth, '%02d');
hourStr = num2str(hour, '%02d');
minuteStr = num2str(minute, '%02d');
secondStr = num2str(fix(second), '%02d');
dateTimeStr = [yearStr, '-', monthStr, '-', dayOfMonthStr, '_', ...
    hourStr, '-', minuteStr, '-', secondStr];

info.yearStr = yearStr;
info.monthStr = monthStr;
info.dayOfMonthStr = dayOfMonthStr;
info.hourStr = hourStr;
info.minuteStr = minuteStr;
info.secondStr = secondStr;
info.dateTimeStr = dateTimeStr;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Input and Output File Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handle the directory and file input and output names.
%Create the root path.

%inputDataPath = [rootPath, 'Data\Input\'];
%outputDataPath = [rootPath, '\Data\Output\'];

info.rootPath = rootPath;
%info.inputDataPath = inputDataPath;
%info.outputDataPath = outputDataPath;

inputMovieName = ['recording_', yearStr, '-', monthStr, '-', ...
     dayOfMonthStr, '_', hourStr, '-', minuteStr, '-', secondStr];

inFileName = [rootPath, inputMovieName, '_cd.dat'];
saveFileName = [rootPath, 'h5\', inputMovieName, '.h5'];

info.inFileName = inFileName;
info.saveFileName = saveFileName;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%  Directory Information  %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

outputDir = [rootPath, dateTimeStr, '\'];
outputPositiveEventsDir = [outputDir, 'FrameEvents\'];
outputNegativeEventsDir = [outputDir, 'FrameEvents\'];
outputPosNegEventsDir = [outputDir, 'FrameEvents\'];
outputMovieDir = [outputDir, 'Movie\'];
positiveFramePlotsDir = [outputDir, 'PositiveFramePlots\'];
negativeFramePlotsDir = [outputDir, 'NegativeFramePlots\'];
posNegFramePlotsDir = [outputDir, 'PosNegFramePlots\'];
saveFileDir = [rootPath, 'h5\'];

%Now fill the info structure.
info.outputDir = outputDir;
info.outputPositiveEventsDir = outputPositiveEventsDir;
info.outputNegativeEventsDir = outputNegativeEventsDir;
info.outputMovieDir = outputMovieDir;
info.positiveFramePlotsDir = positiveFramePlotsDir;
info.negativeFramePlotsDir = negativeFramePlotsDir;
info.posNegFramePlotsDir = posNegFramePlotsDir;

if not(isfolder(saveFileDir))
    mkdir(saveFileDir)
end

%Check to see of the output directory exists. If not, then make it.
if not(isfolder(outputDir))

    %Make the root directory.
    mkdir(outputDir);

    %Make the movie directory.
    mkdir(outputMovieDir);

    %Make the directories for the positive, negative and posneg frame
    %plots.
    mkdir(positiveFramePlotsDir);
    mkdir(negativeFramePlotsDir);
    mkdir(posNegFramePlotsDir);

    %Make the directory for the events.  This will hold positive, negative
    %and posneg events.
    mkdir(outputPositiveEventsDir);    
end

end  %End of the function generateEBSInformationStructure.m



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%  getEBSDatData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = getEBSDatData(info)

%This function will check to see if the data has previously been saved.  If
%so it will read in the save file.  If not it will read in the raw data.  
%The data from the .dat file will be returned in an array of n rowsX 4
%columns.  The first column is the x pixel location of the event.  The
%second column is the y pixel location of the event.  The third column is
%the polarity of the event(It is either increasing or decreasing).  The
%fourth column is the time in seconds from the start of the recording.

saveFileName = info.saveFileName;
inFileName = info.inFileName;

%Check to see if the data has been saved to 
if isfile(saveFileName) 
%    data = h5read(saveFileName, '/odin');
    data = h5read(saveFileName, '/data');
else
    %Read in the data.
    data = datto4xN(inFileName);

    % Fix the problem with (x,y) being zero-indexed
    data(:, 1) = data(:, 1) + 1;
    data(:, 2) = data(:, 2) + 1;

    % We replace (elapsed microseconds from START OF ACQUSITION) with
    % (elapsed microseconds from FIRST EVENT).  The FPGA can leave long
    % (~hundreds of milliseconds) gaps before the first event is clocked
    % in, and this plays merry hell with the FFTs later.
    data(:, 4) = data(:, 4) - min(data(:, 4));

    %Convert the time in microseconds from start of recording with time in
    %seconds from start of recording.
    data(:, 4) = double(data(:, 4))/1.0e6;

    %Now save the data in the .h5 format.
    h5create(saveFileName, '/data', size(data));
    h5write(saveFileName, '/data', data);
end  %End of the if-else clause - if isfile(saveFileName)

end  %End of the function getEBSDatData.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%  datto4xN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fourxN = datto4xN(fname);
%datto4xN.m
%
%   mfile to convert an dat files made from Gen 4 Prophesee .raw files to a
%   4xN    array for futher processing
%
%   McHarg july 2021
%
%   inputs
%   fname-'file name of the dat file
%
%   outputs
%
%   fourxN-4 column by N event array that has x,y,polarity,time for each
%   event
% close all
% clear
%
%   use the load_cd_events from prophessee
events=load_cd_events(fname);
%
%   now make doubles
%
eventsdx=events.x;
eventsdy=events.y;
eventsdt=events.ts;
eventsdp=events.p;
%
%   now make the matrix in the order usafa likes x,y,p,t
%
fourxN=[eventsdx,eventsdy,eventsdp,eventsdt];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%  load_cd_events   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cd_data = load_cd_events(filename, flipX, flipY)
% cd_data = load_cd_events(filename, flipX=0, flipY=0)
%
% Loads data from files generated by the StreamLogger consumer for any type
% of event. This function only read (t,x,y,p) and discard other fields (if
% any) of events.
% timestamps are in uS
% cd_data is a structure containing the fields ts, x, y and p
%
% flipX, flipY allow to flip the image around the X and Y axes. If these
% values are non zero, the corresponding dimension will be flipped
% considering its size to be the value contained in the 'flip' variable
% (i.e. X = flipX - X)  (They defaults to 0 if non-specified)

if ~exist('flipX','var')
    flipX = 0;
end
if ~exist('flipY','var')
    flipY = 0;
end

f=fopen(filename);

% Parse header if any
header = [];
endOfHeader = 0;
numCommentLine = 0;
while (endOfHeader==0)
    bod = ftell(f);
    tline = fgets(f,256);
    if(tline(1)~='%')
        endOfHeader = 1;
    else
        words = strsplit(tline);
        if (length(words) > 2 )
            if (strcmp(words{2} , 'Date'))
                if (length(words) > 3)
                    header = [header; {words{2}, horzcat(words{3}, ...
                        ' ', words{4})}];
                end
            else
                header = [header; {words{2}, words{3}}];
            end
        end
        numCommentLine = numCommentLine+1;
    end
end
fseek(f,bod,'bof');

evType = 0;
evSize = 8;
if (numCommentLine>0) % Ensure compatibility with previous files.
    % Read event type
    evType = fread(f,1,'char');
    % Read event size
    evSize = fread(f,1,'char');
end


bof=ftell(f);

fseek(f,0,'eof');
numEvents=floor((ftell(f)-bof)/evSize);

% read data
fseek(f,bof,'bof'); % start just after header
% ts are 4 bytes (uint32) skipping 4 bytes after each
allTs=uint32(fread(f,numEvents,'uint32',evSize-4,'l')); 
fseek(f,bof+4,'bof'); % timestamps start 4 after bof
% addr are each 4 bytes (uint32) separated by 4 byte timestamps
allAddr=uint32(fread(f,numEvents,'uint32',evSize-4,'l')); 

fclose(f);

cd_data.ts = double(allTs);

version = 0;
index = find(strcmp(header(:,1), 'Version'));
if (~isempty(index))
    version = header{index, 2};
end

if (version < 2)
    xmask = hex2dec('000001FF');
    ymask = hex2dec('0001FE00');
    polmask = hex2dec('00020000');
    xshift=0; % bits to shift x to right
    yshift=9; % bits to shift y to right
    polshift=17; % bits to shift p to right
else
    xmask = hex2dec('00003FFF');
    ymask = hex2dec('0FFFC000');
    polmask = hex2dec('10000000');
    xshift=0; % bits to shift x to right
    yshift=14; % bits to shift y to right
    polshift=28; % bits to shift p to right
end

% make sure non-negative or an error will result from bitand (glitches can
% somehow result in negative addressses...) 
addr=abs(allAddr); 
cd_data.x=double(bitshift(bitand(addr,xmask),-xshift)); % x addresses
cd_data.y=double(bitshift(bitand(addr,ymask),-yshift)); % y addresses

% 1 for ON, -1 for OFF
cd_data.p=-1+2*double(bitshift(bitand(addr,polmask),-polshift)); 

if (flipX > 0)
    cd_data.x = flipX - cd_data.x;
end

if (flipY > 0)
    cd_data.y = flipY - cd_data.y;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%  makeEBSMoviesCNN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function makeEBSMoviesCNN(info, data)

%This function will make a movie of the EBS data.  It is called by
%cadetDroneCNNMakeFiles.m

% We have to remove all the bad events that have x,y pixels out of bounds.
% This is to avoid breaking the moviemaker.
events = data(find(data(:, 1) < info.numXPixels & ...
    data(:, 2) < info.numYPixels), :);
events = double(events);

%Now make the movies.
makeMovieCNN(info, events, 'Positive');
makeMovieCNN(info, events, 'Negative');
makeMovieCNN(info, events, 'PosNeg');

end  %End of the function makeEBSMoviesCNN.m


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     makeMovieCNN  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function makeMovieCNN(info, events, eventType)

%This function is called by makeEBSMoviesCNN.m.  It will generate a set of
%frames that will be returned to makeEBSMovies1 and it will also plot out
%the individual frames as simple plots.

%Set the figure position information.
left = 750;
bottom = 25;
width = 1220;
height = 560;

rect = [0, 0, width, height];

fig2 = figure();
fig2.Position = [left bottom width height];
fig2.ToolBar = 'none';
set(gcf, 'renderer', 'zbuffer');

%Let's set the colormap.
cmap = colormap(jet);

movieStartTime = info.movieStartTime;
movieLength = info.movieLength;

xEdges = 1 : info.numXPixels + 1;
yEdges = 1 : info.numYPixels + 1;

xPixelVector = 1 : info.numXPixels;
yPixelVector = 1 : info.numYPixels;

deltaT = info.movieFrameLength;

%We want to work in seconds.
movieEndTime = info.movieStartTime + fix(info.movieLength/60.0);

%Generate a movie file name.
if strcmp(eventType, 'Positive')
    outputMovieName = [info.outputMovieDir, 'Pos_', ...
        info.dateTimeStr, '_', num2str(info.movieStartTime, '%03d'), ...
        '-', num2str(movieEndTime, '%03d'), '.avi'];
    dataFileName = [info.outputPositiveEventsDir, ...
        'PosEvents', '_', info.dateTimeStr, '_', ...
        num2str(info.movieStartTime, '%03d'), ...
        '-', num2str(movieEndTime, '%03d'), '.h5'];
end

if strcmp(eventType, 'Negative')
    outputMovieName = [info.outputMovieDir, 'Neg_', ...
        info.dateTimeStr, '_', num2str(info.movieStartTime, '%03d'), ...
        '-', num2str(movieEndTime, '%03d'), '.avi'];
    dataFileName = [info.outputNegativeEventsDir, ...
        'NegEvents', '_', info.dateTimeStr, '_', ...
        num2str(info.movieStartTime, '%03d'), ...
        '-', num2str(movieEndTime, '%03d'), '.h5'];
end

if strcmp(eventType, 'PosNeg')
    outputMovieName = [info.outputMovieDir, 'PosNeg_', ...
        info.dateTimeStr, '_', num2str(info.movieStartTime, '%03d'), ...
        '-', num2str(movieEndTime, '%03d'), '.avi'];
    dataFileName = [info.outputNegativeEventsDir, ...
        'PosNegEvents', '_', info.dateTimeStr, '_', ...
        num2str(info.movieStartTime, '%03d'), ...
        '-', num2str(movieEndTime, '%03d'), '.h5'];
end

%Check the movie frame rate.
if (1/deltaT) > 30
    % if it's a small bin size we want a decently fast frame rate to
    % see it.
    outputFrameRate = 10;
else
    % if it's a large bin size we want to slow down the movie.
    outputFrameRate = ceil(1/deltaT);
end

%Generate the bin edges.  We append one last edge onto the array.
%Generate a vector of times in fractional seconds.
time = events(:, 4);

timeIndex = find(time > info.movieStartTime & time <= movieEndTime);

timeInSeconds = events(timeIndex, 4); 
bins = info.movieStartTime : deltaT : max(timeInSeconds);
bins = [bins (max(bins) + deltaT)];
numberOfFrames = length(bins);

%Now lets just keep the first hundred frames.
if numberOfFrames > 100
    bins = bins(1 : 100);
    numberOfFrames = length(bins);
end

% Now combine these to make the array for saving the cdata from the
% getframes function call.  This will be used to feed into the CNN.
movieFrames = zeros(numberOfFrames, width, height, 3);

v = VideoWriter(outputMovieName);
v.FrameRate = outputFrameRate;
open(v);

%Loop through the number of time bins, make a frame from the data in each
%bin and write those to movieFrames Structure.
for frameCount = 1 : numberOfFrames

    disp(['Frame ', num2str(frameCount), ' Out of ', num2str(length(bins))])

    %Find the indices of the events for the time frame being
    %analyzed.
    time = events(:, 4);
    frameEventIndex = find((time >= bins(frameCount)) & ...
        (time < bins(frameCount) + deltaT));

    %Now create an array of those events.
    frameEvents = events(frameEventIndex, :);

    %Find the positive and negative event indices.
    if strcmp(eventType, 'Positive')
        eventIndex = find(frameEvents(:, 3) == 1);
        figFrameName = [info.positiveFramePlotsDir, 'PF_', ...
            info.dateTimeStr, '_', ...
            num2str(info.movieStartTime, '%03d'), '-', ...
            num2str(movieEndTime, '%03d'), '_', ...
            num2str(frameCount, '%05d'), '.png'];

    end

    if strcmp(eventType, 'Negative')
        eventIndex = find(frameEvents(:, 3) == -1);
        figFrameName = [info.negativeFramePlotsDir, 'NF_', ...
            info.dateTimeStr, '_', ...
            num2str(info.movieStartTime, '%03d'), '-', ...
            num2str(movieEndTime, '%03d'), '_', ...
            num2str(frameCount, '%05d'), '.png'];
    end

    if strcmp(eventType, 'PosNeg')
        eventIndex = find(frameEvents(:, 3) == 1 | frameEvents(:, 3) == -1);
        figFrameName = [info.posNegFramePlotsDir, 'PNF_', ...
            info.dateTimeStr, '_', ...
            num2str(info.movieStartTime, '%03d'), '-', ...
            num2str(movieEndTime, '%03d'), '_', ...
            num2str(frameCount, '%05d'), '.png'];
    end

    histogramValues = getHistogramValues(frameEvents, ...
        eventIndex, xEdges, yEdges);

    imagesc(xPixelVector, yPixelVector, ...
        histogramValues', info.positiveCLims);
    set(gca,'XColor', 'none','YColor','none')

    %Draw the figure to the screen.
    drawnow();

    %Now fill in the movieFrames structure.
    frame = getframe(fig2, rect);

    % Print the image to a .png file
    if info.printFrames
        print('-dpng', figFrameName);
    end
    
    writeVideo(v, frame);
    
end % End of for statement - for frameCount = 1 : length(bins) - 1

%Close the video object.
close(v);

%Write the frame data to a file.
if info.writeH5
    h5create(dataFileName, '/Framedata', size(frame.cdata));
    h5write(dataFileName, '/Framedata', frame.cdata);
end

end  %End of the function makeMovie.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%   histogramValues  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function histogramValues = getHistogramValues(frameEvents, index, ...
    xEdges, yEdges)

%This function will determine the histogram values given as inputs the
%indices of events corresponding to either positive events or negative
%events.  It is called by makeMovies.m
        
%Find the x and y pixel locations for the negative events.
xEvents = frameEvents(index, 1);
yEvents = frameEvents(index, 2);

%Generate a histogram of the negative events.
eventsHistogram = histogram2(xEvents, yEvents, 'XBinEdges', xEdges, ...
    'YBinEdges', yEdges, 'DisplayStyle', 'tile', 'Visible', 'off');

histogramValues = eventsHistogram.Values;

end  %End of the function histogramValues.m


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%  End of Program cadetDroneCNNMakeFiles.m   %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%