%% prepare strain structures.
clear; clc; close all;

cd(uigetdir([]));

p8962 = load('DataSets/AHalo.mat');
for idxa = 1:length(p8962.IndTrack)
   p8962.IndTrack(idxa).StateFit = [];
   p8962.IndTrack(idxa).StrainName = 'P8962';
end

Ahalo_fixed = load('DataSets/Ahalo_fixed.mat');
for idxa = 1:length(Ahalo_fixed.IndTrack)
   Ahalo_fixed.IndTrack(idxa).StateFit = [];
   Ahalo_fixed.IndTrack(idxa).StrainName = 'P8962-Fixed';
end

% jm213 = load('DataSets/Astar-Halo.mat');
% for idxa = 1:length(jm213.IndTrack)
%    jm213.IndTrack(idxa).StateFit = [];
%    jm213.IndTrack(idxa).StrainName = 'JM213';
% end

jm165 = load('DataSets/JM165.mat');
for idxa = 1:length(jm165.IndTrack)
   jm165.IndTrack(idxa).StateFit = [];
   jm165.IndTrack(idxa).StrainName = 'JM165';
end

jm175 = load('DataSets/JM175.mat');
for idxa = 1:length(jm175.IndTrack)
   jm175.IndTrack(idxa).StateFit = [];
   jm175.IndTrack(idxa).StrainName = 'JM175';
end

jm220 = load('DataSets/JM220.mat');
for idxa = 1:length(jm220.IndTrack)
   jm220.IndTrack(idxa).StateFit = [];
   jm220.IndTrack(idxa).StrainName = 'JM220';
end

% [file, path] = uigetfile('.mat','input the JM220 files.','multiselect','on');
% 
% for ii = 1:length(file)
%     path_ii = fullfile(path, file(ii));
%     jm220(ii) = load(path_ii{1});
%     for jj = 1:length(jm220(ii).IndTrack)
%        jm220(ii).IndTrack(jj).StateFit = [];
%        jm220(ii).IndTrack(jj).StrainName = 'JM220';
%     end
% end

%% Section 1: Create blinded structure.
%clear; clc; close all;
IndTrack = [p8962.IndTrack, Ahalo_fixed.IndTrack, jm165.IndTrack, jm175.IndTrack, jm220.IndTrack];

Threshold_all = [p8962.Threshold_all, Ahalo_fixed.Threshold_all, jm165.Threshold_all, jm175.Threshold_all, jm220.Threshold_all];


strains = {'P8962','P8962-Fixed','JM165','JM175','JM220'};

for idxa = 1:length(Threshold_all)
   Threshold_all(idxa).Strain = strains{idxa};
end

IndTrack = datasample(IndTrack,length(IndTrack),'Replace',false);
%IndTrack = rmfield(IndTrack,'StateFit');
save('DataSets/MYT_Blinded-AZ-Segmentation.mat','IndTrack','Threshold_all');

%% MYT Section 1: Workstation-specific parameters 
clear; clc;

Input_Params.Experiment = '2D_Tracking'; 
 
% set up some parameter2
Input_Params.PixelS = 100; % pixel size in nm
Input_Params.ExpT = 0.5; % time interval in second
Input_Params.TimeRange = [-10,250]; % the time range for trajectory ploting in sec ,better to have some space on both side
Input_Params.PosiXRang = [-500,500]; % the position range of short axis for plotting in nm
Input_Params.PosiYRang = [-200,200]; % the position range of short axis for plotting in nm
Input_Params.Nboot = 100; % number of the bootstrapping to get linear fitting
Input_Params.Pdrop = 0.1; %dropout probability in bootstrapping

%Is Martin in lab?
response = questdlg('Use two monitor setup?','Is Martin in lab?', 'Yes' ,'No','Yes');

