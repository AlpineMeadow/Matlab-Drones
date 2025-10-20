function fourxN = datto4xN(fname);
%datto4xN.m
%
%   mfile to convert an dat files made from Gen 4 Prophesee .raw files to a 4xN
%   array for futher processing
%
%   McHarg july 2021
%
%   inputs
%   fname-'file name of the dat file
%
%   outputs
%
%   fourxN-4 column by N event array that has x,y,polarity,time for each event
%
%
% close all
% clear
%
%   use the load_cd_events from prophessee
events=load_cd_events(fname);
%
%   now make doubles
%
eventsdx=events.x;
eventsdy=events.y;
eventsdt=events.ts;
eventsdp=events.p;
%
%   now make the matrix in the order usafa likes x,y,p,t
%
fourxN=[eventsdx,eventsdy,eventsdp,eventsdt];

