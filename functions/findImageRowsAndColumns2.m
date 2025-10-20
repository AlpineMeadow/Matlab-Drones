function [rows, cols] = findImageRowsAndColumns2(info, histogramValues, ...
    frameCount)

%This function will find the pixels that are most likely to represent the
%image we are looking for.  It is called by getObjectBoundingBox2.m


%Here we try the matlab kmeans function.
xPixelVector = 1 : info.numXPixels;
yPixelVector = 1 : info.numYPixels;

%First set the max value of the histogram to zero.
maxIndex = max(histogramValues, [], 'all');
histogramValues(maxIndex) = 0.0;

%Lets try it again.
maxIndex = max(histogramValues, [], 'all');
histogramValues(maxIndex) = 0.0;

%Now lets find the mean value of the histogram.
meanHistogramValue = mean(histogramValues, 'all');

%Now find the k-means values.
eventFactor = 4.0;
[rowIndex, colIndex] = find(histogramValues > ...
    info.eventFactor*meanHistogramValue);

%Generate an array from the events that support the criteria in the find
%just above.  The array will be [number of events, 2].
X = [rowIndex, colIndex];

%Find the number of clusters.
opts = statset('Display','final');

[clusterIndex, centroidCoordinates] = kmeans(X, info.k, ...
    'Distance', 'sqeuclidean', 'Replicates', info.kMeansReplicates);

%Given the centroid values, lets find a bounding box.
meanXCentroid = mean(centroidCoordinates(:, 1));
meanYCentroid = mean(centroidCoordinates(:, 2));

xL = fix(meanXCentroid - info.centroidDistance/2.0);
xR = fix(meanXCentroid + info.centroidDistance/2.0);
yU = fix(meanYCentroid - info.centroidDistance/2.0);
yD = fix(meanYCentroid + info.centroidDistance/2.0);

if info.plotClusterAnalysisResults
    plotClusterAnalysisResults(info, histogramValues, ...
        frameCount, xL, xR, yU, yD);
end

%Find the maximum value of the interior histogram.
maxValue = max(max(histogramValues));
maxValueIndex = find(histogramValues == maxValue);
notMaxValueIndex = find(histogramValues ~= maxValue);

%Remove any hot pixels
% if maxValue > info.maximumPixelIntensity
%     newMaxValue = max(max(histogramValues(notMaxValueIndex)));
%     histogramValues(maxValueIndex) = newMaxValue;
%     maxValue = newMaxValue;
% end

peakPercent = info.keepHighestPercentage/100.0;
highValue = (1.0 - peakPercent)*maxValue;
[rows, cols] = find(histogramValues >= highValue);

end  %End of the function findImageRowsAndColumns2.m