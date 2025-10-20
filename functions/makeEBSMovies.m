function makeEBSMovies(info, data)

%This function will make a movie of the EBS data.

% fclose('all');
% close all;
% close(gcf)
% clf;

movieStartTime = info.movieStartTime;
movieLength = info.movieLength;

xEdges = 1 : info.numXPixels + 1;
yEdges = 1 : info.numYPixels + 1;


t0 = info.movieName;

%Set the figure position information.
left = 750;
bottom = 25;
width = 1200;
height = 500;

% Make the movie frames
%f = figure('Units','Inches','Position',[11 0.5 7.65 9.9]);


fig2 = figure();
fig2.Position = [left bottom width height];
fig2.ToolBar = 'none';
%ax = gca();
    
%ax = axes();
%fig1.Position = [750 25 1200 500];
%ax.Position = [0.13, 0.02, 0.995, 0.950];

%Set the color map.
colormap(jet);

xPixelVector = 1 : info.numXPixels;
yPixelVector = 1 : info.numYPixels;

%Set the gcf position.
%set(gcf, 'Position', [left bottom width height]);

%Hold the figure handle parameters for all of the frames to be plotted.
%This is because the video writer needs to have the same size for each
%frame to be saved. Not sure why matlab is changing the sizes.
hold on;


% We have to remove all the bad events that have x,y pixels out of bounds.
% This is to avoid breaking the moviemaker.
EventsT = data(find(data(:, 1) < info.numXPixels & ...
    data(:, 2) < info.numYPixels), :);
EventsT = double(EventsT);

%Generate a vector of times in fractional seconds.
TimeInSecs = EventsT(:, 4); 

%Initialize the frame array.
frame = zeros(info.numXPixels, info.numYPixels); 

%Initialize the polarity array. Must be type double because we're going 
%to set negative polarities to -1                 
frame_net_pol = double(zeros(info.numXPixels,info.numYPixels)); 

%Initialize the positive event frame.
frame_num_pos = zeros(info.numXPixels,info.numYPixels); 
                
%Initialize the negative event frame.
frame_num_neg = zeros(info.numXPixels,info.numYPixels); 

%Loop through the different values of the movie frame length.
for nd = 1 : length(info.movieFrameLength) % loop through our time bins
    %Set the gcf position.
