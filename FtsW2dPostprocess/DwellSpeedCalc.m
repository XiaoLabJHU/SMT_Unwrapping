% calculate the speed distribution and dwell time of a specific condition
clear
clc
% set the threshold for classification : direction motion
Nbin = 31;
LowB = -1.5;
HighB = 3;
Rmax1 = 0.45; % maximum R value
Rmax2 = 0.2; % R for long directional segments
StDmax = 80; % The boundary of standard deviation to justify stationary phase.
Pmin = 0.75; % minimum probability
Nb = 1000; % bootstrapping number

[filenameIn pathname] = uigetfile('.mat','input all the combined trace files','multiselect','on');
kk = 1;
pp = 1;
if ~iscell(filenameIn)
    filename{1} = filenameIn;
else
    filename = filenameIn;
end
for qq = 1 : length(filename)
    filenameX = filename{qq};
    load([pathname filenameX]);
    for ii = 1 : length(IndTrack)
        paraTemp = IndTrack(ii).StateFit;
        if ~isempty(paraTemp)
            for jj = 1 : length(paraTemp)
                Ratio = abs(paraTemp(jj).RatioXboot);
                StD = abs(paraTemp(jj).StDXboot); % new strucutres are StDXboot, old ones are StDboot
                R(kk,1) = Ratio(1);
                S(kk,1) = StD(1);
                P(kk,1) = abs(paraTemp(jj).P_progressive);
                DT(kk,1) = paraTemp(jj).DwellT;
                V(kk,1) = abs(paraTemp(jj).Vx);
                kk = kk + 1;
            end
        end
    end
end
% threshold
index  = find((R<=Rmax1&P>=Pmin)|R<=Rmax2);
index2 = find(((R>Rmax1|(P<Pmin)&R>Rmax2))&S<StDmax);%
Vx = V(index);
Vf = V(index2);
Dtx = DT(index);
Dtf = DT(index2);
Sdx = S(index);
Sdf = S(index2);
Vmean = mean(Vx);
Vmedian = median(Vx);
Dtxmean = mean(Dtx);
Dtfmean = mean(Dtf);
[T1 T2 Pt] = bootTsample(Dtx,Dtf,Nb);
VdirxBoot = bootstrp(Nb,@mean,Vx);
V_tot_dir = [mean(VdirxBoot),std(VdirxBoot)];

% calculate the histogram of dwell time of the directional and diffusive
[HisDx,HisDxx] = histcounts(Dtx,[0:2:50]);
[HisDf,HisDfx] = histcounts(Dtf,[0:2:50]);

% calculate the histogram of speed

% StrainName = 'MG1655-FtsW^C-PBP1B^C-MTSES';
[HisRes,HisX,HisObj] = histLog_xy(Vx,LowB,HighB,Nbin);

% plot the R and P scatter 
h = figure('position',[100,100,1600,400]);
subplot(1,3,1)
semilogx(R,P,'.','markersize',15)
ylim([0,1.1])
xline(Rmax2,'r',['R2 =' num2str(Rmax2)],'LabelVerticalAlignment','bottom')
xline(Rmax1,'k',['R1 =' num2str(Rmax1)],'LabelVerticalAlignment','bottom')
yline(Pmin,'r',['P =' num2str(Pmin)])
yline(0.5,':k','50% line')
xlabel('Ratio')
ylabel('P-progressive')
set(gca,'fontsize',18)
% threshold the data
hold on
semilogx(R(index),P(index),'+','markersize',15)
semilogx(R(index2),P(index2),'d','markersize',10)

subplot(1,3,2)
% xlim([0.6,300])
% set(gca,'fontsize',14);
% fit the two log-normal distribution
BinEdges = HisObj.BinEdges;
BinCenter = BinEdges(1:end-1) + diff(BinEdges);
LogCenter = log10(BinCenter);
% h1 = figure('PaperUnits','inches','PaperPosition',[0 0 12 4],'PaperSize',[12 4])

hold on
bar(LogCenter,HisRes,1,'w','LineWidth',2)
% [fitresult, gof] = twoGaussFit(LogCenter, HisRes);
xlim([0,2.5])
ylim([0,0.35])
xticks([0,1,2,3])
set(gca,'xticklabel',[1, 10, 100, 1000]);
set(gca,'fontsize',18);
xlabel('Speed (nm/s)','fontsize',24);
ylabel('Probability','fontsize',24);
grid on
title(['Vmean = ' num2str(Vmean,2) ';Vmedian = ' num2str(Vmedian,2)]);


subplot(1,3,3)
plot(HisDxx(1:end-1) + diff(HisDxx)/2,HisDx,'g','linewidth',3);
hold on
plot(HisDfx(1:end-1) + diff(HisDxx)/2,HisDf,'r','linewidth',3);
xline(Dtxmean,'g',num2str(Dtxmean,2));
xline(Dtfmean,'r',num2str(Dtfmean,2));
title(['Percentage of moving = ' num2str(Pt(1)*100) '%']);
set(gca,'fontsize',18);
legend('Progressive','Stationary')
xlabel('Dwell Time/s')
[filenameS pathnameS] = uiputfile('.mat','Save the statistics to...');
save([pathnameS filenameS],'Rmax1','Rmax2','Pmin','R','P','DT','V','index','index2','Vx','Dtx','Dtf','Pt','V_tot_dir','S');
saveas(h, 'combined-plot.fig')
waitforbuttonpress
close all
output = [Vmean,Vmedian,V_tot_dir(2),Pt*100];

