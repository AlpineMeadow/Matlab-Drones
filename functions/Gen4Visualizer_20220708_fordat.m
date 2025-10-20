clear all;
close all;
fclose('all');
nf = java.text.DecimalFormat;
% import mlreportgen.report.*
% import mlreportgen.dom.*

% thispath = fileparts(mfilename('fullpath'));
% % Edit the path/wildcard for the instrument-specific parameter files.  This
% % will likely be in **your local** SVN copy.
% INC_FILTER = [thispath,'\INC_PARAMS_*'];

VERSION = '8 July-2022 McHarg';


disp(VERSION);
% disp('14-Jan-2022: Original');
% disp('07-Apr-2022: NEW: Previous movie renamed rather than deleted.');
% disp('07-Apr-2022: NEW: Anderson bare-bones movie switch added.');
% disp('08-Apr-2022: BUGFIX: Nadir movie title and aspect fixes.');
% disp('06-May-2022: NEW: Now creates a new Reports directory each run to avoid overwriting images.');
% disp('06-May-2022: NEW: Added time to Frame info during run, removed post-filtering info.');




%% USER VARIABLE REGION
stocktimebins=0.0001; % array containing time bins in seconds.
% EXAMPLE stocktimebins=[0.01,0.001] generates time series and Fourier
% plots with time samples of 10 milliseconds and 1 millisecond.

movieframes=0.01; % seconds for each movie frame.
% EXAMPLE movieframes=[0.01,0.05] produces two movies, one with frame
% length 10 milliseconds, one with frame length 50 milliseconds.

movie_start_time=0.1; % seconds from the first event.
% EXAMPLE movie_start_time=0.07 starts the movie 70 milliseconds in.

