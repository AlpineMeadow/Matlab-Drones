function [xL, xR, yD, yU] = getObjectBoundingBox(info, ...
    histogramValues, guessXL, guessXR, guessYD, guessYU, frameCount);

%This function is called by makeEBSMovies.m
%This function will find a bounding box around the object being "imaged" in
%the event based video.  It will return the x and y coordinates of the
%bounding box in the following pattern:

%   ____________________________________________________
%   |(x_left, y_up)                    (x_right, y_up)  |
%   |                                                   |
%   |                                                   |
%   |                                                   |
%   |(x_left, y_down)                  (x_right, y_down)|
%   |___________________________________________________|
% 
%xPixelVector = 1 : info.numXPixels;
%yPixelVector = 1 : info.numYPixels;
% h1 = imagesc(xPixelVector, yPixelVector, ...
%     fliplr(histogramValues)', info.positiveCLims);
% colorbar;
% hold on

%This algorithm is likely to be less than perfect.  It will require
%reworking.  This should be considered a starting point.

%First find the maximum value in the histogram values.  In principle the
%maximum value should be the object in question but it is possible that the
%maximum values may be at edges of the field of view.  We may have to
%account for that.

%Generate a range of x and y values that do not include the edges.
xPercent = 1.0;
yPercent = 1.0;
xEdge = fix(info.numXPixels*(xPercent/100.0)); 
yEdge = fix(info.numYPixels*(yPercent/100.0));

%Generate a new array of the interior values of the histogram array.
leftXBoundary = info.numXPixels - xEdge + 1;
upperYBoundary = info.numYPixels - yEdge + 1;
interiorHistogramValues = histogramValues(xEdge : leftXBoundary, ...
	yEdge : upperYBoundary);

%find the maximum value of the interior histogram.
maxValue = max(max(interiorHistogramValues));
maxValueIndex = find(interiorHistogramValues == maxValue);
notMaxValueIndex = find(interiorHistogramValues ~= maxValue);

%Remove any hot pixels
if maxValue > 50.0
    newMaxValue = max(max(interiorHistogramValues(notMaxValueIndex)));
    interiorHistogramValues(maxValueIndex) = newMaxValue;
    maxValue = newMaxValue;
end



peakPercent = info.keepHighestPercentage/100.0;
highValue = (1.0 - peakPercent)*maxValue;
[row, col] = find(interiorHistogramValues >= highValue);

if frameCount == 112
    joe  = 1;
end

%Now find the distances between all of the points.
includeFactor = 1.0;
[goodRows, goodCols] = getGoodPixels(row, col, includeFactor);

%check to see how good the algorithm works.
disp(['Difference in Data Points : ',...
    num2str(length(row) - length(goodRows)), ' For Frame : ', ...
    num2str(frameCount)])
disp(' ')

%There seems to be a problem with pixel y=544, especially on the negative
%polarity instrument response.  I am simply going to get rid of it.
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

%Check to see that the bounding coordinates are not beyond the image size. 
if xLeft < 0
    xLeft = guessXL;
end

if xRight > info.numXPixels
    xRight = guessXR;
end

newWidth = xRight - xLeft;
oldWidth = guessXR - guessXL;
newHeight = yUp - yDown;
oldHeight = guessYU - guessYD;

% if newWidth > oldWidth
%     xRight = guessXR;
%     yLeft = guessXL;
% end
% 
% if newHeight > oldHeight
%     yUp = guessYU;
%     yDown = guessYD;
% end


%Check to see that the bounding coordinates are not beyond the image size.
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

end  %End of the function getObjectBoundingBox.m   