function interiorHistogramValues = removeImageEdges(info, histogramValues)

%This function will remove the edges of the histograms, which is the same
%as removing the edges of the image.  
%It is called by getObjectBoundingBox1.m

%Set up the x and y edges.
xEdge = fix(info.numXPixels*(info.xPercentImageRemoval/100.0)); 
yEdge = fix(info.numYPixels*(info.yPercentImageRemoval/100.0));

%Generate a new array of the interior values of the histogram array.
leftXBoundary = info.numXPixels - xEdge + 1;
upperYBoundary = info.numYPixels - yEdge + 1;
interiorHistogramValues = histogramValues(xEdge : leftXBoundary, ...
	yEdge : upperYBoundary);

end  %End of the function removeImageEdges.m