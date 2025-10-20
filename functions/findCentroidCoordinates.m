function [meanXCentroidCoordinate, meanYCentroidCoordinate] = ...
    findCentroidCoordinates(info, histogramValues);

%This function will determine the x and y coordinates of the centroid of
%the object in the image we are analyzing.  It is called by
%getObjectBoundingBox2.m

%Here we try the matlab kmeans function.
xPixelVector = 1 : info.numXPixels;
yPixelVector = 1 : info.numYPixels;

%First set the max value of the histogram to zero.
% maxValue = max(histogramValues, [], 'all');
% [maxRows, maxCols] = find(histogramValues == maxValue);
% histogramValues(maxRows, maxCols) = 0.0;
% 
% %Lets try it again.
% maxIndex = max(histogramValues, [], 'all');
% histogramValues(maxIndex) = 0.0;

maxValue = max(histogramValues, [], 'all');
[maxValueRowIndex, maxValueColIndex] = find(histogramValues == maxValue);

%Now lets find the mean value of the histogram.
meanHistogramValue = mean(histogramValues, 'all');
stdHistogramValue = std(histogramValues, 0, 'all');

%Now find the k-means values.
%[rowIndex, colIndex] = find(histogramValues > ...
%    info.eventFactor*meanHistogramValue);
[rowIndex, colIndex] = find(histogramValues > ...
    5*stdHistogramValue);

%Generate an array from the events that support the criteria in the find
%just above.  The array will be [number of events, 2].
X = [rowIndex, colIndex];

%Check to see that we can actually use the k-means algorithm.
[numXRows, numXCols] = size(X);

if numXRows <= info.k
    meanXCentroidCoordinate = info.numXPixels/2.0;
    meanYCentroidCoordinate = info.numYPixels/2.0;
else
    %Find the number of clusters.
    opts = statset('Display','final');

    %Use the kmeans algorithm to find the location of the centroid of the
    %object in the image.
    [clusterIndex, centroidCoordinates] = kmeans(X, info.k, ...
        'Distance', 'sqeuclidean', 'Replicates', info.kMeansReplicates);

    %Given the centroid values, lets find a bounding box.
    meanXCentroidCoordinate = mean(centroidCoordinates(:, 1));
    meanYCentroidCoordinate = mean(centroidCoordinates(:, 2));

    %Plot the result of the cluster analysis if the user is interested.
    if info.plotClusterAnalysisResults
        plotClusterAnalysisResults(info, histogramValues, ...
            meanXCentroidCoordinate, meanYCentroidCoordinate);
    end
end  %End of if-else clause - if numXRows <= info.k

end  %End of function findCentroidCoordinates.m