%    set(gcf, 'Position', [left bottom width height]);

    deltaT = info.movieFrameLength(nd);

    %Generate a movie file name.
    realMovieName=[info.movieName, '_', num2str(deltaT*1e3),'.avi']; 

    if deltaT > max(TimeInSecs) % it breaks the histogram...
        continue; %... so abort this particular stocktimebin
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

    % Set up the writer object and open it.
    writerObj = VideoWriter(realMovieName, 'Uncompressed AVI');
    writerObj.FrameRate = outputFrameRate;
    open(writerObj);

    %Generate the bin edges.  We append one last edge onto the array.
    bins = 0 : deltaT : max(TimeInSecs); 
    bins = [bins (max(bins) + deltaT)]; 

    if info.makeMovie 
        for frameCount = 1 : length(bins) - 1 

            if (bins(frameCount) < movieStartTime | ...
                    bins(frameCount) > (movieStartTime + movieLength))
                continue; 
            else
                % create the movie frame file name with the frame index.
                figname = ['frame', num2str(frameCount, '%010i'), '.png']; 

				%Find the indices of the events for the time frame being
				%analyzed.
                frameEventIndex = find((TimeInSecs >= bins(frameCount)) & ...
                    (TimeInSecs < bins(frameCount) + deltaT));

				%Now create an array of those events.
                frameEvents = EventsT(frameEventIndex, :);

				%Find the positive and negative event indices.
                positiveEventIndex = find(frameEvents(:, 3) == 1); 
                negativeEventIndex = find(frameEvents(:, 3) == -1); 

				%Find the x and y pixel locations for the negative events.
                xPositionNegativeEvents = frameEvents(negativeEventIndex, 1);   
                yPositionNegativeEvents = frameEvents(negativeEventIndex, 2);   
                
				%Find the x and y pixel locations for the positive events.
                xPositionPositiveEvents = frameEvents(positiveEventIndex, 1);  
                yPositionPositiveEvents = frameEvents(positiveEventIndex, 2);  

                %Generate a histogram of the negative events.
                negativeEventsHistogram = histogram2(xPositionNegativeEvents, ...
                    yPositionNegativeEvents, 'XBinEdges', xEdges, 'YBinEdges',...
                     yEdges, 'DisplayStyle', 'tile', 'Visible', 'off');
 
                negativeHistogramValues = negativeEventsHistogram.Values;

                %Generate a histogram of the positive events.
                positiveEventsHistogram = histogram2(xPositionPositiveEvents, ...
                    yPositionPositiveEvents, 'XBinEdges', xEdges, 'YBinEdges',...
                    yEdges, 'DisplayStyle', 'tile', 'Visible', 'off');

				positiveHistogramValues = positiveEventsHistogram.Values;

				%Lets find a bounding box around the object being "filmed".
                [PxL, PxR, PyD, PyU] = ...
                     getObjectBoundingBox(info, positiveHistogramValues);
 				[NxL, NxR, NyD, NyU] = ...
                     getObjectBoundingBox(info, negativeHistogramValues);



                %Generate a tiled layout.
                t = tiledlayout(1, 2, 'Visible', 'on');

                % Plot the frame of positive events.
                nexttile(1);
                hh = imagesc(xPixelVector, yPixelVector, ...
                    positiveHistogramValues, info.clims);
                daspect([1 1 1]);
                title('Positive Events');
                set(gca,'YDir','normal')
                axis xy
                colorbar

                hold on

                pp = plot([PxL, PxR], [PyU, PyU], 'r', ...
                    [PxL, PxL], [PyD, PyU], 'r', ...
                    [PxL, PxR], [PyD, PyD], 'r', ...
                    [PxR, PxR], [PyD, PyU], 'r');
                xlim([0 info.numXPixels])
                ylim([0 info.numYPixels])

                %Plot the frame of negative events.
                nexttile(2);
                imagesc(xPixelVector, yPixelVector, ...
                    negativeHistogramValues, info.clims);
                title('Negative Events');
                set(gca,'YDir','normal');
                daspect([1 1 1])
                axis xy
                colorbar

                NP = plot([NxL, NxR], [NyU, NyU], 'r', ...
                    [NxL, NxL], [NyD, NyU], 'r', ...
                    [NxL, NxR], [NyD, NyD], 'r', ...
                    [NxR, NxR], [NyD, NyU], 'r');
                xlim([0 info.numXPixels])
                ylim([0 info.numYPixels])

                % Generate a title string.
                timeStr = ['Time = ',num2str(bins(frameCount),'%.5f'),' to ',...
                    num2str((bins(frameCount) + deltaT),'%.5f'),' sec'];
                sgtitle({t0;timeStr},'Interpreter','none');

                %Draw the figure to the screen.
                drawnow();

                % Print the image to a file...
                if info.printFrames
                    print('-dpng', [info.outputDirName, figname]);
                end

                writeVideo(writerObj, getframe(fig2));

                disp('After writeVideo writes a frame : ')
                disp(['Frame : ', num2str(frameCount)])
                disp(['writerObj.Height : ', num2str(writerObj.Height)])
                disp(['writerObj.Width : ', num2str(writerObj.Width)])

                joe = 1;
%                writeVideo(writerObj, getframe(gcf));

            end % of the if/else checking we are in the movie start/length

        end % of the loop over the movie frames
        close(gcf)
        close(writerObj); % close the video file
        % %Close the current figure.
        % close(gcf);  
        % 
        % %Close the video file.
        % close(writerObj); 

    end % of the if(false/true)

end % of looping through different desired frame sizes.

end  %End of the function makeEBSMovies.m