function data = getEBSDatData(info)

%This function will check to see if the data has previously been saved.  If
%so it will read in the save file.  If not it will read in the raw data.  
%The data from the .dat file will be returned in an array of n rowsX 4
%columns.  The first column is the x pixel location of the event.  The
%second column is the y pixel location of the event.  The third column is
%the polarity of the event(It is either increasing or decreasing).  The
%fourth column is the time in seconds from the start of the recording.

saveFileName = info.saveFileName;
inFileName = info.inFileName;

%Check to see if the data has been saved to 
if isfile(saveFileName) 
%    data = h5read(saveFileName, '/odin');
    data = h5read(saveFileName, '/data');
else
    %Read in the data.
    data = datto4xN(inFileName);

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
    h5create(saveFileName, '/data', size(data));
    h5write(saveFileName, '/data', data);
end  %End of the if-else clause - if isfile(saveFileName)

end  %End of the function getEBSDatData.m