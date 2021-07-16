if exist('ROOT_dir', 'var') == 0
    ROOT_dir = uigetdir([],'Choose main data folder');
    BF_dir = uigetdir(ROOT_dir, 'Choose brightfield image folder');
    DFT_dir = uigetdir(ROOT_dir, 'Choose drift image folder');
    COOR_dir = uigetdir(ROOT_dir, 'Choose unrefined tracjectory folder');
    cd(BF_dir);
    BF_imgs = dir('*.tif');
    cd(DFT_dir);
    DFT_imgs = dir('*.tif');
    cd(COOR_dir);
    COOR_files = dir('*.mat');
    num_imgs = length(BF_imgs);
end
    
for i = 1:num_imgs
%cd(BF_folder);
BF_name = BF_imgs(i).name;
BF_tag = BF_name(end-5:end-4);
BF_path = [BF_dir '\' BF_name];
BF = imread(BF_path, 'tif');

DFT_name = DFT_imgs(i).name;
DFT_tag = DFT_name(end-5:end-4);
DFT_path = [DFT_dir '\' DFT_name];
DFT = imread(DFT_path, 'tif');

disp(BF_tag);

COOR_name = COOR_files(i).name;
COOR_tag = DFT_name(end-5:end-4);
COOR_path = [COOR_dir '\' COOR_name];
COOR = load(COOR_path);

%handles.trackFinal= COOR.tracksFinal;

%load traces here

if ~strcmp(BF_tag, DFT_tag)
    disp('Tags do not match');
end

plt_BF = imshow(BF, []);
hold on
plt_DFT = imshow(DFT);
plt_DFT.Visible = 'off';
%hold off

%display traces here
pause(0.2);

%hold on
pxSize = 100;
for idxT=1:length(COOR.tracksFinal)
    % load the current frame info
    Track = COOR.tracksFinal(idxT).Coord;
    % rescale the unit
    Track(:,2:4) = Track(:,2:4)/pxSize;
    Tracksnew(idxT).Coordinates = Track; 
    Tracksnew(idxT).Index=idxT;% the index from the original structure
    Intens(idxT) = mean(Track(:,5));
    % plot all the traces
    plot(Track(:,2),Track(:,3),'- .' , 'LineWidth',0.5,'MarkerSize',5);
end
hold off

pause(0.2);
plt_DFT.Visible = 'on';
hold on
plt_BF.Visible = 'off';
hold off
pause(0.2);
plt_BF.Visible = 'on';
plt_DFT.Visible = 'off';
hold off
pause(0.2);
end
