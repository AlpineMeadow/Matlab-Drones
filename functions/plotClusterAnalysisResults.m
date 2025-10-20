function plotClusterAnalysisResults(info, histogramValues, ...
    meanXCentroidCoordinate, meanYCentroidCoordinate)

%This function will plot the results of the cluster analysis.  It is called
%by findImageRowsAndColumns2.m

%Generate the xL, xR, yU and yD values.
xL = fix(meanXCentroidCoordinate - info.boundingBoxXSize);
xR = fix(meanXCentroidCoordinate + info.boundingBoxXSize);
yU = fix(meanYCentroidCoordinate - info.boundingBoxYSize);
yD = fix(meanYCentroidCoordinate + info.boundingBoxYSize);

%Here we try the matlab kmeans function.
xPixelVector = 1 : info.numXPixels;
yPixelVector = 1 : info.numYPixels;

%Set the figure position information.
left = 750;
bottom = 25;
width = 1220;
height = 560;

fig2 = figure();
fig2.Position = [left bottom width height];
fig2.ToolBar = 'none';
set(gcf, 'renderer', 'zbuffer');

imagesc(xPixelVector, yPixelVector, histogramValues', info.positiveCLims);
colorbar
hold on
%Plot a bounding box.
plot([xL, xL], [yD, yU], 'r', 'LineWidth', 3)
plot([xR, xR], [yD, yU], 'r', 'LineWidth', 3)
plot([xL, xR], [yD, yD], 'r', 'LineWidth', 3)
plot([xL, xR], [yU, yU], 'r', 'LineWidth', 3)
xlim([0 info.numXPixels])
ylim([0, info.numYPixels])

end %End of the function plotClusterAnalysisResults.m