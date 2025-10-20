%%
close all
clear all


%% Load in .dat file

[h5filename,PathName,FilterIndex]=uigetfile('*.dat','Select DAT file','Multiselect','off');
allh5filename=fullfile(PathName,h5filename);
cd(PathName);

data=datto4xN(allh5filename);
data=double(data);
data(:,4)=(data(:,4)/1e6);
data(:,4)=data(:,4)-min(data(:,4));

%% User Variable Section

startTime=0;
endTime=10000;
FrameLength=0.1; %seconds
fps=10;


%% Data Organization
data=data(data(:,4)>=startTime & data(:,4)<=endTime,:);
endTime=max(data(:,4));

%% Movie initialization

temp2=VideoWriter(h5filename(1:end-3),'MPEG-4');
temp2.FrameRate=fps;
open(temp2);
%% Movie maker

for i=startTime:FrameLength:endTime
    loop_data=data(data(:,4)>=i & data(:,4)<=i+FrameLength,:);

        Xedges=0:1280;
        Yedges=0:720;
        histogram2(loop_data(:,1),loop_data(:,2),Xedges,Yedges,'DisplayStyle','tile','showEmptyBins','on')
        xlim([0 1280]);
        ylim([0 720 ]);
        set(gca,'YDir','reverse');
        set(gca,'XDir','reverse'); 
    colorbar
    axis equal
    colormap jet
    caxis([0 50])
    j=i+FrameLength;
    title("Time from start="+i+"s to "+j+"s");
    drawnow;
    frame=getframe(gcf);
    writeVideo(temp2,frame);
end
close(temp2);