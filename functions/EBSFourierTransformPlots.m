function [outputArg1,outputArg2] = EBSFourierTransformPlots(Events, info)

%FFT Transforms
fig = figure('Units','Inches','Position',[12 0.5 7.65 9.9]);


% We replace (elapsed microseconds from START OF ACQUSITION) with (elapsed
% microseconds from FIRST EVENT).  The FPGA can leave long (~hundreds of
% milliseconds) gaps before the first event is clocked in, and this plays
% merry hell with the FFTs later.
Events(:,4) = Events(:,4) - Events(1,4);

% Elapsed time in (float) seconds.
TimeInSecs = double(Events(:,4))/1.0e6;


% Calculate time series.
deltaT = info.stockTimeBins;
if deltaT>max(TimeInSecs) % it breaks the histogram...
    error('Time bin is greater than length of acquisition.'); %... so abort this particular stocktimebin
end

%Set up the bins for the histograms.
bins = 0 : deltaT : max(TimeInSecs);
bins = [bins (max(bins) + deltaT)];


Et=TimeInSecs;



hsel = histogram(Et,bins);
ttn = hsel.Values;
Fs = 1/deltaT;          % Sampling frequency
T = 1/Fs;             % Sampling period
L = length(ttn);      % Length of signal
t = (0:L-1)*T;        % Time vector

Y = fft((ttn));
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
freq = Fs*(0:(L/2))/L;

t=tiledlayout('flow');


t.Title.String = info.movieName;
t.Title.Interpreter='none';
s1='Single-sided Amplitude Spectrum of Events';
freqlow=5;
[ii,jj]=find(freq>freqlow);
[a,b]=max(P1(jj));
s2=['Dominant Frequency (>',num2str(freqlow),' Hz) = ',num2str(freq(b)+freqlow),' Hz'];
t.Subtitle.String={s1,s2};

t.Subtitle.Interpreter='none';
xlabel(t,'freq (Hz)')
ylabel(t,'|P1(f)|')

nexttile; % All events
semilogy(freq,P1)
tit2='All frequencies';
title(tit2,'interpreter','none');

nexttile; % < 100 Hz
semilogy(freq,P1);
xticks(0:10:100);
xlim([0 100]);
yticks([]);
title('< 100 Hz','interpreter','none');
%axis tight;

pn=[info.movieName,'_FFT.png'];
%pf=q2;
picname=pn;
print('-dpng', picname);
%list_repplot{num_repplot}=picname;
%num_repplot=num_repplot+1;
hold off;


end  %End of the function EBSFourierTransformPlots.m