%
%   Gen4_freq_count.m
%
%   McHarg 2022
%
%   Specify a data file name  use one of the .dat files made by Prop
%   software.  Load the data using load_cd_events subroutine.  Strip off
%   the time, x, y and polarity.  
%
close all
clear
fil_nam='F1_cd.dat';
final_path='D:\Users\Matthew.Mcharg\Documents\mcharg\McHarg\matlab\mfiles\Falcon ODIN\EBS_Gen4_lab';
data=load_cd_events(fil_nam);
time_in_secs=(data.ts-data.ts(1))/1E6;
x=data.x;
y=data.y;
p=data.p;
%
%   Set x and y limits for pixels
%   Note it 0 counts with x=0:1279 and y=0:719
%
xmax=1279;
ymax=719;
xedges=[0:xmax];
yedges=[0:ymax];
%
%   Set up the frequency and the number of seconds you want to analyze
% 
led_freq=20;  % Note this is a variable you change.  This is the frequency the LED was flashing
time_secs=2.0;  % This is a variable you change.  This is the last time in seconds you want to analyze
n_cycles=led_freq*time_secs;  % Calculated number of cycles in the time you analyze
%
%   trim the data in time, and get the positive and negative events
%   separated
%
good_index=find(time_in_secs <= time_secs);
x_trim=x(good_index);
y_trim=y(good_index);
p_trim=p(good_index);
time_trim=time_in_secs(good_index);
ppe=find(p_trim==1);  % the positive polarity events
npe=find(p_trim==-1); % the negative polarity events
xxp=x_trim(ppe);
yyp=y_trim(ppe);
%
%   make the 2D hsitogram for positive events
%
h1=histogram2(xxp,yyp,'XBinEdges',xedges,'YBinEdges',yedges);
tc_pos=h1.Values;
figure
imagesc(tc_pos);
 axis image
 colorbar
 title('Number of positive events per pixel')
 
plotname=[final_path,'\','posppixel'];
poutfile=['print(''-djpeg'',''',plotname,''')'];
eval(poutfile) 
 %
 %  Now normalize the events by number of cycles
 %
 figure
 tcp_norm=tc_pos/n_cycles;
 imagesc(tcp_norm);
 axis image
 colorbar
 
 %
 %  Now get the pixels with at least 0.5 events per pixel
 %
 figure
 big_index=find(tcp_norm >= 0.5);
 avg_pos_cycle=mean(tcp_norm(big_index))
 title(['Positive events per pixel per cycle','avg = ',num2str(avg_pos_cycle)])
 plotname=[final_path,'\','pospcycle'];
poutfile=['print(''-djpeg'',''',plotname,''')'];
eval(poutfile) 
 
 
 %
%   make the 2D hsitogram for negative events
%
xnp=x_trim(npe);
ynp=y_trim(npe);
h1=histogram2(xnp,ynp,'XBinEdges',xedges,'YBinEdges',yedges);
tc_neg=h1.Values;
figure
imagesc(tc_neg);
 axis image
 colorbar
 title('Number of negative events per pixel')
 plotname=[final_path,'\','negppixel'];
poutfile=['print(''-djpeg'',''',plotname,''')'];
eval(poutfile) 
 
 %
 %  Now normalize the events by number of cycles
 %
 figure
 tcn_norm=tc_neg/n_cycles;
 imagesc(tcp_norm);
 axis image
 colorbar
 
 %
 %  Now get the pixels with at least 0.5 events per pixel
 %
 big_indexn=find(tcn_norm >= 0.5);
 avg_neg_cycle=mean(tcn_norm(big_indexn))
 title(['Negative events per pixel per cycle','avg = ',num2str(avg_neg_cycle)])
 plotname=[final_path,'\','negpcycle'];
poutfile=['print(''-djpeg'',''',plotname,''')'];
eval(poutfile) 