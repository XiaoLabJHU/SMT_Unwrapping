%% Tracking Main Scipt.
%This workflow has the main functions that all members of our lab use to
%link spots, refine trajectories, and other steps necessary for
%pre-processing. Some minor differentiations regard cropping and aliging
%channels. 

%Each section is labeled for its purpose. Run these in order.

%% Section 1. Link all the spots and generate .mat files from ThunderSTORM outputs. 

spotsLinking

%% Section 2: Identify trajectories by manually inspecting the data over a brightfield image.

TraceRefineExpress

%% Section 3. Rotate cells with trajectories such that they are entirely vertical.
% Do not use for nanopillar experiments.
Z = 0 %Put 1 if using 3D, or 0 if using 2D.
if Z; RegionCrop_unwrap3D
else; RegionCrop_unwrap
end
%% Section 3. This is for nanopillars only. 
%Fit the ZapA-GFP ring to a circle. Do this after TraceRefine.
%REQUIRES PLUGINS: 'FREEZECOLORS' AND 'CIRCLE FIT (PRATT METHOD)'
clear;
clc;

[TRfilename TRpathname] = uigetfile('.mat', 'Select the TraceRefine files','multiselect','on');
[BFfilename BFpathname] = uigetfile('.tif','Select ALL BF files','multiselect','on');
[GFPfilename, GFPpathname] = uigetfile('.tif','Select ALL GFP files','multiselect','on');

% Custom script to fit a circle.
Fit_to_a_Circle(TRfilename, TRpathname, BFfilename, BFpathname, GFPfilename, GFPpathname);