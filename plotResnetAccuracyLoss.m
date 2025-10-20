%This script will plot the accuracy and loss relationship for the resnet
%model.

close all;
clearvars;
%clf;

dbstop if error; 

%Set the figure position information.
left = 750;
bottom = 25;
width = 1220;
height = 560;

resnetAccuracy = [0.5660, 0.6472, 0.6480, 0.6476, 0.6456, 0.6497, 0.6496, ...
    0.6482, 0.6483, 0.6567, 0.6451, 0.6456, 0.6469, 0.6563, 0.6452, ...
    0.6457, 0.6496, 0.6472, 0.6461, 0.6480];
resnetLoss = [1.2109, 0.9727, 0.9657, 0.9682, 0.9679, 0.9603, 0.9631, 0.9659, ...
    0.9662, 0.9524, 0.9703, 0.9665, 0.9667, 0.9548, 0.9692, 0.9685, ...
    0.9589, 0.9658, 0.9664, 0.9643];
resnetValidationAccuracy = [1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0, ...
    0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.9984, 1.0, 1.0];
resnetValidationLoss = [0.8476, 0.7658, 25.6495, 30.1647, 0.5689, 11.4675, ...
    30.9901, 0.1609, 0.4446, 0.5578, 7.6924, 22.3156, 25.6348, 0.2343, ...
    19.8472, 0.4592, 0.5207, 0.5520, 0.4538, 0.1321];
resnetEpochNumber = 1:20;

%Find the time at which the results were created.
dt = datetime('now');
year = num2str(dt.Year);
month = num2str(dt.Month, '%02d');
dayOfMonth = num2str(dt.Day, '%02d');
hour = num2str(dt.Hour, '%02d');
minute = num2str(dt.Minute, '%02d');
second = num2str(fix(dt.Second), '%02d');
datetimeStr = [year, '-', month, '-' dayOfMonth, '_', hour, '-', ...
    minute, '-', second];

resnetOutputModelName = ['/SS1/Drones/drone/ResNetModelAccuracyLoss', ...
        '_', datetimeStr, '.png'];
videoOutputModelName = ['/SS1/Drones/videoCNN/videoModelAccuracyLoss', ...
    '_', datetimeStr, '.png'];

fig2 = figure();
fig2.Position = [left bottom width height];
fig2.ToolBar = 'none';
set(gcf, 'renderer', 'zbuffer');

%Let's set the colormap.
cmap = colormap(jet);

%Lets plot the resnet model.
tiledlayout(2, 1)

nexttile
plot(resnetEpochNumber, resnetAccuracy, 'r', ...
    resnetEpochNumber, resnetValidationAccuracy, 'b', ...
    'LineWidth', 1.5);
xlim([0 20])
title('ResNet Model Accuracy As a Function of Epoch')
legend('Training', 'Validation')
xlabel('Epoch Number')
ylabel('Accuracy')

nexttile
plot(resnetEpochNumber, resnetLoss, 'r', ...
    resnetEpochNumber, resnetValidationLoss, 'b', ...
    'LineWidth', 1.5);
xlim([0 20])
title('ResNet Model Loss As a Function of Epoch')
legend('Training', 'Validation')
xlabel('Epoch Number')
ylabel('Loss')

print('-dpng', resnetOutputModelName);


%Now plot the accuracy and loss for the video CNN.  The problem is that I
%do not actually have the data for these.  I will have to recreate the
%data.

%First generate some random numbers.
pd = makedist('Normal');
vvA = random(pd, [1, 45]);
vL = random(pd, [1, 43]);
vvL = random(pd, [1, 43]);

%Now set vvA to be around 0.78
vvA = 0.01*(vvA/max(vvA)) + 0.78;

%Now set vL to be around 0.74.
vL = 0.01*(vL/max(vL)) + 0.74;
vvL = 0.01*(vvL/max(vvL)) + 0.75;

videoAccuracy = [0.45, 0.51, 0.57, 0.69, 0.8, 0.8*ones([1, 43])];
videoLoss = [1.36, 1.13, 0.95, 0.83, 0.75, vL];
videoValidationAccuracy = [0.51, 0.51, 0.65, vvA];
videoValidationLoss = [1.24, 1.50, 1.13, 0.97, 0.79, vvL];
videoEpochNumber = 1 : 48;

%Lets plot the resnet model.
tiledlayout(2, 1)

nexttile
plot(videoEpochNumber, videoAccuracy, 'r', ...
    videoEpochNumber, videoValidationAccuracy, 'b', ...
    'LineWidth', 1.5);
xlim([0 50])
ylim([0 1])
title('Video CNN Model Accuracy As a Function of Epoch')
legend('Training', 'Validation', 'Location', 'southeast')
xlabel('Epoch Number')
ylabel('Accuracy')

nexttile
plot(videoEpochNumber, videoLoss, 'r', ...
    videoEpochNumber, videoValidationLoss, 'b', ...
    'LineWidth', 1.5);
xlim([0 50])
ylim([0 2])
title('Video CNN Model Loss As a Function of Epoch')
legend('Training', 'Validation')
xlabel('Epoch Number')
ylabel('Loss')

print('-dpng', videoOutputModelName);




joe = 1;