if strcmp(response,'Yes')
    Input_Params.martin_is_in_lab = 1;

    Ind_pathname = '/Users/myepes/Xiao Lab Dropbox/Lab Members/Yepes_Martin/Projects/FtsA/20220610-FtsA-FtsZ_SMT/DataSets/';
    Ind_filename = 'R-MYT_Blinded-AZ-Segmentation.mat';
    Ind_path = fullfile([Ind_pathname, Ind_filename]);
    sim_path = '/Users/myepes/Xiao Lab Dropbox/Lab Members/McCausland_Josh/Projects/ZipA_Project/FtsA-FtsZ-Blinded/FtsA-FtsZ_500ms_sim.mat';
    img_pathname = '/Users/myepes/Xiao Lab Dropbox/Lab Members/Yepes_Martin/Projects/FtsA/20220610-FtsA-FtsZ_SMT/SegmentedTrajs';

    %com_path = ''
else
   
    Input_Params.martin_is_in_lab = 0;
    
    %Define Indtrack path
    disp('Input the pre-processed trace file (with IndTrack)');
    [Ind_filename, Ind_pathname] = uigetfile('.mat','input the pre-processed trace file (with IndTrack)');
    Ind_path = fullfile([Ind_pathname, Ind_filename]);
    %Define simulation path
    disp('Select the simulated stationary trajectories');
    [filenameSimu, pathnameSimu] = uigetfile('.mat','Select the simulated stationary trajectories');
    sim_path = fullfile([pathnameSimu filenameSimu]);
    %define segmented traj. jpg path
    disp('Input segmented traj. directory');
    img_pathname =  uigetdir('Input segmented traj. directory');
end

cd(Ind_pathname);
cd('..');
Input_Params.img_pathname = img_pathname;
Input_Params.Simul_strucs = load(sim_path);

I = load(Ind_path,'IndTrack','Threshold_all');
%% MYT Section 2: Resolve comments

close("all");
for i = 1:length(I.IndTrack)
    if ~isempty(I.IndTrack(i).comment) 
        period = find(I.IndTrack(i).file == '.');
        img_filename = ['Ind-' num2str(i) '-Str-' I.IndTrack(i).StrainName '-' I.IndTrack(i).file(1:8) '-' I.IndTrack(i).file(period-2:period-1) '-seg-' num2str(length(I.IndTrack(i).StateFit)) '.jpg'];
        img = imread(fullfile(img_pathname, img_filename));
        f1 = figure('Name',['Traj. ' num2str(i)]);
        imshow(img, []);
        title(I.IndTrack(i).comment);
        
        resp1 = questdlg(I.IndTrack(i).comment, "Resegment trajectory?",'Yes','No','Yes');
        close(f1);
        if strcmp(resp1, 'Yes')
            %Loads and writes indtrack files
            Segment_Blinded_Trajectories(i, Ind_path, Input_Params);
        end

        f1 = figure('Name',['Traj. ' num2str(i)]);
        imshow(img, []);
        title(I.IndTrack(i).comment);
        resp2 = questdlg(I.IndTrack(i).comment, "Resolve comment and continue?",'Yes','No','Yes');

        if strcmp(resp2, 'Yes')
            close(f1);
            %have to reload the file for changes to take effect
            I = load(Ind_path);
            I.IndTrack(i).comment = [];

            IndTrack = I.IndTrack;
            Threshold_all = I.Threshold_all;
            save(Ind_path,'IndTrack','Threshold_all');
        else
            disp(['Stopped at i = '  num2str(i)]);
            break
        end
    end
end
%% MYT Section 3: Add comments

close("all");

i_start = 598;

for i = i_start:length(I.IndTrack)
    if isempty(I.IndTrack(i).comment) 
        period = find(I.IndTrack(i).file == '.');
        img_filename = ['Ind-' num2str(i) '-Str-' I.IndTrack(i).StrainName '-' I.IndTrack(i).file(1:8) '-' I.IndTrack(i).file(period-2:period-1) '-seg-' num2str(length(I.IndTrack(i).StateFit)) '.jpg'];
        img = imread(fullfile(img_pathname, img_filename));
        f1 = figure('Name',['Traj. ' num2str(i)]);
        imshow(img, []);
        %title(I.IndTrack(i).comment);
        
        resp1 = questdlg(I.IndTrack(i).comment, "Comment trajectory?",'Yes','No', 'Stop','No');
        close(f1);
        if strcmp(resp1, 'Yes')
            %Loads and writes indtrack files
            %Segment_Blinded_Trajectories(i, Ind_path, Input_Params);
            I = load(Ind_path);

            ThreshN = inputdlg('Comment trajectory',['Traj. ' num2str(i)]);
            I.IndTrack(i).comment = ThreshN{1};

            IndTrack = I.IndTrack;
            Threshold_all = I.Threshold_all;
            save(Ind_path,'IndTrack','Threshold_all');
        elseif strcmp(resp1, 'Stop')
            disp(['Stopped at i = '  num2str(i)]);
            break
        end
    end
