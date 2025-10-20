function histogramValues = getHistogramValues(info, frameEvents, index)

%This function will determine the histogram values given as inputs the
%indices of events corresponding to either positive events or negative
%events.  It is called by makeMovies.m

xEdges = 1 : info.numXPixels + 1;
yEdges = 1 : info.numYPixels + 1;

%Find the x and y pixel locations for the negative events.
xEvents = frameEvents(index, 1);
yEvents = frameEvents(index, 2);

%Generate a histogram of the negative events.
eventsHistogram = histogram2(xEvents, yEvents, 'XBinEdges', xEdges, ...
    'YBinEdges', yEdges, 'DisplayStyle', 'tile', 'Visible', 'off');

histogramValues = eventsHistogram.Values;

end