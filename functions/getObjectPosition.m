function objectPosition = getObjectPosition(info, Events);



%This function is called by jdwGen4Visualizer.m
%This function will generate a vector of x and y pixel
%locations found from determining the location of the object in question.
%There will be no plotting or other visual information generated.  This
%function is really just being used to see how fast we can get these
%coordinate positions.  


movieStartTime = info.movieStartTime;
movieLength = info.movieLength;

xedges = 1 : info.numXPixels + 1;
yedges = 1 : info.numYPixels + 1;

% We have to remove all the bad events that have x,y pixels out of bounds.
% This is to avoid breaking the moviemaker.
EventsT = Events(find(Events(:, 1) < info.numXPixels & Events(:, 2) < info.numYPixels), :);
EventsT = double(EventsT);

%Generate a vector of times in fractional seconds.
TimeInSecs = EventsT(:,4)/1E6; 

%Initialize the frame array.
frame = zeros(info.numXPixels,info.numYPixels); 

%Loop through the different values of the movie frame length.
for nd = 1 : length(info.movieFrames) % loop through our time bins
    deltaT = info.movieFrames(nd);

    if deltaT > max(TimeInSecs) % it breaks the histogram...
        continue; %... so abort this particular stocktimebin
    end

	%The data is divided into chunks of time.  For each chunk we positive
	%and negative events and then generate a histogram of the events.  Next
	%we find the location of the object by looking for the maximum event
	%counts from the histogram and then we generate a bounding box from
	%that maximum.

    %Generate the bin edges.  We append one last edge onto the array.
    bins = 0 : deltaT : max(TimeInSecs); 
    bins = [bins (max(bins) + deltaT)]; 

	%Set up some variables for the position information.
	numEvents = length(bins);
	positiveXCenter = zeros(1, numEvents); %Remember this gives 1 row by numEvents columns.
	positiveYCenter = zeros(1, numEvents);
	positiveXBoundingBox = zeros(numEvents, 4);
	positiveYBoundingBox = zeros(numEvents, 4);
	
	negativeXCenter = zeros(1, numEvents);
	negativeYCenter = zeros(1, numEvents);
	negativeXBoundingBox = zeros(numEvents, 4);
	negativeYBoundingBox = zeros(numEvents, 4);
	eventTime = zeros(1, numEvents);

	%Loop through the time chunks.  The frameCount iterate is a leftover
	%from this same function that was used to make a movie.  I am keeping
	%the same variable so that we can compare if necessary.
	for frameCount = 1 : numEvents - 1 % frame count

		%Set up the event time values.
		eventTime(frameCount) = bins(frameCount);


		if (bins(frameCount) < movieStartTime | bins(frameCount) > (movieStartTime + movieLength))
			continue; % ignore everything outside of the movie selection
		else

			%Find the indices of the events for the time frame being
			%analyzed.
			frameEventIndex = find((TimeInSecs >= bins(frameCount)) & ...
				(TimeInSecs < bins(frameCount) + deltaT)); % event index in each time bin

			%Now create an array of those events.
			frameEvents = EventsT(frameEventIndex,:);

			%Find the positive and negative event indices.
			positiveEventIndex = find(frameEvents(:, 3) == 1); % index of which events are positive
			negativeEventIndex = find(frameEvents(:, 3) == 0); % index of which events are negative

			%Find the x and y pixel locations for the negative events.
			xPositionNegativeEvents = frameEvents(negativeEventIndex, 1);   % these are the x's of the negative events
			yPositionNegativeEvents = frameEvents(negativeEventIndex, 2);   % these are the y's of the negative events
                
			%Find the x and y pixel locations for the positive events.
			xPositionPositiveEvents = frameEvents(positiveEventIndex, 1);   % these are the x's of the positive events
			yPositionPositiveEvents = frameEvents(positiveEventIndex, 2);   % these are the y's of the positive events

			%Generate a histogram of the negative events.
			negativeEventsHistogram = histogram2(xPositionNegativeEvents, yPositionNegativeEvents, 'XBinEdges', xedges, 'YBinEdges',...
				yedges, 'DisplayStyle', 'tile', 'Visible', 'off');
 
			negativeHistogramValues = negativeEventsHistogram.Values;

			%Generate a histogram of the positive events.
			positiveEventsHistogram = histogram2(xPositionPositiveEvents, yPositionPositiveEvents, 'XBinEdges', xedges, 'YBinEdges',...
				yedges, 'DisplayStyle', 'tile', 'Visible', 'off');

			positiveHistogramValues = positiveEventsHistogram.Values;

			%Lets find a bounding box around the object being "filmed".
			[xBBPositive, yBBPositive, xCenterPositive, yCenterPositive] = getObjectBoundingBox(info, positiveHistogramValues);
			[xBBNegative, yBBNegative, xCenterNegative, yCenterNegative] = getObjectBoundingBox(info, negativeHistogramValues);


		end %End of if-else clause - if (bins(frameCount) < movieStartTime | bins(frameCount) > (movieStartTime + movieLength))
		

		%Fill the arrays.
		positiveXCenter(frameCount) = xCenterPositive;
		positiveYCenter(frameCount) = yCenterPositive;
		positiveXBoundingBox(frameCount, :) = xBBPositive;
		positiveYBoundingBox(frameCount, :) = yBBPositive;
		negativeXCenter(frameCount) = xCenterNegative;
		negativeYCenter(frameCount) = yCenterNegative;
		negativeXBoundingBox(frameCounts, :) = xBBNegative;
		negativeYBoundingBox(frameCounts, :) = yBBNegative;

	end %End of for loop - for frameCount = 1 : length(bins) - 1 % frame count

end %End of for loop - for nd = 1 : length(info.movieFrames) 

%Now generate and fill the objectPosition structure
%First do the positive locations.
objectPosition.positiveXCenter = positiveXCenter;
objectPosition.positiveXCenter = positiveYCenter;
objectPosition.positiveXBoundingBox = positiveXBoundingBox;
objectPosition.positiveYBoundingBox = positiveYBoundingBox;

%Next do the negative locations.
objectPosition.negativeXCenter = negativeXCenter;
objectPosition.negativeYCenter = negativeYCenter;
objectPosition.negativeXBoundingBox = negativeXBoundingBox;
objectPosition.negativeYBoundingBox = positiveYBoundingBox;

%Add in the time information.
objectPosition.eventTime = eventTime;


end  %End of the function getObjectPosition.m