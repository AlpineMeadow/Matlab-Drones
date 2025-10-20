%This script will make multiple panels in a Matlab gui.
close all;
clearvars;

dbstop if error; 


%In order to get the details of the set up correct, I will pretend to have
%generated a data acquisition object.
bangDAQ = 1;

%Set up a handle structure.
handles = struct;

%Set up the parent gui location.
left  = 60;
bottom = 60;
width = 1280;
height = 605;

%Set up a parent gui for the program.
fig = uifigure;

%Give it a name.
fig.Name = 'BangMeter Test';

%Give it a position.
fig.Position = [left bottom width height];

%Here we set up the various panels.  These need the original parent gui
%handle.
handles.pulsePairs = getPulsePairs(fig, bangDAQ);
handles.sineWave = getSineWave(fig, bangDAQ);
handles.squareWave = getSquareWave(fig, bangDAQ);
handles.sawtoothWave = getSawtoothWave(fig, bangDAQ);
handles.utilities = getUtilities(fig, bangDAQ);

%Store the handle structure in the application data of the figure object.
guidata(fig, handles);

