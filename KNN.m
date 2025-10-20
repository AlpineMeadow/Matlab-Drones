%This script will explore using Matlab's knnsearch function. I want to use
%it to find the drone in an image.
close all;
clearvars;
%clf;

c = [1, 2];
d = [1, 2; 2, 1; 2, 2; 1, 1; 10,10];
% [idx, D] = knnsearch(d, c);

% 
% load hospital;
% X = [hospital.Age hospital.Weight];
% Y = [20 162; 30 169; 40 168; 50 170; 60 171];   % New patients
% [idx2, D2] = knnsearch(X, Y)

%load fisheriris;
%x = meas(:,3:4);
newpoints = [5 1.45; 7 2; 4 2.5; 2 3.5];


X = [0.5 1.0; 1.0 1.0; 2.0 1.0; 1.0 2.0; 2.5 2.5; 3.0 2.0; 3.0 1.5; ...
    1.5 2.5; 0.5 3.0; 2.0 2.0; 0.5 0.25; 0.2 2.0;];
Y = [5.0 5.0; 6.0 4.0; 5.0 6.0; 8.0 7.0; 8.0 8.0; 8.4 6.5; 7.0 9.0; ...
    9.0 10.0; 8.5 8.5; 8.5 9.5; 10.0 10.0; 11.0 10.0];

%This is the number of points to be queried.  In the drone case this will
%be the number of points [rows, cols] found.
Q = size(Y, 1);  

%Now we define the dimensionality of the data points.  We are looking only
%at a plane of pixels so there are 2 dimensions, x & y.  
M = size(X, 2);

%Let k = number of nearest neighbors to keep.  In the drone program this
%will likely be n-1, where n is the total number of [rows,cols] found.
k = Q;
x_closest = zeros(k, M, Q);
ind_closest = zeros(Q, k);

%// Loop through each point and do logic as seen above:
for ii = 1 : Q
    %// Get the point
    newpoint = Y(ii, :);

    %// Use Euclidean
    dists = sqrt(sum(bsxfun(@minus, X, newpoint).^2, 2));
    [d,ind] = sort(dists);

    %// New - Output the IDs of the match as well as the points themselves
    ind_closest(ii, :) = ind(1 : k).';
    x_closest(:, :, ii) = X(ind_closest(ii, :), :);
end
