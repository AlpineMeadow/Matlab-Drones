function droneFunction(dataPartition)

%Create a date and time for the input and output filenames.
year = 2024;
month = 7;
dayOfMonth = 4;
hour = 21; 
minute = 56;
second = 36;

%Now generate the information structure.
info = generateEBSInformationStructure(year, month, dayOfMonth, ...
    hour, minute, second, dataPartition);

%Read in the data from the .dat file.  We will also write out the data as a
%.h5 file for further use.  The time data is given in seconds, not
%microseconds!
data = getEBSDatData(info);

%First find the length of time for which we have data.  The 4th column of
%the data array contains the time in microseconds from the start of the
%collection session.  We can find the total time of the session by
%subtracting the beginning from the end.
totalTimeSeconds = data(end, 4) - data(1, 4);

%Lets cut off any data that expands past an integer second value.
totalTimeSeconds = fix(totalTimeSeconds);
disp(['Total Number of Seconds : ', num2str(totalTimeSeconds)]);

%Loop through the data making divisions into 1 second increments.
for secondIncrement = 0 : totalTimeSeconds
    %Lets close the figures.
    close all;

    %Let put the start time into the info structure.
    info.movieStartTime = secondIncrement;
    info.movieEndTime = secondIncrement + 1;

    %Make movies of the data.
    makeEBSMoviesCNN(info, data)

end  %End of for loop - for ii = 0 : totalTimeSeconds

end