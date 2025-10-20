function [xL, xR, yU, yD] = ...
    getObjectBoundingBox2(info, histogramValues, guessXL, guessXR, ...
    guessYD, guessYU);

%This function is called by makeEBSMovies1.m as well as makeMovie.m
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
oldXCentroidCoordinate = 0.5*(guessXL + guessXR);
oldYCentroidCoordinate = 0.5*(guessYU + guessYD);

%Check to see that our calculation is valid.  If any of the guess values
%are nonexistent then the oldXCentroid or oldYCentroid values will be
%nonexistent and that will screw things up in later calculations.
if length(oldXCentroidCoordinate) == 0 | length(oldYCentroidCoordinate) == 0
    oldXCentroidCoordinate = info.numXPixels/2.0;
    oldYCentroidCoordinate = info.numYPixels/2.0;
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
%Find the centroid coordinates of the object in the image.
[xCentroidCoordinate, yCentroidCoordinate] = ...
    findCentroidCoordinates(info, interiorHistogramValues);

%Sometimes the x and y centroid values are way off.  Not sure why.  Lets
%check them against the previous values.
percentDiffYCentroidValue = 100.0*abs(yCentroidCoordinate - ...
    oldYCentroidCoordinate)/oldYCentroidCoordinate;
percentDiffXCentroidValue = 100.0*abs(xCentroidCoordinate - ...
    oldXCentroidCoordinate)/oldXCentroidCoordinate;

if percentDiffYCentroidValue > 50
    yCentroidCoordinate = oldYCentroidCoordinate;
end

if percentDiffXCentroidValue > 50
    xCentroidCoordinate = oldXCentroidCoordinate;
end

%Now determine the boundaries for the x and y boxes.
xL = fix(xCentroidCoordinate - info.boundingBoxXSize);
xR = fix(xCentroidCoordinate + info.boundingBoxXSize);
yU = fix(yCentroidCoordinate + info.boundingBoxYSize);
yD = fix(yCentroidCoordinate - info.boundingBoxYSize);

%Check to see that the bounding coordinates are not beyond the
%image size.
if xL < 0
    xL = guessXL;
end

if xR > info.numXPixels
    xR = guessXR;
end

%Check to see that the bounding coordinates are not beyond the
%image size.
if yU > info.numYPixels
    yU = guessYU;
end

if yD < 0
    yD = guessYD;
end

end  %End of the function getObjectBoundingBox2.m