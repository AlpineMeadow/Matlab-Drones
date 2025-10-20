%Play around with k-means program.

close all;
clearvars;

%rng default; % For reproducibility
X = [randn(100,2)*0.45+ones(100,2);
    randn(100,2)*0.15-ones(100,2);
    randn(100,2)*0.9-ones(100,2)];

figure;
plot(X(:,1),X(:,2),'.');
title 'Randomly Generated Data';

k = 2;
opts = statset('Display','final');
[idx,C] = kmeans(X, k, 'Distance', 'sqeuclidean',...
    'Replicates', 15, 'Options', opts);

figure;
hold on

if k == 2
    colorName = [{'red'}, {'blue'}];
    legendStr = {'Cluster 1','Cluster 2', 'Centroids'};
end
if k == 3
    colorName = [{'red'}, {'blue'}, {'green'}];
    legendStr = {'Cluster 1','Cluster 2', 'Cluster 3', 'Centroids'};
end

hold on
for ii = 1 : k
    plot(X(idx == ii, 1), X(idx == ii, 2), 'Color', ...
        getColorTriplet(colorName(ii)), ...
        'MarkerSize', 12, 'Marker', '.', 'LineStyle', 'None')
end
%legend(legendStr, 'Location', 'NW')
plot(C(:,1),C(:,2),'kx', 'MarkerSize',15,'LineWidth',3)
plot([0, 0], [min(min(X)), max(max(X))], 'k')
plot([min(min(X)), max(max(X))], [0, 0], 'k')
title 'Cluster Assignments and Centroids'

% 
% plot(X(idx==2,1),X(idx==2,2),'b.','MarkerSize',12)
% plot(X(idx==3,1),X(idx==3,2),'g.','MarkerSize', 12)


% plot(C(:,1), C(:,2), 'kx', 'MarkerSize', 15, 'LineWidth', 3)
% legend('Cluster 1','Cluster 2', 'Cluster 3', 'Centroids',...
%        'Location','NW')
% 
% hold off
% 
