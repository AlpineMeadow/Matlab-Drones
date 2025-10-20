function makeEBSMovies2(Events, info)

load('EBSjw')
fclose('all')
close all

movieStartTime = info.movieStartTime;
movieLength = info.movieLength;

xedges = 1 : info.numXPixels + 1;
yedges = 1 : info.numYPixels + 1;


t0 = info.movieName;

% Make the movie frames
f = figure('Units','Inches','Position',[11 0.5 7.65 9.9]);
%f = figure('Position', [1050 10 800 1200]);

% We have to remove all the bad events that have x,y pixels out of bounds.
% This is to avoid breaking the moviemaker.
EventsT = Events(find(Events(:, 1) < info.numXPixels & Events(:, 2) < info.numYPixels), :);
EventsT = double(EventsT);

%Generate a vector of times in fractional seconds.
TimeInSecs = EventsT(:,4)/1E6; 

%Initialize the frame array.
frame = zeros(info.numXPixels,info.numYPixels); 

%Initialize the polarity array. Must be type double because we're going to set negative polarities to -1               
frame_net_pol=double(zeros(info.numXPixels,info.numYPixels)); 

%Initialize the positive event frame.
frame_num_pos=zeros(info.numXPixels,info.numYPixels); 
                
%Initialize the negative event frame.
frame_num_neg=zeros(info.numXPixels,info.numYPixels); 

%Declare the color map.                
colormap(EBSjetwhite);

%Loop through the different values of the movie frame lengths.
for nd = 1 : length(info.movieFrames) % loop through our time bins
    deltaT = info.movieFrames(nd);

    if deltaT > max(TimeInSecs) % it breaks the histogram...
        continue; %... so abort this particular stocktimebin
    end

    %Generate the bin edges.  We append one last edge onto the array.
    bins = 0 : deltaT : max(TimeInSecs); 
    bins = [bins (max(bins) + deltaT)]; 

    %Generate a movie file name.
    realMovieName=[info.movieName, '_',num2str(deltaT*1E3),'.avi']; % create a movie file name.

    %Check the movie frame rate.
    if (1/deltaT) > 30
        outputFrameRate = 10; % if it's a small bin size we want a decently fast frame rate to see it.
    else
        outputFrameRate = ceil(1/deltaT); % if it's a large bin size we want to slow down the movie.
    end


    % Set up the writer object and open it.
    writerObj = VideoWriter(realMovieName, 'Uncompressed AVI');
    writerObj.FrameRate = outputFrameRate;
    open(writerObj);

    if info.makeMovie % This is the on/off switch to actually make the movie.

        for frameCount = 1 : length(bins) - 1 % frame count

            if (bins(frameCount) < movieStartTime | bins(frameCount) > (movieStartTime + movieLength))
                continue; % ignore everything outside of the movie selection
            else

                % create the movie frame file name with the frame index.
                figname=['frame',num2str(frameCount,'%010i'),'.png']; 

                f_ev_index = find((TimeInSecs >= bins(frameCount)) & ...
                    (TimeInSecs < bins(frameCount) + deltaT)); % event index in each time bin

                f_ev = EventsT(f_ev_index,:);

                loc_ev_pos=find(f_ev(:,3) == 1); % index of which events are positive
                loc_ev_neg=find(f_ev(:,3) == 0); % index of which events are negative

                f_ev_neg_x=f_ev(loc_ev_neg, 1);   % these are the x's of the negative events
                f_ev_neg_y=f_ev(loc_ev_neg, 2);   % these are the y's of the negative events
                
                f_ev_pos_x=f_ev(loc_ev_pos, 1);   % these are the x's of the positive events
                f_ev_pos_y=f_ev(loc_ev_pos, 2);   % these are the y's of the positive events
                
                h_neg=histogram2(f_ev_neg_x, f_ev_neg_y, 'XBinEdges', xedges, 'YBinEdges',...
                     yedges, 'DisplayStyle', 'tile', 'Visible', 'off');
 
                h_neg_v=h_neg.Values;
                disp(['For frame count ', num2str(frameCount), ' Size of h_neg is : ', num2str(h_neg.NumBins)])

                h_pos=histogram2(f_ev_pos_x, f_ev_pos_y, 'XBinEdges', xedges, 'YBinEdges',...
                    yedges, 'DisplayStyle', 'tile', 'Visible', 'off');
                h_pos_v=h_pos.Values;
                disp(['For frame count ', num2str(frameCount), ' Size of h_pos is : ', num2str(h_pos.NumBins)])

                t=tiledlayout(2,1,'Visible','on');
                ax = gca();
%                set(ax1,'fontsize',22,'Color',[0.8 0.8 0.8],'gridcolor',[1 1 1],'gridalpha',0.9) % set the axis color

                % Plot the frame of positive events.
                nexttile(1);
%                imagesc(h_pos_v',info.clims);
                daspect([1 1 1]);
                title('Positive Events');
                axis xy
                xlabel('Pixel Number')
                ylabel('Pixel Number')                
                colorbar

%                hold on 

                plot([0, info.numXPixels], ...
                    [info.propellerPositionY, info.propellerPositionY])
                plot([info.propellerPositionX, info.propellerPositionX], ...
                    [0, info.numYPixels])


                %Plot the frame of negative events.
                nexttile(2);
                imagesc(h_neg_v',info.clims);
                title('Negative Events');
                daspect([1 1 1]);
                axis xy
                xlabel('Pixel Number')
                ylabel('Pixel Number')
                colorbar

                hold on 

                plot([info.propellerPositionX], [info.propellerPositionY],...
                    'b*', 'MarkerSize', 18)


                % Generate a title string.
                t1 = ['Time = ',num2str(bins(frameCount),'%.5f'),' to ',...
                    num2str((bins(frameCount) + deltaT),'%.5f'),' sec'];
                sgtitle({t0;t1},'Interpreter','none');
                
               drawnow();

               if (info.printFrames == 1)
                    % Print the image to a file...
                    print('-dpng',[info.outFileDir, figname]);
               end

               %Now write the image to the video as a single frame.
                writeVideo(writerObj, getframe(gcf));

            end % of the if/else checking we are in the movie start/length

        end % of the loop over the movie frames
        close(gcf)
        close(writerObj); % close the video file
        %delete('frame*.png'); % get rid of all the frame images
    end % of the if(false/true)


end % of looping through different desired frame sizes.


end  %End of the function makeEBSMovies2.m