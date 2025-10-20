function info = generateEBSInformationStructure(year, month, dayOfMonth, ...
    hour, minute, second, dataPartition)

%This function will fill the information structure for the EBS data
%analysis.  I am keeping this seperate from all of the other
%generateInformationStructure functions because it is likely that this will
%be used by others who will not care or need the rest of the generalized
%generateInformationStructure function and the extra information will only
%serve to confuse them.


%Set up variables for the number of pixels in the x and y direction.
info.numXPixels = 1280;
info.numYPixels = 720;

%Create the Instrument name.
Instrument = 'EBS';
info.instrument = Instrument;

%This function is called by drones.m
%Choose the size of the bounding box to make around the object.
boundingBoxXSize = 150;
boundingBoxYSize = 150;
info.boundingBoxXSize = boundingBoxXSize;
info.boundingBoxYSize = boundingBoxYSize;

%Lets make an outer boundary in the case that we might decide to save only
%part of the data.
outerBoundingBoxSize = 250;  %Units are pixels.
info.outerBoundingBoxSize = outerBoundingBoxSize;

%We sometimes need to remove the edges of the image.  Lets take care of
%that.  We set the percent of the image to remove.  Since the image
%dimensions are not the same we set the percent for each dimension.  
xPercentImageRemoval = 1.0;
yPercentImageRemoval = 1.0;
info.xPercentImageRemoval = xPercentImageRemoval;
info.yPercentImageRemoval = yPercentImageRemoval;

%We also set a flag to either remove the edges or not.
removeImageEdges = 1;
info.removeImageEdges = removeImageEdges;

%A flag to determine if the user wants to see a plot of the cluster
%analysis results.
plotClusterAnalysisResults = 0;
info.plotClusterAnalysisResults = plotClusterAnalysisResults;

%We set a limit on the maximum pixel intensity.  There are some hot pixels
%on the cameras which are not real but which damage the ability to find any
%given object.  Setting the pixel intensity will get rid of them.  This
%value is arbitrary and may need to be changed depending on the bias
%settings on the sensor.
maximumPixelIntensity = 50;
info.maximumPixelIntensity = maximumPixelIntensity;

%Let us set up a factor that will change how the bad pixels are discarded.
%It will be a multiplier onto the mean distance of all of the pixels from
%the centroid.  A factor greater than one will cause more pixels to be
%dropped and likely a poorer result but faster analysis.  A factor less
%than one will retain more pixels with a better result but slower analysis. 
meanDistanceFactor = 1.0;
info.meanDistanceFactor = meanDistanceFactor;

%We add a parameter that determines if the object we are trying to find is
%moving too fast for it to be an actual detection.  Since we typically work
%with constant delta times we really just convert velocity to distance.  So
%we arbitrarily set a distance for the centroid to move inside a given
%frame time.  
centroidDistance = 400; %Units are pixels
info.centroidDistance = centroidDistance;

%We need to set a parameter for finding the bounding box around the object
%in the image.  Basically it throws out events that are not significant.
%This is set up as a percentage subtracted from 1.  So to keep the top 80
%percent of the events we would have percent = 1 - 0.2.
keepHighestPercentage = 25;  %Value is in percent.
info.keepHighestPercentage = keepHighestPercentage;

%Set up a flag that determines if we want to print the individual movie
%frames to .png files.
printFrames = 1;
info.printFrames = printFrames;

%Set the frame length for each frame in the movie.  The units are in
%seconds.  EXAMPLE movieFrameLength = [0.01,0.05] produces two movies, one
%with  frame length 10 milliseconds, one with frame length 50 milliseconds.
movieFrameLength = 0.01;
info.movieFrameLength = movieFrameLength;

%Set the movie starting time in seconds from the first event.
%EXAMPLE info.movieStartTime=0.07 starts the movie 70 milliseconds in.
movieStartTime = 0.0; 

%Do we want to make a movie.
makeMovie = 1;
info.makeMovie = makeMovie;

%Set the number of clusters for the k-means cluster determination.
k = 2;
info.k = k;

