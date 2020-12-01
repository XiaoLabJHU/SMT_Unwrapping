%% Nanopillar Pre-Processing. 
% Nanopillar experiments are completed with a two-channel imaging setup.
% This workflow it built to prepare the images for ThunderSTORM and
% downstread analysis, including sections to crop and align the channels. 

%% Section 1. Creating a crop matrix.
%If you have a single TIF image with more than one channel, it must be
%cropped and separated first. Take your bead stack and select the channels
%for cropping. It will generate one matrix to apply a crop for all images.
%This function is written to display 488 and 647 as the channels.
clear;
clc;
[filename pathname] = uigetfile('.tif','Select the Bead Calibration file');
Two_Channel_Crop(filename,pathname);

%% Section 2. Crop all multi-channel images with the crop matrix generated from bead ROIs. 
clear;
clc;

%Load the Channel Crop mat structure.
load('Channel_Crop.mat');

%Select every TIF file in current directory to crop and separate channels.
%Our naming format is Cell-NAME-XX.tif. Name is 'BF', or 'JF646'. 'XX' is
%the image number. 'Cell' acts as the handle for Matlab to find.
files_Cell = dir('Cell*');

%Crop all files. Input the channel where the BF is as 'top' or 'bottom'.
crop_files(files_cell,'top');

%% Section 3. Align the two channels using the cropped bead images. 
%Select the standard channel and the channel assigned for alignment. The
%standard channel for Nanopillars is 647, the single molecule channel. We
%will align the GFP-ZapA images (488) to 647. This will allow the ring fits
%to accurately capture the circle the trajectories will run on.
[filename_s pathname_s] = uigetfile('.tif','Select the standard image');
[filename_c pathname_c] = uigetfile('.tif','Select the calibration image');
Two_Color_Image_Align(filename_s,pathname_s,filename_c,pathname_c);

%% Section 4. Align BF and GFP channels using the Bead_Alignment matrix.
% I align the output from Pure_Denoise-applied GFP files. Run that plugin
% first before running this section. 
clear;
clc;
files_BF = dir('BF*');
files_488 = dir('Denoised*');
load('Bead_Alignment.mat');
Align_Brightfield_Images(files_BF,tform_2C);
Align_GFP_Images(files_488,tform_2C);


%% Section 5. Fit the ZapA-GFP ring to a circle. Do this after TraceRefine.
%REQUIRES PLUGINS: 'FREEZECOLORS' AND 'CIRCLE FIT (PRATT METHOD)'
clear;
clc;

[TRfilename TRpathname] = uigetfile('.mat', 'Select the TraceRefine files','multiselect','on');
[BFfilename BFpathname] = uigetfile('.tif','Select ALL BF files','multiselect','on');
[GFPfilename, GFPpathname] = uigetfile('.tif','Select ALL GFP files','multiselect','on');

% Custom script to fit a circle.
Fit_to_a_Circle(TRfilename, TRpathname, BFfilename, BFpathname, GFPfilename, GFPpathname);