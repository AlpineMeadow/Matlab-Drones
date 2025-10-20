%This will act as a driver program for the droneFunction function.

close all;
clearvars;
%clf;

dbstop if error; 

numPartitions = 8;

for dataPartition = 0 : numPartitions - 1
    droneFunction(dataPartition);
end