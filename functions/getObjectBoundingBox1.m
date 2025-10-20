function [xL, xR, yD, yU, xCL, xCR, yCU, yCD] = ...
    getObjectBoundingBox1(info, histogramValues, guessXL, guessXR, ...
    guessYD, guessYU, frameCount);

%This function is called by makeEBSMovies1.m
%This function will find a bounding box around the object being "imaged" in
%the event based video.  It will return the x and y coordinates of the
%bounding box in the following pattern:

%   ____________________________________________________
%   |(xL, yU)                                   (xR, yU)|
%   |                                                   |
%   |                                                   |
%   |                                                   |
%   |(xL, yD)                                   (xR, yD)|
%   |___________________________________________________|
% 

%Let us calculate the old centroid position.  We can use this to check to
%see if our new centroid position calculation is reasonable.  What can
%happen is that the algorithm can pick up a secondary bright change and
%then incorrectly focus on that.  By assuming that the centroid does not
%move too rapidly we can check to see if the algorithm gives a result that
%changes too much.  The problem with this is we do not know how much is too
%much. Small steps, small steps.
oldXCentroid = 0.5*(guessXL + guessXR);
oldYCentroid = 0.5*(guessYU + guessYD);

%Check to see that our calculation is valid.  If any of the guess values
%are nonexistent then the oldXCentroid or oldYCentroid values will be
%nonexistent and that will screw things up in later calculations.
if length(oldXCentroid) == 0 | length(oldYCentroid) == 0
    oldXCentroid = 0;
    oldYCentroid = 0;
end

%Generate a range of x and y values that do not include the edges.
if info.removeImageEdges
    interiorHistogramValues = removeImageEdges(info, histogramValues);
else
    interiorHistogramValues = histogramValues;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Use image "intensity" to narrow down the number of pixels to those that
%contain the object we are trying to identify.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now find the rows and columns of the object we are looking for.
[rows, cols] = findImageRowsAndColumns(info, interiorHistogramValues);


%Now lets find the data centroid.
xCentroid = mean(rows);
yCentroid = mean(cols);

%Sometimes the x and y centroid values are way off.  Not sure why.  Lets
%check them against the previous values.
percentDiffYCentroidValue = 100.0*abs(yCentroid - ...
    oldYCentroid)/oldYCentroid;
percentDiffXCentroidValue = 100.0*abs(xCentroid - ...
    oldXCentroid)/oldXCentroid;

if percentDiffYCentroidValue > 50
    yCentroid = oldYCentroid;
end

if percentDiffXCentroidValue > 50
    xCentroid = oldXCentroid;
end


%Now check to see if the new centroid changes drastically.  Since the time
%interval is constant we really just need to check the distance.
centroidDistance = sqrt( abs(xCentroid - oldXCentroid)^2 + ...
    abs(yCentroid - oldYCentroid)^2);

% disp(['Centroid Distance : ', num2str(centroidDistance)])
% disp(['Frame Count : ', num2str(frameCount)])
% disp(' ')

if frameCount > 356
    joe = 1;
end


%if centroidDistance > info.centroidDistance
    %The situation seems to be that we have found an anomaly so we will use
    %the data from the previous frame.
    % xL = guessXL;
    % xR = guessXR;
    % yU = guessYU;
    % yD = guessYD;
    % 
    % xCL = oldXCentroid - info.outerBoundary;
    % xCR = oldXCentroid + info.outerBoundary;
    % yCU = oldYCentroid + info.outerBoundary;
    % yCD = oldYCentroid - info.outerBoundary;

%else
    %There does not seem to be an anomoly  so we will recalulate the
    %position of the drone.

    distance = sqrt(abs(rows - xCentroid).^2 + abs(cols - yCentroid).^2);
    goodDistanceIndex = find(distance < info.meanDistanceFactor*mean(distance));

    if distance == 0 | length(goodDistanceIndex) == 0
        goodRows = rows;
        goodCols = cols;
    else
        goodRows = rows(goodDistanceIndex);
        goodCols = cols(goodDistanceIndex);
    end

    %Now lets recalculate the centroids.
    newXCentroid = mean(goodRows);
    newYCentroid = mean(goodCols);

    %Now find the distances between all of the points.
    %includeFactor = 1.0;
    %[goodRows, goodCols] = getGoodPixels(row, col, includeFactor);

    %There seems to be a problem with pixel y=544, especially on the
    %negative polarity instrument response.  I am simply going to get rid of it.
    k = find(goodCols == 544);
    if length(k) ~= 0
        goodCols(k) = [];
        goodRows(k) = [];
    end

    %Now determine the boundaries for the x and y boxes.
    xLeft = min(goodRows) - info.boundingBoxXSize;
    xRight = max(goodRows) + info.boundingBoxXSize;

    yUp = max(goodCols) + info.boundingBoxYSize;
    yDown = min(goodCols) - info.boundingBoxYSize;

    %Check to see that the bounding coordinates are not beyond the
    %image size.
    if xLeft < 0
        xLeft = guessXL;
    end

    if xRight > info.numXPixels
        xRight = guessXR;
    end

    %Check to see that the bounding coordinates are not beyond the
    %image size.
    if yUp > info.numYPixels
        yUp = guessYU;
    end

    if yDown < 0
        yDown = guessYD;
    end

    %Now return the results.
    xL = xLeft;
    xR = xRight;
    yU = yUp;
    yD = yDown;
    
    xCL = newXCentroid - info.outerBoundingBoxSize;
    xCR = newXCentroid + info.outerBoundingBoxSize;
    yCU = newYCentroid + info.outerBoundingBoxSize;
    yCD = newYCentroid - info.outerBoundingBoxSize;

    %Now check for bad boundaries.
    if xCL < 0
        xCL = 0;
    end

    if xCR > info.numXPixels
        xCR = info.numXPixels;
    end

    if yCU > info.numYPixels
        yCU = info.numYPixels;
    end

    if yCD < 0
        yCD = 0;
    end
    

end  %End of the function getObjectBoundingBox1.m