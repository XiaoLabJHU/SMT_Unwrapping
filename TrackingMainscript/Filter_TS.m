%% Plot raw ThunderSTORM results to find boundaries. First build the struc.
% Assumes folder with ThunderSTORM results is named "TS_Results."
% Be in the directory above that.
clear; clc;

%Answer with '2D' or '3D'.
Tracking = '2D';

TS_Directory = dir('TS_Results');
%-------------------------------------------------------------------------
isMatch = ~cellfun('isempty', strfind({TS_Directory.name}, '.csv'));
TS_Directory = TS_Directory(isMatch);

%remove any csv files with 'filter' in the name. Useful if reanalyzing old data set.
isMatch = ~cellfun('isempty', strfind({TS_Directory.name}, 'filter'));
TS_Directory(isMatch) = [];

intens = []; sigma1 = []; sigma2 = []; sigma = [];
w = waitbar(0,'Please wait...');
for idxa = 1:length(TS_Directory)
    waitbar(idxa/length(TS_Directory),w,...
            ['At track ' num2str(idxa) ' of ' num2str(length(TS_Directory))]);
    file_num = TS_Directory(idxa).name(end-5:end-4);
    file_curr = readtable([pwd '/TS_Results/' TS_Directory(idxa).name]);
    intens = [intens; file_curr.intensity_photon_];
    switch Tracking
        case '3D'
            sigma1 = [sigma1; file_curr.sigma1_nm_];
            sigma2 = [sigma2; file_curr.sigma2_nm_];
        case '2D'
            sigma = [sigma; file_curr.sigma_nm_];
    end
end
close(w);

%% Plot the results and test boundaries for fit.
close all;

%Input your parameters below.
figsize = [10 8];
intensity_boundary = 500;

%If using 2D tracking:
sigma_lower_boundary = 100;
sigma_upper_boundary = 300;

%If using 3D tracking:
sigma1_lower_boundary = 100;
sigma1_upper_boundary = 300;
sigma2_lower_boundary = 100;
sigma2_upper_boundary = 300;

%-----------------------------------------------------------------------------
%Calculate bins from boundaries.
filtered_intensity_bins = 0:25:intensity_boundary;
switch Tracking
    case '2D'
        filtered_sigma_bins = sigma_lower_boundary:10:sigma_upper_boundary;
    case '3D'
        filtered_sigma1_bins = sigma1_lower_boundary:10:sigma1_upper_boundary;
        filtered_sigma2_bins = sigma2_lower_boundary:10:sigma2_upper_boundary;
end

f = figure('Units','Inches','Position',[0 0 figsize],'PaperUnits','inches','PaperPosition',[0 0 figsize],'PaperSize',figsize,'CreateFcn','movegui center');

switch Tracking
    case '2D'; subplot(2,2,1);
    case '3D'; subplot(2,3,1);
end
histogram(intens,50,'Normalization','Probability','FaceColor',rgb('GainsBoro'),'EdgeColor','k','LineWidth',1);
xlabel('Intensity (Photon)');
ylabel({'\bfUnfiltered\rm' 'Frequency'});
set(gca,'Yscale','log');
title(['\rmN = ' num2str(length(intens)) ' localizations'],'FontSize',12);

switch Tracking
    case '2D'
        subplot(2,2,2);
        histogram(sigma,50,'Normalization','Probability','FaceColor',rgb('GainsBoro'),'EdgeColor','k','LineWidth',1);
        xlabel('Sigma (nm)');
        ylabel('Frequency');
        
        subplot(2,2,3);
    case '3D'
        subplot(2,3,2);
        histogram(sigma1,50,'Normalization','Probability','FaceColor',rgb('GainsBoro'),'EdgeColor','k','LineWidth',1);
        xlabel('Sigma 1 (nm)');
        ylabel('Frequency');

        subplot(2,3,3);
        histogram(sigma2,50,'Normalization','Probability','FaceColor',rgb('GainsBoro'),'EdgeColor','k','LineWidth',1);
        xlabel('Sigma 2 (nm)');
        ylabel('Frequency');
        
        subplot(2,3,4);
