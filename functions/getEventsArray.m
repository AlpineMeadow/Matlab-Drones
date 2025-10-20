function [Events] = getEventsArray(info);
%esto4xN.m
%
%   function to convert an es(event stream) data array from Gen 4 Prophesee camera to a Nx4
%   array for futher processing
%
%   McHarg dec 2021
%   Williams September 2022
%
%   inputs
%   info : A structure containing the input file name.
%
%   outputs
%
%   Events : An [N event by 4 column] array that has x, y, polarity, time for each event
%
%
% close all
% clear
%
%   use the mex file provided by Alex Marcireau
%
fname = info.inFileName;
[~, events] = event_stream_decode(fname);

%Make the matrix in the order usafa likes x,y,p,t

Events = [double(events.x),double(events.y),double(events.on),double(events.t)];

end  %End of the getEventsArray.m function