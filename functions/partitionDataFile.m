function partitionDataFile(inFileName)

%This function will partition the data file into manageable chunks.  It is
%called by getEBSData.m, which in turn is called by cadetDrone.m.

 
%Lets find the number of lines in the file.
[status, commandOutput] = system(['wc -l ', inFileName]);

%Matlab returns more than we want so lets pick the useful information.
commandOutputCell = strsplit(commandOutput);

%Now get the number of lines as an integer.
numLines = str2num(commandOutputCell{1});

%Generate a file ID.
fileID = fopen(inFileName);

%Read in the data.
B = fread(fileID, [numLines, 4]);

%Now lets divide the data into chunks and save the individual pieces.
%Each piece will contain 1e6 lines of data.
numOutputFiles = fix(numLines/1e6);
numOutputFilesStr = num2str(numOutputFiles);
    
%Lets tell the user how many output files will be created.
disp(['The data has been divided into ', numOutputFilesStr, ...
    ' number of partitions'])
disp(['In order to analyze the entire data file the user will need'])
disp(['run cadetDrone filling in the dataPartition value starting'])
disp(['from 0 and going to ', numOutputFilesStr, '.  If '])
disp([numOutputFilesStr, ' is zero, then the user does not need'])
disp([' to change the dataPartition value because the file is small '])
disp(['enough to be completely  analyzed in one single turn through '])
disp(['the data.'])

%Loop through the data and save the chunks.
for files = 0 : numOutputFiles
    saveFileName = ['/SS1/Drones/Data/Input/h5/', ...
        originalInputFileName, '_', num2str(files, '%03d'), '.h5'];
    firstIndex = 1000000*files + 1;
    lastIndex = (files + 1)*1000000;

    if files == numOutputFiles
        lastIndex = numLines;
    end

    data = B(firstIndex : lastIndex, :);
    h5create(saveFileName, '/data', size(data));
    h5write(saveFileName, '/data', data);
end

end  %End of the function partitionDataFile.m