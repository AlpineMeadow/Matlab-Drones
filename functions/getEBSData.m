function data = getEBSData(info)

%This function will be called by cadetDrones.m.  It will do two things.
%The first will be to split up the original .dat files into data chunks.
%This is because some of these .dat files are too large to load into memory
%and then work with making movies.  These data chunks will be saved as .h5
%files.  The second thing this function will do
%will be to read in .h5 files and then return them as a data array.  

%If the data chunk has already been written from part 1 of this function
%then it will skip reading in the .dat file.

if isfile(info.saveFileName)
    %The file exists, read it in.
    data = h5read(info.saveFileName, '/data');
else
    %Read in the data and turn it into chunks.
    inFileName = info.inFileName;

    %Lets partition the data file.
    partitionDataFile(inFileName);
   
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

end  %End of the function getEBSData.m