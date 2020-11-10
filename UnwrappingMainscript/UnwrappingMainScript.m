%% Unwrapping Main Script
%% Section 1. Unwrap trajectories from 3D single molecule tracking. 
clear; clc;
[filename pathname] = uigetfile('.mat','input the unwrapped trajectory files','multiselect','on');
Unwrap_3DSMT(filename,pathname);

%% Section 2. Unwrap Nanopillar Experiment Results.
% Requires CircleFits structure and raw tracerefine files.
% Go to main directory with CircleFits and tracefine files. Directory named
% such that ~/YYYYMMDD-STRAIN/Unwrap. 
clear; clc;
load('CircleFits.mat');
Exposure_Time = 0.5;
Dark_Time = 0.5;
px_size = 100;
FileSaveName = 'JM151';
Nanopillar_Unwrap(CircleFits,Exposure_Time,Dark_Time,px_size,FileSaveName);