%Set the number of k-means cluster replicates.  This is a simple number
%that tells the algorithm how many times to repeat and that after that
%number of times it picks the best result.
kMeansReplicates = 50;
info.kMeansReplicates = kMeansReplicates;

%We need to define a factor that allows us to choose which events to keep
%for the cluster analysis.  This event factor is multiplied onto the mean
%value of the events histogram and then any events greater than that
%product are used to find the events that are clustered.  At the moment
%this is a factor of 4 but this may be changed if it doesn't work in
%general.
eventFactor = 10.0;
info.eventFactor = eventFactor;

%Set the color limits. There are always more negative events so we will set
%two different limits.
positiveCLims = [0 5]; 
negativeCLims = [0 5];
info.positiveCLims = positiveCLims;
info.negativeCLims = negativeCLims; 

%Set up the line widths for the boxes around the drone.
positiveInnerLineWidth = 1.0;
positiveOuterLineWidth = 3.0;
negativeInnerLineWidth = 1.0;
negativeOuterLineWidth = 3.0;
info.positiveInnerLineWidth = positiveInnerLineWidth;
info.positiveOuterLineWidth = positiveOuterLineWidth;
info.negativeInnerLineWidth = negativeInnerLineWidth;
info.negativeOuterLineWidth = negativeOuterLineWidth;

%Set up a flag as whether to plot the boxes around the object.
plotBoxes = 0;
info.plotBoxes = plotBoxes;

%Flag to write the files in the H5 format.
writeH5 = 1;
info.writeH5 = writeH5;

%Handle the directory and file input and output names.
%Create the root path.
rootPath = '/SS2/Drones/';
inputDataPath = '/SS2/Drones/Data/Input/';
outputDataPath = '/SS2/Drones/Data/Output/';

info.rootPath = rootPath;
info.inputDataPath = inputDataPath;
info.outputDataPath = outputDataPath;

info.dataPartition = dataPartition;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%  Time Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Take care of the date and time information.
info.year = year;
info.yearStr = num2str(year);

info.month = month;
info.monthStr = num2str(month, '%02d');

info.dayOfMonth = dayOfMonth;
info.dayOfMonthStr = num2str(dayOfMonth, '%02d');

info.hour = hour;
info.hourStr = num2str(hour, '%02d');

info.minute = minute;
info.minuteStr = num2str(minute, '%02d');

info.second = second;
info.secondStr = num2str(fix(second), '%02d');

info.dateTimeStr = [info.yearStr, '-', info.monthStr, '-', ...
    info.dayOfMonthStr, '_', info.hourStr, '-', info.minuteStr, ...
    '-', info.secondStr];

inputMovieName = ['recording_', info.yearStr, '-', info.monthStr, '-', ...
     info.dayOfMonthStr, '_', info.hourStr, '-', info.minuteStr, '-', ...
     info.secondStr, '_', num2str(dataPartition, '%02d')];

inFileName = [inputDataPath, 'dat/', inputMovieName, '.dat'];
saveFileName = [inputDataPath, 'h5/', inputMovieName, '.h5'];

info.inFileName = inFileName;
info.saveFileName = saveFileName;

info.movieName = ['EBS_', inputMovieName, '_Movie'];


outputDir = [outputDataPath, info.dateTimeStr, '/'];
outputPositiveEventsDir = [outputDir, 'FrameEvents/'];
outputNegativeEventsDir = [outputDir, 'FrameEvents/'];
outputPosNegEventsDir = [outputDir, 'FrameEvents/'];
outputMovieDir = [outputDir, 'Movie/'];
positiveFramePlotsDir = [outputDir, 'PositiveFramePlots/'];
negativeFramePlotsDir = [outputDir, 'NegativeFramePlots/'];
posNegFramePlotsDir = [outputDir, 'PosNegFramePlots/'];

%Now fill the info structure.
info.outputDir = outputDir;
info.outputPositiveEventsDir = outputPositiveEventsDir;
info.outputNegativeEventsDir = outputNegativeEventsDir;
info.outputMovieDir = outputMovieDir;
info.positiveFramePlotsDir = positiveFramePlotsDir;
info.negativeFramePlotsDir = negativeFramePlotsDir;
info.posNegFramePlotsDir = posNegFramePlotsDir;

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