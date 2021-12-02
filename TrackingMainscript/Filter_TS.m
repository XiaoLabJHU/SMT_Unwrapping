%% Initialize directories
clear; clc;

if ~exist("MAIN_dir", "var")
     MAIN_dir = uigetdir([],"Choose main data folder");
end
cd(MAIN_dir);

%% Plot raw ThunderSTORM results to find boundaries. First build the struc.
%clear; clc;

TS_Directory = dir('TS_Results');

%handles.RfTr_files = dir('*.csv');
%isMatch = ~cellfun('isempty', strfind({TS_Directory.name}, '.csv'));
isMatch = contains(strfind(TS_Directory.name, '.csv'));
% isMatch = ~cellfun('isempty', strfind({TS_Directory.name}, 'filter'));
TS_Directory = TS_Directory(isMatch);

intens = []; sigma1 = []; sigma2 = [];
w = waitbar(0,'Please wait...');
for idxa = 1:length(TS_Directory)
    waitbar(idxa/length(TS_Directory),w,...
            ['At track ' num2str(idxa) ' of ' num2str(length(TS_Directory))]);
    file_num = TS_Directory(idxa).name(end-5:end-4);
    file_curr = readtable([pwd '/TS_Results/' TS_Directory(idxa).name]);
    intens = [intens; file_curr.intensity_photon_];
    sigma1 = [sigma1; file_curr.sigma1_nm_];
    sigma2 = [sigma2; file_curr.sigma2_nm_];
end
close(w);

%% Plot the results.
close all;
%sigma_lower_limit = 0;
%sigma_upper_limit = 300;
sigma_bins = 0:10:300;

%intensity_limit = 1000;
intensity_bins = 0:25:1000;

intensity_boundary = 500;

sigma_lower_boundary = 100;
sigma_upper_boundary = 300;

filtered_intensity_bins = 0:25:intensity_boundary;
filtered_sigma_bins = sigma_lower_boundary:10:sigma_upper_boundary;

figsize = [15 8];

f = figure('Units','Inches','Position',[0 0 figsize],'PaperUnits','inches','PaperPosition',[0 0 figsize],'PaperSize',figsize,'CreateFcn','movegui center');

ax1 = subplot(2,3,1);
histogram(intens,intensity_bins,'Normalization','Probability','FaceColor',rgb('GainsBoro'),'EdgeColor','k','LineWidth',1);
xlabel('Intensity (Photon)');
ylabel('Frequency');

ax2 = subplot(2,3,2);
histogram(sigma1,sigma_bins,'Normalization','Probability','FaceColor',rgb('GainsBoro'),'EdgeColor','k','LineWidth',1);
xlabel('Sigma 1 (nm)');
ylabel('Frequency');

ax3 = subplot(2,3,3);
histogram(sigma2,sigma_bins,'Normalization','Probability','FaceColor',rgb('GainsBoro'),'EdgeColor','k','LineWidth',1);
xlabel('Sigma 2 (nm)');
ylabel('Frequency');

ax4 = subplot(2,3,4);
histogram(intens,filtered_intensity_bins,'Normalization','Probability','FaceColor',rgb('GainsBoro'),'EdgeColor','k','LineWidth',1);
xlabel('Intensity (Photon)');
ylabel('Frequency');

ax5 = subplot(2,3,5);
histogram(sigma1, filtered_sigma_bins,'Normalization','Probability','FaceColor',rgb('GainsBoro'),'EdgeColor','k','LineWidth',1);
xlabel('Sigma 1 (nm)');
ylabel('Frequency');

ax6 = subplot(2,3,6);
histogram(sigma2, filtered_sigma_bins,'Normalization','Probability','FaceColor',rgb('GainsBoro'),'EdgeColor','k','LineWidth',1);
xlabel('Sigma 2 (nm)');
ylabel('Frequency');

set([ax1 ax2 ax3 ax4 ax5 ax6],'Box','Off','TickDir','Out','LineWidth',1.5,'FontSize',14,'XColor','k','YColor','k');
print(f,'TS_Filtering.png','-dpng','-r600') %print the figure window to png with 600 dpi.
print(f,'TS_Filtering.pdf','-dpdf') %print the figure window to pdf so you can have vector graphics.

%% Filter ThunderSTORM results
% clear; clc;
% sigma_lower_boundary = 100;
% sigma_upper_boundary = 300;
% intensity_boundary = 500;

TS_Directory = dir('TS_Results');
isMatch = ~cellfun('isempty', strfind({TS_Directory.name}, '.csv'));
TS_Directory = TS_Directory(isMatch);

w = waitbar(0,'Please wait...');
for idxa = 1:length(TS_Directory)
    waitbar(idxa/length(TS_Directory),w,...
            ['At track ' num2str(idxa) ' of ' num2str(length(TS_Directory))]);
    file_num = TS_Directory(idxa).name(end-5:end-4);

    %filter intensity
    file_curr = readtable([pwd '/TS_Results/' TS_Directory(idxa).name]);
    file_curr([find(file_curr.intensity_photon_ > intensity_boundary)],:) = [];
    
    %filter sigma 1
    file_curr([find(file_curr.sigma1_nm_ < sigma_lower_boundary)],:) = [];
    file_curr([find(file_curr.sigma1_nm_ > sigma_upper_boundary)],:) = [];
    
    %filter sigma 2
    file_curr([find(file_curr.sigma2_nm_ < sigma_lower_boundary)],:) = [];
    file_curr([find(file_curr.sigma2_nm_ > sigma_upper_boundary)],:) = [];
    writetable(file_curr,[pwd '/TS_results/TS_results-filter-' file_num '.csv']);
end
close(w);