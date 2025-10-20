function  makeMovie(info, events, eventType)

%This function is called by makeEBSMoviesCNN.m.  

%Set the figure position information.
left = 750;
bottom = 25;
width = 1220;
height = 560;

%This variable is used to set the size of the movie frame.  If this is not
%set then the frame/writeVideo movie command will fail.
rect = [0, 0, width, height];

fig2 = figure();
fig2.Position = [left bottom width height];
fig2.ToolBar = 'none';
set(gcf, 'renderer', 'zbuffer');

%Let's set the colormap.
cmap = colormap(jet);

movieStartTime = info.movieStartTime;

xPixelVector = 1 : info.numXPixels;
yPixelVector = 1 : info.numYPixels;

%Generate some names for data and plot files.
[outputMovieName, dataFileName, fitFrameName] = getMovieNames(info, ...
    eventType);

%Get the movie frame length.
deltaT = info.movieFrameLength;

%Check the movie frame rate.
if (1/deltaT) > 30
    % if it's a small bin size we want a decently fast frame rate to
    % see it.
    outputFrameRate = 10;
else
    % if it's a large bin size we want to slow down the movie.
    outputFrameRate = ceil(1/deltaT);
end

%Generate a vector of the times.  These are in seconds.
time = events(:, 4);

%Generate a set of bins.
bins = info.movieStartTime : deltaT : info.movieEndTime;
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
for frameCount = 1 : length(bins) 

     disp(['Frame ', num2str(frameCount), ' Out of ', ...
         num2str(length(bins))])
    
    frameSeconds = bins(frameCount);

    titleStr = getTitleStr(info, frameSeconds);

    %Find the indices of the events for the time frame being
    %analyzed.
    frameEventStartTime = bins(frameCount);
    frameEventEndTime = bins(frameCount) + deltaT;

    frameEventIndex = find((time >= frameEventStartTime) & ...
        (time < frameEventEndTime));

    %Now create an array of those events.
    frameEvents = events(frameEventIndex, :);

    %Generate a figure frame name for each frame.
    figFrameName = [fitFrameName, num2str(frameCount, '%05d'), '.png'];

    %Find the positive and negative event indices.
    if strcmp(eventType, 'Positive')
        eventIndex = find(frameEvents(:, 3) == 1);
    end

    if strcmp(eventType, 'Negative')
        eventIndex = find(frameEvents(:, 3) == -1);
    end

    if strcmp(eventType, 'PosNeg')
        eventIndex = find(frameEvents(:, 3) == 1 | frameEvents(:, 3) == -1);
    end

    %Get the histogram values.
    histogramValues = getHistogramValues(info, frameEvents, ...
        eventIndex);

    %Lets find a bounding box around the object being "filmed".
    if frameCount == 1
        guessXL = 500;
        guessXR = 600;
        guessYD = 500;
        guessYU = 600;

    else
        guessXL = xL;
        guessXR = xR;
        guessYD = yD;
        guessYU = yU;
    end

    [xL, xR, yU, yD] = ...
        getObjectBoundingBox2(info, fliplr(histogramValues), ...
        guessXL, guessXR, guessYD, guessYU);

    % Plot the frame of events.
    imagesc(xPixelVector, yPixelVector, ...
        histogramValues', info.positiveCLims);
    set(gca,'XColor', 'none','YColor','none')

    hold on
    
    if info.plotBoxes
        plot([xL, xR], [yU, yU], 'g', ...
            [xL, xL], [yD, yU], 'g', ...
            [xL, xR], [yD, yD], 'g', ...
            [xR, xR], [yD, yU], 'g', ...
            'LineWidth', info.positiveOuterLineWidth);
        
        xlim([0 info.numXPixels])
        ylim([0 info.numYPixels])
    end

    hold off

    %Draw the figure to the screen.
    drawnow();

    % Print the image to a .png file
    if info.printFrames
        print('-dpng', figFrameName);
    end

    %Now fill in the movieFrames structure.
    frame = getframe(fig2, rect);
    writeVideo(v, frame);
    
end % End of for statement - for frameCount = 1 : length(bins) - 1

%Close the video object.
close(v);

%Write the frame data to a file.
if info.writeH5
    h5create(dataFileName, '/Histogram', size(histogramValues));
    h5write(dataFileName, '/Histogram', histogramValues);
end

end  %End of the function makeMovie.m