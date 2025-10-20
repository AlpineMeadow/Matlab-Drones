function EventBasedSummaryPlot(Events, info)



Et = double(Events(:,4))/1.0E6;


nf = info.nf;
outFileName = info.outFileName;
stockTimeBins = info.stockTimeBins;

bins = 0 : stockTimeBins : max(Et);
bins = [bins (max(bins) + stockTimeBins)];

%Generate indices for positive and negative events.
positiveEventsIndex=find(Events(:, 3) == 1);
negativeEventsIndex=find(Events(:, 3) == 0);

% Sextuple graph showing x,y,pol histograms and time ramp
f1 = figure('Units','Inches','Position',[0 0 7.65 9.9]);

t = tiledlayout('flow');
t.TileSpacing = 'compact';
t.Padding = 'compact';

% count of up and count of down events.
numPositiveEvents = length(positiveEventsIndex);
numNegativeEvents = length(negativeEventsIndex);

timeSpan = (Events(end, 4) - Events(1, 4))/1.0e6;


q22=[char(nf.format(length(Events))),' events (',char(nf.format(numNegativeEvents)),...
    ' down, ',char(nf.format(numPositiveEvents)),' up) in ',num2str(double(timeSpan)),' seconds'];

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
h1=histogram(Et(positiveEventsIndex),bins);
hold on
h2=histogram(Et(negativeEventsIndex),bins);
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


nexttile; % Event delta timestamp
dtt=diff(Events(:, 4));
binedges=0:25;
h3=histogram(dtt,'BinEdges',binedges);
h3.DisplayStyle='stairs';
tit1='Event delta time';
title({tit1},'interpreter','none');
xlabel('\mus');
ylabel('#');
axis tight;

% Save plot as file
saveas(f1, outFileName);


end