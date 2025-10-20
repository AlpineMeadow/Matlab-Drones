function [goodRows, goodCols] = getGoodPixels(rows, cols, includeFactor)

%This function will determine the distances between all of the points found
%in the getObjectBoundingBox function.  It is called by
%getObjectBoundingBox.m

%First combine the rows and cols values into points on the plane.
pointCloud = [rows cols];

%Now recopy the pointCloud array so that we can check distance between all
%of the points.
points = pointCloud;

%This is the number of points to be queried.  In the drone case this will
%be the number of points [rows, cols] found.
Q = size(points, 1);  

%Set up a vector that will append all of the good indices that are found.
goodIndices = [];

% Loop through each point and do logic as seen above:
for ii = 1 : Q

    %Pick a point
    newpoint = points(ii, :);

    % Use the Euclidean distance metric.
    distances = sqrt(sum(bsxfun(@minus, pointCloud, newpoint).^2, 2));

    goodValueIndex = find(distances < includeFactor*mean(distances));
    goodIndices = [goodIndices; goodValueIndex];
end

%Because we went through all of the data for each data point the
%goodIndices will have many repeats, so lets get rid of them.
uniqueGoodIndices = unique(goodIndices);
[C,iGoodIndices,ic] = unique(goodIndices);

a_counts = accumarray(ic, 1);
value_counts = [C, a_counts];

minIndex = find(a_counts == min(a_counts));

%Now use minIndex to find the distances again.
if length(minIndex) ~= 0
    distances = sqrt( (pointCloud(:, 1) - rows(minIndex(1))).^2 + ...
        (pointCloud(:, 2) - cols(minIndex(1))).^2 );
    
    goodValueIndex = find(distances < includeFactor*mean(distances));

    %Now that we have the indices that we want lets put them back into the rows
    %and cols that we input into the function.
    goodRows = rows(goodValueIndex);
    goodCols = cols(goodValueIndex);
else
    goodRows = rows;
    goodCols = cols;
end

end  %End of the function getGoodPixels.m