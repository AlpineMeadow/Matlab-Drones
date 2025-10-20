%
%   esdrive.m
%
%   driver file for esto4Xn.m
%
%   McHarg
%
%   dec 2021
%
close all
clear all
%% Load in .dat file

[h5filename,PathName,FilterIndex]=uigetfile('*.dat','Select DAT file','Multiselect','off');
allh5filename=fullfile(PathName,h5filename);
cd(PathName);

data=datto4xN(allh5filename);

%% Convert to .h5
%
% go get the data using esto4xN
%
%[fourxN]=esto4xN();

h5fnam=[h5filename(1:end-3),'.h5'];
sz_fourxN=size(data);
h5create(h5fnam,'/odin',sz_fourxN);
h5write(h5fnam,'/odin',data);