end

%% Section 2: Load the file saved from section1 
%         1. This section is to get the path and filename of the trajectories filtered in section1
%         2. The variable will be used in section3, don't clear the workspace until you finishe section3
%         3. Set up hyperparameters in this section as well for the next section



%addpath('Functions');
%disp('Input the pre-processed trace file (with IndTrack)');
%[filename, pathname] = uigetfile('.mat','input the pre-processed trace file (with IndTrack)');

file_check = load(Ind_path);
IndTrack = file_check.IndTrack;
disp(['There are ' num2str(length(IndTrack)) ' trajectories in the file']);
counter = 0;
for idxa = 1:length(IndTrack)
    if ~isempty(IndTrack(idxa).StateFit)
        counter = counter + 1;
        SegCheck(counter,1) = idxa;
    end
end
if exist('SegCheck','var')
   disp(['The most recently segmented trajectory is number ' num2str(SegCheck(end)) '.']);
end

%Detail experiment:
    % '2D_Tracking' for 2D SMT
    % '3D_Tracking' for 3D SMT
    % 'Nanopillar' for Nanopillar expeirment
Input_Params.Experiment = '2D_Tracking'; 

% set up some parameter2
Input_Params.PixelS = 100; % pixel size in nm
Input_Params.ExpT = 0.5; % time interval in second
Input_Params.TimeRange = [-10,250]; % the time range for trajectory ploting in sec ,better to have some space on both side
Input_Params.PosiXRang = [-500,500]; % the position range of short axis for plotting in nm
Input_Params.PosiYRang = [-200,200]; % the position range of short axis for plotting in nm
Input_Params.Nboot = 100; % number of the bootstrapping to get linear fitting
Input_Params.Pdrop = 0.1; %dropout probability in bootstrapping

% Load the simulated trajectories from section 1.
Input_Params.Simul_strucs = load(sim_path);

% if if_martin_is_in_lab
%     sim_path = '/Users/myepes/Xiao Lab Dropbox/Lab Members/McCausland_Josh/Projects/ZipA_Project/FtsA-FtsZ-Blinded/FtsA-FtsZ_500ms_sim.mat';
%     Input_Params.Simul_strucs = load(sim_path);
% else
%     disp('Select the simulated stationary trajectories');
%     [filenameSimu, pathnameSimu] = uigetfile('.mat','Select the simulated stationary trajectories');
% 
%     Input_Params.Simul_strucs = load([pathnameSimu filenameSimu]);
% end


%% Section 3: Iteratively segment all trajectories  
%         1. Change the first line from 1 to max number of the trajectories (showed in last section, or check the length of IndTrack)
%         2. The variable will be saved automatically. If you cannot finish all trajectories in a single time, don't worry. You can re-run section two and start from the next trajectories haven't processed by the last time.
%         3. The segmentation file wll also be saved by segment and named automatically.
%         4. functions required:
%                 a.  lognormalHistfit(I_all)
%                 b. [V, DisplXb, StDXb, RatioXb, NXb] = tracedropout(TimeT_TXY,TraceTx,Nboot,Pdrop)
%                 c. [R_V,R_0,Traj_V,Traj_0] = addVoneFLtrajs(Traj_struc,R_struc,Frame_L,frameL,TimeMatrix,V)
%                d. Prob = getProbR(R_sample,Bin,epsl)
Index = 752  % change this line from 1 to the max index of trajectories


Segment_Blinded_Trajectories(Index, Ind_path, Input_Params);

%% Iterate Quickly

