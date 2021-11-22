%% Plot raw ThunderSTORM results to find boundaries. First build the struc.
clear; clc;

TS_Directory = dir('TS_Results');
isMatch = ~cellfun('isempty', strfind({TS_Directory.name}, '.csv'));
%isMatch = ~cellfun('isempty', strfind({TS_Directory.name}, 'filter'));
TS_Directory = TS_Directory(isMatch);

intens = []; sigma = [];
w = waitbar(0,'Please wait...');
for idxa = 1:length(TS_Directory);
    waitbar(idxa/length(TS_Directory),w,...
            ['At track ' num2str(idxa) ' of ' num2str(length(TS_Directory))]);
    file_num = TS_Directory(idxa).name(end-5:end-4);
    file_curr = readtable([pwd '/TS_Results/' TS_Directory(idxa).name]);
    intens = [intens; file_curr.intensity_photon_];
    sigma = [sigma; file_curr.sigma_nm_];
end
close(w);

%% Plot the results.
close all;
sigma_lower_boundary = 10;
sigma_upper_boundary = 300;
intensity_boundary = 1000;
intensity_bins = 0:25:intensity_boundary
sigma_bins = 80:10:sigma_upper_boundary
figsize = [10 4];

f = figure('Units','Inches','Position',[0 0 figsize],'PaperUnits','inches','PaperPosition',[0 0 figsize],'PaperSize',figsize,'CreateFcn','movegui center');
ax1 = subplot(1,2,1);
histogram(intens,intensity_bins,'Normalization','Probability','FaceColor',rgb('GainsBoro'),'EdgeColor','k','LineWidth',1);
xlabel('Intensity (Photon)');
ylabel('Frequency');

ax2 = subplot(1,2,2);
histogram(sigma,sigma_bins,'Normalization','Probability','FaceColor',rgb('GainsBoro'),'EdgeColor','k','LineWidth',1);
xlabel('Sigma (nm)');
ylabel('Frequency');

set([ax1 ax2],'Box','Off','TickDir','Out','LineWidth',1.5,'FontSize',14,'XColor','k','YColor','k','XTick',[]);

%% Filter ThunderSTORM results
clear; clc;
sigma_lower_boundary = 100;
sigma_upper_boundary = 300;
intensity_boundary = 500;

TS_Directory = dir('TS_Results');
isMatch = ~cellfun('isempty', strfind({TS_Directory.name}, '.csv'));
TS_Directory = TS_Directory(isMatch);

w = waitbar(0,'Please wait...');
for idxa = 1:length(TS_Directory);
    waitbar(idxa/length(TS_Directory),w,...
            ['At track ' num2str(idxa) ' of ' num2str(length(TS_Directory))]);
    file_num = TS_Directory(idxa).name(end-5:end-4);
    file_curr = readtable([pwd '/TS_Results/' TS_Directory(idxa).name]);
    file_curr([find(file_curr.intensity_photon_ > intensity_boundary)],:) = [];
    file_curr([find(file_curr.sigma_nm_ < sigma_lower_boundary)],:) = [];
    file_curr([find(file_curr.sigma_nm_ > sigma_upper_boundary)],:) = [];
    writetable(file_curr,[pwd '/TS_results/TS_results-filter-' file_num '.csv']);
end
close(w);