movie_length=1; % seconds in length
% EXAMPLE movie_length=0.1 uses 100 milliseconds of acqusitions (starting
% from movie_start_time

make_movie_bool=true; % skip the movie or not.

%% Fettling the analysis

% load the custom colormap for EBS work
load('EBSjw')

% removes negative and time series from movie
% LEAVE THIS FALSE UNLESS YOU REALLY WANT A BARE MOVIE
anderson_movie=false;

%% DO NOT TOUCH

yawlineonoff=false; % turns them on or off
yawlinespacing=10; % pixels
% EXAMPLE yawlinespacing=10 has yaw lines spaced every 10 pixels
yawlineoffset=26; % pixels
% EXAMPLE yawlineoffset=0 has the grid lines horizontal.
% EXAMPLE yawlineoffset=10 has the grid lines offset 10 pixels DOWN from
% left to right.

manualfilter=true; % turns on post-facto filtering
manualfilter_neighbors=0; % requires at least this many neighbors recording
% events within the same frame, otherwise that pixel will record no events
% in the that time frame.



clims=[0 4]; % TODO: agree on what the limits should be for sparse events.

% %% Loading INCfile definitions
% 
% [ParameterFile,ParameterPath]=uigetfile(INC_FILTER,'Select the instrument-specific parameters INC file.');
% % Running the file populates the variables.
% run(fullfile(ParameterPath,ParameterFile));
% 
% % GEOFF do not touch this bit.
% dataformat=1; % select 1 for new FPGA 5-byte event definition
% % use this for EDU data from May 1st 2021 onwards
% % do not use this for flight data until/if we update flight in Sept 2021
% if (dataformat==1)
%     strev=['Using 5-byte event definition (March 2021 onwards)'];
%     %disp(strev);
%     TYPE1_PKT_EVENT_DATA_DSC = 'Event Data bundle';
%     TYPE1_PKT_EVENT_DATA_POS = 12;
%     TYPE1_PKT_EVENT_DATA_LEN = 249;
%     TYPE1_PKT_EVENT_DATA_BPD = 5;
%     ROLLOVERVALINUSEC = 1000000;
% else
%     %strev=['Using 4-byte event definition (pre-March 2021)'];
%     disp(strev);
% 
% end

%% Read in the H5 file.
[h5filename,PathName,FilterIndex] = uigetfile('*.dat','Select DAT file','Multiselect','off');
allh5filename=fullfile(PathName,h5filename);
% Go there, since it's likely you'll want to go there again.
cd(PathName);
[Events]=datto4xN(allh5filename);
%events = h5read(allh5filename, '/FalconNeuro');
% Fix the problem with (x,y) being zero-indexed
Events(:,1) = Events(:,1) + 1;
Events(:,2) = Events(:,2) + 1;
[a,b]=size(Events);
if b == 1 % ie we have a proper 4D array
    error('Not a 4D array.');
end
x_max=1280;
y_max=720;
tsnow = datestr(now,'yyyymmddHHMM');
reportdir=['Reports_',tsnow,'\'];
if exist(fullfile(PathName,reportdir))==7
% 
else
mkdir(reportdir);
end
cd(reportdir);

list_repplot={};
num_repplot=1;
%% USER AREA
% GEOFF everything before this is pulling a 4xN array out of a previously
% written .h5 HDF file and putting it into an array called 'events'. For
% the standalone camera writing to aedat files, you will feed in the 4xN
% array here instead of reading from a file.

% %% Open the report and start.
[q1,q2,q3]=fileparts(h5filename);
q2=replace(q2,'~','_'); % tildes in the filenames don't play nice with writerObj later so they will be replaced by underscores.
% 
% rname=[q2,' Summary.pdf'];
% tempreportname='tempreport.pdf';
% 
% rpt = Report(tempreportname);
% %rpt.Layout.Landscape=true;
% rpt.Layout.Landscape=false;
% pm=PageMargins();
% pm.Left="0.75in";
% pm.Right="0.75in";
% pm.Top="0.5in";
% pm.Bottom="0.5in";
% %pm.Header="0.2";
% pm.Footer="0.2";
% rpt.Layout.PageMargins=pm;
% 
% tp = TitlePage();
% tp.Title = 'Falcon Neuro Acquisition Summary';
% tp.Author = ['Filename = ',h5filename];
% %tp.Subtitle=['Acquisition started at Neuro time ',h5readatt(allh5filename,'/FalconNeuro','Time of Start of Acquisition')];
% %tp.Image = which('b747.jpg');
% tp.Publisher = VERSION;
% tp.PubDate = datestr(now);
% append(rpt,tp);
% 
% append(rpt,['Source directory ',PathName]);
% append(rpt,['Source file ',h5filename]);
% 
% xxx=h5readatt(allh5filename,'/FalconNeuro','camera');
% if strfind(xxx,"RAM")
%     camname="RAM";
% else
%     camname="NADIR";
% end
%%
% We don't want to contaminate the raw data in 'events' so we copy the
% array.
%Events = events;
str=input('Enter time of start of acq IN UTC! > ','s');
disp(datestr(datenum(str)));

mname=input('Enter title for images > ','s');
t0=mname;

%AbsTime = double(Events(:,4))/(1E6 * 86400) + datenum(h5readatt(allh5filename,'/FalconNeuro','Time of Start of Acquisition'));
AbsTime = double(Events(:,4))/(1E6 * 86400) + datenum(str);
TimeStart=datestr(datenum(str));
% append(rpt,['Acqusition started at ',TimeStart]);
% LeapSeconds=18; % GPS to UTC subtracts leap seconds
% AbsTime = AbsTime - LeapSeconds/86400;
FirstEventTime = AbsTime(1);
DOY=floor(date2doy(FirstEventTime));
% We replace (elapsed microseconds from START OF ACQUSITION) with (elapsed
% microseconds from FIRST EVENT).  The FPGA can leave long (~hundreds of
% milliseconds) gaps before the first event is clocked in, and this plays
% merry hell with the FFTs later.
Events(:,4) = Events(:,4)-Events(1,4);
% Elapsed time in (float) seconds.
TimeInSecs = double(Events(:,4))/1.0E6;


%% Calculate time series.
delt=stocktimebins;
if delt>max(TimeInSecs) % it breaks the histogram...
    error('Time bin is greater than length of acquisition.'); %... so abort this particular stocktimebin
end
bins=0:delt:max(TimeInSecs);
bins=[bins (max(bins)+delt)];
lastind = 0;


%yyaxis left;

Et=TimeInSecs;
Epi=find(Events(:,3)==1);
Eni=find(Events(:,3)==0);
%Emid0=find(events(:,2)==90);

Emid1=find(Events(:,1)>=105);
Emid2=find(Events(:,1)<=105);
Emid3=find(Events(:,2)>=45);
Emid4=find(Events(:,2)<=45);

Emid=intersect(Emid1,Emid2);
Emid=intersect(Emid,Emid3);
Emid=intersect(Emid,Emid4);

xedges=1:x_max+1;
yedges=1:y_max+1;

aa=find(Events(:,3)==1);
bb=find(Events(:,3)==0);

xx=Events(:,1);
yy=Events(:,2);
tt=Events(:,4);

xxp=xx(aa);
yyp=yy(aa);
xxn=xx(bb);
yyn=yy(bb);

height=uint32(720);
width=uint32(1280);
%% Sextuple graph showing x,y,pol histograms and time ramp
f1=figure('Units','Inches','Position',[0 0 7.65 9.9]);
%f1=figure();
t=tiledlayout('flow');
t.TileSpacing = 'compact';
t.Padding = 'compact';
% count of up and count of down events.
c_up = length(find(Events(:,3)==1));
c_down=length(find(Events(:,3)==0));

% append(rpt,['Found ',char(nf.format(length(Events))),' events.']);
% append(rpt,['Found ',char(nf.format(c_up)),' UP events.']);
% append(rpt,['Found ',char(nf.format(c_down)),' DOWN events.']);

e1=Events(1,4);
e2=Events(end,4);
% s1=Paragraph(['Acquisition started at Neuro time ',h5readatt(allh5filename,'/FalconNeuro','Time of Start of Acquisition')]);
% s1.Bold;
% append(rpt,s1);
% append(rpt,['Found 1st event at time ',char(nf.format(e1)),' microseconds after acquisition start.']);
% append(rpt,['Found last event at time ',char(nf.format(e2)),' microseconds after acquisition start.']);
% append(rpt,['Total event span (start to end) ',num2str(double(e2-e1)/1E6),' seconds.']);

q22=[char(nf.format(length(Events))),' events (',char(nf.format(c_down)),' down, ',char(nf.format(c_up)),' up) in ',num2str(double(e2-e1)/1E6),' seconds'];

nexttile;
binlims=[0:1:1280];
histogram(Events(:,1),binlims)
title('X-pixel histogram','interpreter','none');
xlabel('Bin');
ylabel('Count')
axis tight;

nexttile;
binlims=[0:1:720];
histogram(Events(:,2),binlims)
title('Y-pixel histogram','interpreter','none');
xlabel('Bin')
ylabel('Count')
axis tight;

nexttile;
h3=histogram(Events(:,3)) ;
title('Polarity','interpreter','none');
xticks([0 1]);
xticklabels({'down','up'});
ylabel('Count')
axis tight;

nexttile; % Count vs time
zz=1:1:length(Events(:,4));
plot(Events(:,4)/1E6,zz)
title('Event Count vs Time','interpreter','none');
ylabel('Event #');
xlabel('Elapsed Time (s)')
axis tight;

nexttile; % Event rates
% Histogram of event rates
h1=histogram(Et(Epi),bins);
hold on
h2=histogram(Et(Eni),bins);
h1.FaceColor='r';
h2.FaceColor='b';
h1.DisplayStyle='stairs';
h2.DisplayStyle='stairs';
h1.Normalization='countdensity';
h2.Normalization='countdensity';
tit1='Event Count Rate vs Time';
title({tit1},'interpreter','none');
xlabel('Elapsed Time (s)');
ylabel('Event Rate (s^{-1})');
legend('Positive (1)','Negative (0)');
axis tight;
[p1a,p1b]=max(h1.Values);
[p2a,p2b]=max(h2.Values);
% s1=['Max pos event rate at t = ',num2str(Et(p1b)),' s'];
% s2=['Max neg event rate at t = ',num2str(Et(p2b)),' s'];
%subtitle({s1, s2});

nexttile; % Event delta timestamp
dtt=diff(tt);
binedges=0:25;
h3=histogram(dtt,'BinEdges',binedges);
h3.DisplayStyle='stairs';
tit1='Event delta time';
title({tit1},'interpreter','none');
xlabel('\mus');
ylabel('#');
axis tight;

% Save plot as file
pn=[q2,'_XYPCRD_Counts.png'];
pf=q2;
picname=pn;
q21=['Start time = ',TimeStart, ' UTC'];
title(t,h5filename,{q21,q22},'interpreter','none');
print('-dpng', picname);
% list_repplot{num_repplot}=picname;
% num_repplot=num_repplot+1;
% hold off;

%%
%imgObj = Image(picname);
%append(rpt,imgObj);

% figReporter2 = Image(picname);
% figReporter2.Height='9.9in';
% figReporter2.Width='7.65in';
% add(rpt,figReporter2);


% %% Twin graphs showing pos, neg event focal plane 2D histograms
% f2=figure('Units','Inches','Position',[1 0 7.65 9.9]);
% %f=figure();
% 
% if camname=="NADIR"
%     t=tiledlayout(2,1,'Visible','on');
% else
%     t=tiledlayout(1,2,'Visible','on');
% end
% %t.TileSpacing = 'tight';
% % t.Padding = 'tight';
% t.Title.String=h5filename;
% t.Title.Interpreter='none';
% % s1=[char(nf.format(length(events))),' events (',char(nf.format(c_up)),' up, ',char(nf.format(c_down)),' down)'];
% % s2=['Acquisition Time = ',num2str(double(e2-e1)/1E6),' seconds']
% q20='Total Events per Pixel';
% q23='';
% t.Subtitle.String={q20,q22,q23};
% %t.Subtitle.String={s1,s2};
% t.Subtitle.Interpreter='none';
% 
% nexttile;
% h1=histogram2(xxp,yyp,'XBinEdges',xedges,'YBinEdges',yedges,'DisplayStyle','tile','Visible','off');
% h1.FaceColor='flat';
% tc_pos=h1.Values;
% clims=[0 10];
% 
% if camname=="NADIR"
%     imagesc(flipud(imrotate(tc_pos,-90)),clims);
%     xticks([]);
%     yticks([]);
% 
% else % RAM
%     imagesc(tc_pos,clims);
%     xticks([]);
%     yticks([]);
% 
% end
% if camname=="NADIR"
%     ylabel('-X_{ISS} (Aft in +XVV)');
%     xlabel('-Y_{ISS} (Starboard in +XVV)');
% else % RAM
%     xlabel('-Z_{ISS} (Down in +XVV)');
%     ylabel('+Y_{ISS} (Port in +XVV)');
% end
% title('All Positive Events')
% 
% daspect([1 1 1]);
% %title('All Positive Events');
% 
% nexttile;
% h2=histogram2(xxn,yyn,'XBinEdges',xedges,'YBinEdges',yedges,'DisplayStyle','tile','Visible','off');
% h2.FaceColor='flat';
% tc_neg=h2.Values;
% %clims=[0 max(max(tc_neg))];
% if camname=="NADIR"
%     imagesc(flipud(imrotate(tc_neg,-90)),clims);
%     xticks([]);
%     yticks([]);
% else % RAM
%     imagesc(tc_neg,clims);
%     xticks([]);
%     yticks([]);
% end
% if camname=="NADIR"
%     ylabel('-X_{ISS} (Aft in +XVV)');
%     xlabel('-Y_{ISS} (Starboard in +XVV)');
% else % RAM
%     xlabel('-Z_{ISS} (Down in +XVV)');
%     ylabel('+Y_{ISS} (Port in +XVV)');
% end
% title('All Negative Events')
% c=colorbar;
% c.Layout.Tile='east';
% c.Label.String='Counts / pixel';
% daspect([1 1 1]);
% 
% 
% pn=[q2,'_TPC.png'];
% pf=q2;
% picname=pn;
% print('-dpng', picname);
% list_repplot{num_repplot}=picname;
% num_repplot=num_repplot+1;
% hold off;
% %%
% figReporter2 = Image(picname);
% figReporter2.Height='9.9in';
% figReporter2.Width='7.65in';
% add(rpt,figReporter2);



%% FFT Transforms
% f3=figure('Units','Inches','Position',[2 0 7.65 9.9]);
% %f=figure();
% 
% delt=stocktimebins;
% bins=0:delt:max(TimeInSecs);
% %bins=0:delt:thigh;
% bins=[bins (max(bins)+delt)];
% hsel=histogram(Et,bins);
% ttn=hsel.Values;
% Fs = 1/delt;          % Sampling frequency
% T = 1/Fs;             % Sampling period
% L = length(ttn);      % Length of signal
% t = (0:L-1)*T;        % Time vector
% 
% Y = fft((ttn));
% P2 = abs(Y/L);
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% freq = Fs*(0:(L/2))/L;
% 
% t=tiledlayout('flow');
% % t.TileSpacing = 'tight';
% % t.Padding = 'tight';
% 
% t.Title.String=h5filename;
% t.Title.Interpreter='none';
% %s1=[char(nf.format(length(events))),' events (',char(nf.format(c_up)),' up, ',char(nf.format(c_down)),' down'];
% s1='Single-sided Amplitude Spectrum of Events';
% freqlow=5;
% [ii,jj]=find(freq>freqlow);
% [a,b]=max(P1(jj));
% s2=['Dominant Frequency (>',num2str(freqlow),' Hz) = ',num2str(freq(b)+freqlow),' Hz'];
% t.Subtitle.String={s1,s2};
% 
% 
% 
% t.Subtitle.Interpreter='none';
% xlabel(t,'freq (Hz)')
% ylabel(t,'|P1(f)|')
% %axis tight;
% 
% 
% nexttile; % All events
% semilogy(freq,P1)
% %xticks=([0:10:max(P1)]);
% tit2='All frequencies';
% title(tit2,'interpreter','none');
% 
% nexttile; % < 100 Hz
% semilogy(freq,P1);
% xticks(0:10:100);
% xlim([0 100]);
% yticks([]);
% title('< 100 Hz','interpreter','none');
% %axis tight;
% 
% pn=[q2,'_FFT.png'];
% pf=q2;
% picname=pn;
% print('-dpng', picname);
% list_repplot{num_repplot}=picname;
% num_repplot=num_repplot+1;
% hold off;
% %%
% figReporter2 = Image(picname);
% figReporter2.Height='9.9in';
% figReporter2.Width='7.65in';
% add(rpt,figReporter2);


%% Make the movie frames
% We have to remove all the bad events that have x,y pixels out of bounds.
% This is to avoid breaking the moviemaker.
f=figure('Units','Inches','Position',[3 0 7.65 9.9]);
%f=figure();
EventsT=Events(find(Events(:,1)<x_max & Events(:,2)<y_max ),:);
EventsT=double(EventsT);
nTimeInSecs=EventsT(:,4)/1E6; % Fractional seconds, not integer microseconds



for nd=1:length(movieframes) % loop through our time bins
    delt=movieframes(nd);
    if delt>max(TimeInSecs) % it breaks the histogram...
        continue; %... so abort this particular stocktimebin
    end
    bins=0:delt:max(TimeInSecs); % set up all the bin edges
    bins=[bins (max(bins)+delt)]; % ..and the last one.

    realmname=[q2,'_',num2str(delt*1E3),'_ms.avi']; % create a movie file name.
    %mname='test.mp4';

    if (1/delt) > 30
        output_frame_rate = 10; % if it's a small bin size we want a decently fast frame rate to see it.
    else
        output_frame_rate = ceil(1/delt); % if it's a large bin size we want to slow down the movie.
    end

    %delete('frame*.png'); % delete any existing movie frames.
    %delete(mname);
    % Set up the writer object and open it.
%    writerObj = VideoWriter(realmname, 'MPEG-4');
    writerObj = VideoWriter(realmname, 'Uncompressed AVI');
    writerObj.FrameRate = output_frame_rate;
    open(writerObj);
    if make_movie_bool % This is the on/off switch to actually make the movie.
        tcntr=0;
        for fc=1:length(bins)-1 % frame count

            if (bins(fc)<movie_start_time | bins(fc)>(movie_start_time+movie_length))
                continue; % ignore everything outside of the movie selection
            else
                tcntr=tcntr+1;
                %disp(['> ',num2str(bins(fc))]);
                figname=['frame',num2str(fc,'%010i'),'.png']; % create the movie frame file name with the frame index.
                frame=zeros(x_max,y_max); % initialize an array
                frame_net_pol=double(zeros(x_max,y_max)); % sum of polarities, must be type double because we're going to set negative polarities to -1
                frame_num_pos=zeros(x_max,y_max); % number of pos events
                frame_num_neg=zeros(x_max,y_max); % number of neg events

                f_ev_index=find((nTimeInSecs >= bins(fc)) & (nTimeInSecs < bins(fc) + delt)); % event index in each time bin
                f_ev=EventsT(f_ev_index,:);

                loc_ev_pos=find(f_ev(:,3)==1); % index of which events are positive
                loc_ev_neg=find(f_ev(:,3)==0); % index of which events are negative

                f_ev_neg_x=f_ev(loc_ev_neg,1);   % these are the x's of the negative events
                f_ev_neg_y=f_ev(loc_ev_neg,2);   % these are the y's of the negative events
                
                f_ev_pos_x=f_ev(loc_ev_pos,1);   % these are the x's of the positive events
                f_ev_pos_y=f_ev(loc_ev_pos,2);   % these are the y's of the positive events
                
                 h_neg=histogram2(f_ev_neg_x,f_ev_neg_y,'XBinEdges',xedges,'YBinEdges',yedges,'DisplayStyle','tile','Visible','off');
                % h_neg_v is a 2D array.
                h_neg_v=h_neg.Values;
               
                h_pos=histogram2(f_ev_pos_x,f_ev_pos_y,'XBinEdges',xedges,'YBinEdges',yedges,'DisplayStyle','tile','Visible','off');
                h_pos_v=h_pos.Values;
                
                colormap(jet);
                
%                 f_ev_pol=EventsT(f_ev_index,3); % see above re: negative polarities
%                 f_ev_pol(find(f_ev_pol==0))=-1;
%                 f_ev(:,3)=f_ev_pol;

                t=tiledlayout(2,1,'Visible','on');
                
                % Plot the frame of positive events.
                nexttile(1);
                imagesc(h_pos_v',clims);
                daspect([1 1 1]);
                title('Positive Events');
                axis xy
                colorbar
                nexttile(2);
                imagesc(h_neg_v',clims);
                title('Negative Events');
                daspect([1 1 1]);
                axis xy
                colorbar
                % Add a title...
                %
                t1=['Time = ',num2str(bins(fc),'%.5f'),' to ',num2str((bins(fc)+delt),'%.5f'),' sec'];
                sgtitle({t0;t1},'Interpreter','none');
                
              
                % Print the image to a file...
                print('-dpng',figname);
                % ... and immediately read it back into an image object
                % that is written as the next writer object frame.
                img=imread(figname);
                writeVideo(writerObj,img);
%                 figReporter2 = Image(figname);
%                 figReporter2.Height='9.9in';
%                 figReporter2.Width='7.65in';
%                 add(rpt,figReporter2);

            end % of the if/else checking we are in the movie start/length

        end % of the loop over the movie frames
        close(writerObj); % close the video file
        %delete('frame*.png'); % get rid of all the frame images
    end % of the if(false/true)


end % of looping through different desired frame sizes.

%% Housekeeping
% rpts5=Chapter('Outputs');
% rpts5.Numbered = false;
% append(rpt,rpts5);
% for i=1:num_repplot-1
%     append(rpt,['Written image ',list_repplot{i}]);
% end

if (make_movie_bool)
%     if isfile(realmname)
%         str=['_old_',tsnow,'.mp4'];
%         movefile(realmname,strrep(realmname,'.mp4',str));
%     end
    %movefile(mname,realmname);
%     append(rpt,['Written movie file ',realmname]);
end
% close(rpt);

% if isfile(rname) % Rename any older versions of the report.
%     str=['_old_',tsnow,'.pdf'];
%     movefile(rname,strrep(rname,'.pdf',str));
% end
%movefile(tempreportname,rname);
%%


%close all;
%rptview(rpt);