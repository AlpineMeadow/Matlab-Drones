%This script will generate .h5 files for cadet EJ Shin. He requested that I
%generate .h5 files that contain only the nX4 array of the data from the
%EBS drones.  The files will be named according to the date and time the
%data were taken and will also have a prefix that identifies the type of
%the drone being observed.  Finally the files will contain a suffix that 
%indicates the partition number.  This number is necessary due to the fact
%that Matlab cannot work with some of the giant files produced by the EBS
%cameras.  To manage this the original files were split into more managable
%chunks.  These were then numbered starting from 000 and going until the
%entire file was split up.
%The files will have the following format : 

% N_Date_Time_PN.h5 - Files containing data that does not contain drones (No
% Drone)
% Q_Date_Time_PN.h5 - Files containing data that contains quadcopter drones.
% O_Date_Time_PN.h5 - Files containing data that contains octocopter drones.
% F_Date_Time_PN.h5 - Files containing data that contains fixed wing drones.

close all;
clearvars;
dbstop if error; 

%Create a date and time for the input and output filenames.
year = 2024;
month = 11;
dayOfMonth = 18;
hour = 18; 
minute = 46;
second = 20; 

dataPartition = 0;

%We set out the class type so that we can use the information to set the
%proper file name.  Types are NoDrone, Quad, Octo, Delta.
classType = 'Quad';

%Now generate the information structure.
info = generateEBSInformationStructure(year, month, dayOfMonth, ...
    hour, minute, second, dataPartition);

%Read in the data from the .dat file.  We will also write out the data as a
%.h5 file for further use.  The time data is given in seconds, not
%microseconds!
getEBSDatDataH5(info, classType);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function getEBSDatDataH5(info, classType)

%This function will read in the raw data.  
%The data from the .dat file will be returned in an array of [n rows X 4]
%columns.  The first column is the x pixel location of the event.  The
%second column is the y pixel location of the event.  The third column is
%the polarity of the event(It is either increasing or decreasing).  The
%fourth column is the time in seconds from the start of the recording.

outputDataPath = '/SS1/Drones/Data/Output/h5/';
inputDataPath = '/SS1/Drones/Data/Input/';

inputMovieName = ['recording_', info.yearStr, '-', info.monthStr, '-', ...
     info.dayOfMonthStr, '_', info.hourStr, '-', info.minuteStr, '-', ...
     info.secondStr, '_', num2str(info.dataPartition, '%02d')];

%Use the classType value to determine the classTypeStr.
if strcmp(classType, 'Quad')
    classTypeStr = 'Q';
end

if strcmp(classType, 'Octo')
    classTypeStr = 'O';
end

if strcmp(classType, 'NoDrone')
    classTypeStr = 'N';
end

if strcmp(classType, 'Delta')
    classTypeStr = 'D';
end

%Generate the output file name.
outputFileName = [classTypeStr, '_', info.yearStr, '-', ...
    info.monthStr, '-', info.dayOfMonthStr, '_', info.hourStr, '-', ...
    info.minuteStr, '-', info.secondStr, '_', ...
    num2str(info.dataPartition, '%02d')];

inputFileName = [inputDataPath, 'dat/', inputMovieName, '.dat'];
outFileName = [outputDataPath, outputFileName, '.h5'];


% outputName = [classTypeStr, '_', info.yearStr, '-', ...
%     info.monthStr, '-', info.dayOfMonthStr, '_', info.hourStr, '-', ...
%     info.minuteStr, '-', info.secondStr, '_', ...
%     num2str(info.dataPartition, '%02d')];
% plotFileName = [outputDataPath, outputName, '.png'];




%Read in the data.
data = datto4xN(inputFileName);

% Fix the problem with (x,y) being zero-indexed
data(:, 1) = data(:, 1) + 1;
data(:, 2) = data(:, 2) + 1;

% We replace (elapsed microseconds from START OF ACQUSITION) with
% (elapsed microseconds from FIRST EVENT).  The FPGA can leave long
% (~hundreds of milliseconds) gaps before the first event is clocked
% in, and this plays merry hell with the FFTs later.
data(:, 4) = data(:, 4) - min(data(:, 4));

%Convert the time in microseconds from start of recording with time in
%seconds from start of recording.
data(:, 4) = double(data(:, 4))/1.0e6;

%Now save the data in the .h5 format.
h5create(outFileName, '/data', size(data));
h5write(outFileName, '/data', data);
    

% plot(data(:,4))
% xlabel('Number of Events')
% ylabel('Time (s)')
% title('Plot of Time in Column 4 versus Number of Events')
% print('-dpng', plotFileName)



end  %End of the function getEBSDatDataH5.m