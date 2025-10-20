function [goodRows, goodCols] = getPixelDistances(rows, cols)

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

%Now we define the dimensionality of the data points.  We are looking only
%at a plane of pixels so there are 2 dimensions, x & y.  
M = size(pointCloud, 2);

%Let k = number of nearest neighbors to keep.  In the drone program this
%will likely be n-1, where n is the total number of [rows,cols] found.
k = Q;
% x_closest = zeros(k, M, Q);
% ind_closest = zeros(Q, k);

%Set up a vector that will append all of the good indices that are found.
goodIndices = [];

% Loop through each point and do logic as seen above:
for ii = 1 : Q

    %Pick a point
    newpoint = points(ii, :);

    % Use the Euclidean distance metric.
    distances = sqrt(sum(bsxfun(@minus, pointCloud, newpoint).^2, 2));

    %Sort the distances
%    [d,ind] = sort(dists);
    
    goodValueIndex = find(distances < mean(distances));
    goodIndices = [goodIndices; goodValueIndex];

    %// New - Output the IDs of the match as well as the points themselves
    % ind_closest(ii, :) = ind(1 : k).';
    % x_closest(:, :, ii) = pointCloud(ind_closest(ii, :), :);
end

%Because we went through all of the data for each data point the
%goodIndices will have many repeats, so lets get rid of them.
uniqueGoodIndices = unique(goodIndices);

%Now that we have the indices that we want lets put them back into the rows
%and cols that we input into the function.
goodRows = rows(uniqueGoodIndices);
goodCols = cols(uniqueGoodIndices);


distances = 1;

end  %End of the function getPixelDistances.m