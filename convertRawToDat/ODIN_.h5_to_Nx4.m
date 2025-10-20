% Clean Slate
clear all
close all

%% Load in .h5 file

[h5filename,PathName,FilterIndex]=uigetfile('*.h5','Select HDF5 file','Multiselect','off');
allh5filename=fullfile(PathName,h5filename);
cd(PathName);

data=h5read(allh5filename,'/odin');
data=double(data);
data(:,4)=(data(:,4)/1e6);
data(:,4)=data(:,4)-min(data(:,4));