end
histogram(intens,filtered_intensity_bins,'Normalization','Probability','FaceColor',rgb('GainsBoro'),'EdgeColor','k','LineWidth',1);
xlabel('Intensity (Photon)');
ylabel({'\bfFiltered\rm' 'Frequency'});

switch Tracking
    case '2D'
        subplot(2,2,4);
        histogram(sigma, filtered_sigma_bins,'Normalization','Probability','FaceColor',rgb('GainsBoro'),'EdgeColor','k','LineWidth',1);
        xlabel('Sigma (nm)');
        ylabel('Frequency');    
    case '3D'
        subplot(2,3,5);
        histogram(sigma1, filtered_sigma1_bins,'Normalization','Probability','FaceColor',rgb('GainsBoro'),'EdgeColor','k','LineWidth',1);
        xlabel('Sigma 1 (nm)');
        ylabel('Frequency');

        subplot(2,3,6);
        histogram(sigma2, filtered_sigma2_bins,'Normalization','Probability','FaceColor',rgb('GainsBoro'),'EdgeColor','k','LineWidth',1);
        xlabel('Sigma 2 (nm)');
        ylabel('Frequency');
end
set(f.Children,'Box','Off','TickDir','Out','LineWidth',1.5,'FontSize',14,'XColor','k','YColor','k');
print(f,'TS_Filtering.png','-dpng','-r600') %print the figure window to png with 600 dpi.
%print(f,'TS_Filtering.pdf','-dpdf') %print the figure window to pdf so you can have vector graphics.

%% Filter ThunderSTORM results
clear; clc;

%Answer with '2D' or '3D'.
Tracking = '2D';
intensity_boundary = 500;

%If using 2D tracking:
sigma_lower_boundary = 100;
sigma_upper_boundary = 300;

%If using 3D tracking:
sigma1_lower_boundary = 100;
sigma1_upper_boundary = 300;
sigma2_lower_boundary = 100;
sigma2_upper_boundary = 300;

TS_Directory = dir('TS_Results');
%---------------------------------------------------------------
isMatch = ~cellfun('isempty', strfind({TS_Directory.name}, '.csv'));
TS_Directory = TS_Directory(isMatch);

%remove any csv files with 'filter' in the name. Useful if reanalyzing old data set.
isMatch = ~cellfun('isempty', strfind({TS_Directory.name}, 'filter'));
TS_Directory(isMatch) = [];

w = waitbar(0,'Please wait...');
for idxa = 1:length(TS_Directory)
    waitbar(idxa/length(TS_Directory),w,...
            ['At track ' num2str(idxa) ' of ' num2str(length(TS_Directory))]);
    file_num = TS_Directory(idxa).name(end-5:end-4);
    file_curr = readtable([pwd '/TS_Results/' TS_Directory(idxa).name]);
    file_curr([find(file_curr.intensity_photon_ > intensity_boundary)],:) = [];
    
    switch Tracking
        case '2D'
            file_curr([find(file_curr.sigma_nm_ < sigma_lower_boundary)],:) = [];
            file_curr([find(file_curr.sigma_nm_ > sigma_upper_boundary)],:) = [];
        case '3D'
            file_curr([find(file_curr.sigma1_nm_ < sigma1_lower_boundary)],:) = [];
            file_curr([find(file_curr.sigma1_nm_ > sigma1_upper_boundary)],:) = [];
            file_curr([find(file_curr.sigma2_nm_ < sigma2_lower_boundary)],:) = [];
            file_curr([find(file_curr.sigma2_nm_ > sigma2_upper_boundary)],:) = [];
    end
    writetable(file_curr,[pwd '/TS_results/TS_results-filter-' file_num '.csv']);
end
close(w);