%This script will read in the big data files and chunk them up to more
%manageble bites and then save them.

close all;
clearvars;

dbstop if error; 

%Input the year that the data were taken.
year = 2024;

%Input the month (in month number) that the data were taken.
month = 7;

%Input the day of month that the data were taken.
dayOfMonth = 4;

%Input the hour that the data were taken.
hour = 21;

%Input the minute that the data were taken.
minute = 56;

%Input the second that the data were taken.
second = 36;

yearStr = num2str(year);
monthStr = num2str(month, '%02d');
dayOfMonthStr = num2str(dayOfMonth, '%02d');
hourStr = num2str(hour, '%02d');
minuteStr = num2str(minute, '%02d');
secondStr = num2str(second, '%02d');

%Set the root path.
rootPath = '/SS1/Drones/Data/Input/dat/';

%Set the root input movie file name.
originalInputFileName = ['recording_', yearStr, '-', monthStr, '-', ...
     dayOfMonthStr, '_', hourStr, '-', minuteStr, '-', secondStr];

%Set the input movie file name as well as the save file name.
inFileName = [rootPath, originalInputFileName, '.dat'];

%Get the data.
B = datto4xN(inFileName);

%Lets get the size of the data array.
[numLines, numChannels] = size(B);

% Fix the problem with (x,y) being zero-indexed
B(:, 1) = B(:, 1) + 1;
B(:, 2) = B(:, 2) + 1;

% We replace (elapsed microseconds from START OF ACQUSITION) with
% (elapsed microseconds from FIRST EVENT).  The FPGA can leave long
% (~hundreds of milliseconds) gaps before the first event is clocked
% in, and this plays merry hell with the FFTs later.
B(:, 4) = B(:, 4) - min(B(:, 4));

%Convert the time in microseconds from start of recording to time in
%seconds from start of recording.
B(:, 4) = double(B(:, 4))/1.0e6;

%Now lets divide the data into chunks and save the individual pieces.
numLinesPerFile = 1e8;
numOutputFiles = fix(numLines/numLinesPerFile);

%Loop through the data and save the chunks.
for files = 0 : numOutputFiles
    saveFileName = ['/SS1/Drones/Data/Input/h5/', ...
        originalInputFileName, '_', num2str(files, '%03d'), '.h5'];
    firstIndex = numLinesPerFile*files + 1;
    lastIndex = (files + 1)*numLinesPerFile;
    if files == numOutputFiles
        lastIndex = numLines;
    end
    data = B(firstIndex : lastIndex, :);
    h5create(saveFileName, '/data', size(data));
    h5write(saveFileName, '/data', data);
end