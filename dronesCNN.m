%This script will mirror drones.m but will just work to generate data for
%the CNN model we will try to operate.
close all;
clearvars;
%clf;

dbstop if error; 

%Create a date and time for the input and output filenames.
%The original octocopter movie has year = 2024, month = 06, day = 10, hour
%= 00, minute = 00, second = 00.
year = 2024;
month = 6;
dayOfMonth = 14;
hour = 22;
minute = 56;
second = 40;

%Choose the size of the bounding box to make around the object.
boundingBoxXSize = 40;
boundingBoxYSize = 40;

%Lets make an outer boundary in the case that we might decide to save only
%part of the data.
outerBoundingBoxSize = 250;  %Units are pixels.

%We sometimes need to remove the edges of the image.  Lets take care of
%that.  We set the percent of the image to remove.  Since the image
%dimensions are not the same we set the percent for each dimension.  
xPercentImageRemoval = 1.0;
yPercentImageRemoval = 1.0;

%We also set a flag to either remove the edges or not.
removeImageEdges = 1;

%We set a limit on the maximum pixel intensity.  There are some hot pixels
%on the cameras which are not real but which damage the ability to find any
%given object.  Setting the pixel intensity will get rid of them.  This
%value is arbitrary and may need to be changed depending on the bias
%settings on the sensor.
maximumPixelIntensity = 50;

%Let us set up a factor that will change how the bad pixels are discarded.
%It will be a multiplier onto the mean distance of all of the pixels from
%the centroid.  A factor greater than one will cause more pixels to be
%dropped and likely a poorer result but faster analysis.  A factor less
%than one will retain more pixels with a better result but slower analysis. 
meanDistanceFactor = 1.0;

%We add a parameter that determines if the object we are trying to find is
%moving too fast for it to be an actual detection.  Since we typically work
%with constant delta times we really just convert velocity to distance.  So
%we arbitrarily set a distance for the centroid to move inside a given
%frame time.  
centroidDistance = 500; %Units are pixels

%We need to set a parameter for finding the bounding box around the object
%in the image.  Basically it throws out events that are not significant.
%This is set up as a percentage subtracted from 1.  So to keep the top 80
%percent of the events we would have percent = 1 - 0.2.
keepHighestPercentage = 25;  %Value is in percent.

%Set up a flag that determines if we want to print the individual movie
%frames to .png files.
printFrames = 1;

%Set up a flag that tells the program if we want to save the movie frames
%to a file.  This is so that we can run a CNN model on the data.
writeH5 = 1;

%Set the frame length for each frame in the movie.  The units are in
%seconds.  EXAMPLE movieFrameLength = [0.01,0.05] produces two movies, one
%with  frame length 10 milliseconds, one with frame length 50 milliseconds.
movieFrameLength = 0.01;

%Do we want to make a movie.
makeMovie = true;

%Set the color limits. There are always more negative events so we will set
%two different limits.
positiveCLims = [0 50]; 
negativeCLims = [0 5];

%Set up the line widths for the boxes around the drone.
positiveInnerLineWidth = 1.0;
positiveOuterLineWidth = 3.0;
negativeInnerLineWidth = 1.0;
negativeOuterLineWidth = 3.0;

%Set up a flag as whether to plot the boxes around the object.
plotBoxes = 1;

%Set the movie starting time in seconds from the first event.
%EXAMPLE info.movieStartTime=0.07 starts the movie 70 milliseconds in.
movieStartTime = 0.0; 

%Now generate the information structure.
info = generateEBSInformationStructure(year, month, dayOfMonth, ...
    hour, minute, second, boundingBoxXSize, boundingBoxYSize, ...
    xPercentImageRemoval, yPercentImageRemoval, removeImageEdges, ...
    maximumPixelIntensity, meanDistanceFactor, centroidDistance, ...
    keepHighestPercentage, printFrames, movieFrameLength, movieStartTime, ...
    makeMovie, positiveCLims, negativeCLims, outerBoundingBoxSize, ...
    positiveInnerLineWidth, positiveOuterLineWidth, writeH5, ...
    negativeInnerLineWidth, negativeOuterLineWidth, plotBoxes);

%Read in the data from the .dat file.  We will also write out the data as a
%.h5 file for further use.
data = getEBSDatData(info);

%Lets find the potential length of the data set.  We do not know this
%apriori since each movie is different.
[events, rows] = size(data);
movieLength = events/1.0e7;

%disp(['Total Number of Events : ', num2str(events)])

%Choose the length of the movie to be made in seconds.
info.movieLength = movieStartTime + 60.0; 


%Make movies of the data.
makeEBSMoviesCNN(info, data)