for i = (Index+1):3316 
    Segment_Blinded_Trajectories(i, Ind_path,Input_Params);
    
    MartinsMonitors = get(0,'MonitorPositions');

    response = MFquestdlg([0.01+MartinsMonitors(1,2),0.05],'Continue?','Proceed to the next step?', 'Yes' ,'No','Yes');
    %response = questdlg(['Continue?'],'Proceed to the next step?','Yes','No','Yes');
    if strcmp(response,'No')
        disp(['i = '  num2str(i) ' (' num2str(100*i/length(IndTrack)) '%)']);
        break
    end
end

%% Import Comments to Indtrack file
clear; clc;
 
disp('Input the pre-processed trace file (with IndTrack)');
[Ind_filename, Ind_pathname] = uigetfile('.mat','input the pre-processed trace file (with IndTrack)');
Ind_path = fullfile(Ind_pathname, Ind_filename);
Ind_path_for_review = fullfile(Ind_pathname, ['R-' Ind_filename]);


disp('Input the comment file (matching IndTrack)');
[com_filename, com_pathname] =  uigetfile('.txt', 'input the text file with the comments');
com_path = fullfile(com_pathname, com_filename);

I = load(Ind_path);

C = readmatrix(com_path, Delimiter = '\t', OutputType = 'string');

for i = 1:length(I.IndTrack)
    I.IndTrack(i).comment = [];
end

for j = 1:length(C)
    j_rev = str2num(C(j, 1));
    j_com = C(j, 2);

    I.IndTrack(j_rev).comment = j_com;
end

IndTrack = I.IndTrack;
Threshold_all = I.Threshold_all;
save(Ind_path_for_review,'IndTrack','Threshold_all');

%% Review Trajs

disp('Input segmented traj. directory');
img_pathname =  uigetdir('Input segmented traj. directory');

I = load(Ind_path,'IndTrack','Threshold_all');

for i = 1:length(I.IndTrack)
    if ~isempty(I.IndTrack(i).comment) 
        period = find(I.IndTrack(i).file == '.');
        img_filename = ['Ind-' num2str(i) '-Str-' I.IndTrack(i).StrainName '-' I.IndTrack(i).file(1:8) '-' I.IndTrack(i).file(period-2:period-1) '-seg-' num2str(length(I.IndTrack(i).StateFit)) '.jpg'];
        img = imread(fullfile(img_pathname, img_filename));
        imshow(img, []);
        
        resp1 = questdlg(I.IndTrack(i).comment, "Resegment trajectory?",'Yes','No','Yes');
        if strcmp(resp1, 'Yes')

            %Loads and writes indtrack files
            Segment_Blinded_Trajectories(i, Ind_path, Input_Params);
        end
        resp2 = questdlg(I.IndTrack(i).comment, "Resolve comment and continue?",'Yes','No','Yes');
        if strcmp(resp2, 'Yes')

            %have to reload the file for changes to take effect
            I = load(Ind_path);
            I.IndTrack(i).comment = [];

            IndTrack = I.IndTrack;
            Threshold_all = I.Threshold_all;
            save(Ind_path,'IndTrack','Threshold_all');
        else
            disp(['Stopped at i = '  num2str(i)]);
            break
        end
    end
end

%M = readmatrix("/Users/myepes/Desktop/Josh_comments.txt", Delimiter = ' (', OutputType = 'string', Whitespace = '- ')

%review_list = M;

%comment_path = uigetfile();

%Input_Params.review_list = readmatrix(comment_path, Delimiter = '\t', OutputType = 'string');

% for j = 1:length(Input_Params.review_list)
% 
%     j_rev = str2num(Input_Params.review_list(j, 1));
% 
%     comment = Input_Params.review_list(j, 2);
% 
%     Input_Params.j = j;
% 
%     disp(comment);
% 
%     Segment_Blinded_Trajectories(j_rev,filename,pathname,Input_Params);
%     
%     MartinsMonitors = get(0,'MonitorPositions');
% 
%     response = MFquestdlg([0.01+MartinsMonitors(1,2),0.05],'Continue?','Proceed to the next step?', 'Yes' ,'No','Yes');
%     %response = questdlg(['Continue?'],'Proceed to the next step?','Yes','No','Yes');
%     if strcmp(response,'No')
%         disp(['Stopped at i = '  num2str(j_rev)]);
%         break
%     else
%         Input_Params.review_list(j) = [];
%     end
% end    

