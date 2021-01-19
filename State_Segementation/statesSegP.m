% This is a code for single molecule trajectories segmentation
% Mainly built for molecules in bacteria
% Current version deals with divisome proteins: 
%                 X-axis: short axis of the cell, Y-axis: long axis of the cell
%          3. The diffusion model is confined diffusion with or without processive movement
%          4. The code should be run block by block with the instructions 
% By Xinxing Yang from Dr. Jie Xiao lab  
%          version1: 2020514
%% Section 0: simulate a set of trajectories with a certain boundary and diffusion coeff 
%         1.This is not a neccessary step for every experiment. As long as the boundary does not change too much, you can use the same file generated in this step for other experiments.
%         2. A way to verify your simulation is to calculate the MSD of your stationary molecules in the end (section X). If the boundary and D are not so different from your setting here, it should be okay.
%         3. In this simulation,we consider the velocity = 0.
% Set the hyperparameters for your simulation, simulate, and save the file
clear; clc;
Frame_L = [5:400]; % the range of the possible trajectory length
ExpT = 1; % the exposure time (if there is dark interval, this should be total time interval)
D = 0.0005; % diffusion coefficient: in um^2/s
B = 200; % boundary size  in nm
L_err = 15; % localization error in nm
N_traj = 2000; % number of trajectories for simulation in one condition
filenameSimu = 'FileName.mat'; % filename to save the simulation result
% simulation
[R_struc,Traj_struc,TimeMatrix,frameMatrix,SpeedMatrix] = rcdfCal(Frame_L,0,ExpT,D,B,L_err,N_traj);
save(filenameSimu,'R_struc','Traj_struc','TimeMatrix','frameMatrix','SpeedMatrix','Frame_L');
%% Section 1: refine the trajectories using intensity and calculate the noise level in both x and y 
%         1.This is the real start of segmentation: combine multiply files from different movie and remove high intensity frames
%         2. this section will generate a matrix called IndTrack (with individule traces) and StatMat (with statistics of intensity and displacement) requires following funtions in path:
%         3. functions required:
%                 a.  Refine_Trajectories
%                 b.  lognormalHistfit(I_all)
%                 c.  MSDcalculate_1d(strucD,PixelS,ExpT,0,1,'all');
%                 d.  kusumi_xy(msd_x);
%                 e.  intensityFilter(Trace,Threshold_I);
%                 f.  colorCodeTracePlot(Time,Trace,linewidth)
%                 g.  linfitR(Time,Trace)
%                 h.  tracedropout(Time,Trace,Nboot,pdrop)
clear; clc;
%Detail experiment:
    % '2D_Tracking' for 2D SMT
    % '3D_Tracking' for 3D SMT
    % 'Nanopillar' for Nanopillar experiment
Experiment = '2D_Tracking'; 
ExpT = 0.5; % timeinterval in second
PixelS = 81.25; % pixel size in nm
ThreshT = 10; % the threshold of trajectory length. Only select the trajectories longer than this
[filenameIn pathname] = uigetfile('.mat','input the unwrapped trajectory files','multiselect','on');

Refine_Trajectories(filenameIn,pathname,Experiment,ExpT,PixelS,ThreshT);

%% Section 2: Load the file saved from section1 
%         1. This section is to get the path and filename of the trajectories filtered in section1
%         2. The variable will be used in section3, don't clear the workspace until you finishe section3
%         3. Set up hyperparameters in this section as well for the next section
clear; clc;
[filename pathname] = uigetfile('.mat','input the pre-processed trace file (with IndTrack)');
file_check = load([pathname filename]);
display(['There are ' num2str(length(file_check.IndTrack)) ' trajectories in the file']);

%Detail experiment:
    % '2D_Tracking' for 2D SMT
    % '3D_Tracking' for 3D SMT
    % 'Nanopillar' for Nanopillar expeirment
Input_Params.Experiment = '2D_Tracking'; 

% set up some parameter2
Input_Params.PixelS = 81.25; % pixel size in nm
Input_Params.ExpT = 1; % time interval in second
Input_Params.TimeRange = [-10,400]; % the time range for trajectory ploting in sec ,better to have some space on both side
Input_Params.PosiXRang = [-500,500]; % the position range of short axis for plotting in nm
Input_Params.PosiYRang = [-200,200]; % the position range of short axis for plotting in nm
Input_Params.Nboot = 100; % number of the bootstrapping to get linear fitting
Input_Params.Pdrop = 0.1; %dropout probability in bootstrapping

% Load the simulated trajectories from section 1.
[filenameSimu pathnameSimu] = uigetfile('.mat','Select the simulated stationary trajectories');
Input_Params.Simul_strucs = load([pathnameSimu filenameSimu]);
%% Section 3: Iteratively segment all trajectories  
%         1. Change the first line from 1 to max number of the trajectories (showed in last section, or check the length of IndTrack)
%         2. The variable will be saved automatically. If you cannot finish all trajectories in a single time, don't worry. You can re-run section two and start from the next trajectories haven't processed by the last time.
%         3. The segmentation file wll also be saved by segment and named automatically.
%         4. functions required:
%                 a.  lognormalHistfit(I_all)
%                 b. [V, DisplXb, StDXb, RatioXb, NXb] = tracedropout(TimeT_TXY,TraceTx,Nboot,Pdrop)
%                 c. [R_V,R_0,Traj_V,Traj_0] = addVoneFLtrajs(Traj_struc,R_struc,Frame_L,frameL,TimeMatrix,V)
%                 d. Prob = getProbR(R_sample,Bin,epsl)
Index = 9% change this line from 1 to the max index of trajectories

Segment_Trajectories(Index,filename,pathname,Input_Params);
