function [rows, cols] = findImageRowsAndColumns(info, histogramValues)

%This function will find the pixels that are most likely to represent the
%image we are looking for.  It is called by getObjectBoundingBox1.m
%and getObjectBoundingBox2.m

%Find the maximum value of the interior histogram.
maxValue = max(max(histogramValues));
maxValueIndex = find(histogramValues == maxValue);
notMaxValueIndex = find(histogramValues ~= maxValue);

%Remove any hot pixels
if maxValue > info.maximumPixelIntensity
    newMaxValue = max(max(histogramValues(notMaxValueIndex)));
    histogramValues(maxValueIndex) = newMaxValue;
    maxValue = newMaxValue;
end

peakPercent = info.keepHighestPercentage/100.0;
highValue = (1.0 - peakPercent)*maxValue;
[rows, cols] = find(histogramValues >= highValue);

end  %End of the function findImageRowsAndColumns.m