handles.pxSize = 100;
handles.drift = 0;

%if exist('ROOT_dir', 'var') == 0
if ~isfield(handles, 'ROOT_dir')
    handles.ROOT_dir = uigetdir([],'Choose main data folder');
    handles.BF_dir = uigetdir(handles.ROOT_dir, 'Choose brightfield image folder');
    handles.DFT_dir = uigetdir(handles.ROOT_dir, 'Choose drift image folder');
    handles.COOR_dir = uigetdir(handles.ROOT_dir, 'Choose unrefined tracjectory folder');
    cd(handles.BF_dir);
    handles.BF_files = dir('*.tif');
    cd(handles.DFT_dir);
    handles.DFT_files = dir('*.tif');
    cd(handles.COOR_dir);
    handles.COOR_files = dir('*.mat');
    cd(handles.ROOT_dir);
    num_imgs = length(handles.BF_files);
end

num_imgs = 60;

for i = 1:num_imgs
    
handles = load_data_at_index(handles, i);

handles = refresh_plot(handles);
pause(0.5);

hold on
Intens = [];
Tracksnew = [];
TF = handles.COOR.tracksFinal;
for idxT=1:length(TF)
    % load the current frame info
    Track = TF(idxT).Coord;
    % rescale the unit
    Track(:,2:4) = Track(:,2:4)/handles.pxSize;
    Tracksnew(idxT).Coordinates = Track; 
    Tracksnew(idxT).Index=idxT;% the index from the original structure
    Intens(idxT) = mean(Track(:,5));
    % plot all the traces
    plot(Track(:,2),Track(:,3),'- .' , 'LineWidth',0.5,'MarkerSize',5);
end
hold off
handles.Tracksnew=Tracksnew;
handles.Intens=Intens;
handles.TracksRefine=Tracksnew;
disp('Loaded');
pause(0.4);


%refine

[N, edges] = histcounts(Intens,20);
disp(length(edges));
I_peak = edges((N == max(N)));
I_peak = I_peak(1);
disp(I_peak);
I_min = min(Intens);
I_max = max(Intens);

disp(['Min: ' string(I_min) 'Peak ' string(I_peak) 'Max ' string(I_max)]);
cutoff = 200;

handles = refresh_plot(handles);
pause(0.4);

hold on
cst=1;
handles.TracksRefine=[];
for ii=1:length(handles.Tracksnew)
    Track=handles.Tracksnew(ii).Coordinates;
    if handles.Intens(ii)>I_min & handles.Intens(ii)<cutoff
        TracksRefine(cst,1).Coordinates=Track;
        TracksRefine(cst,1).Index=Tracksnew(ii).Index;
        cst=cst+1;
        plot(Track(:,2),Track(:,3),'- .' , 'LineWidth',0.5,'MarkerSize',5);
    end
end
hold off

disp('Refined');

handles = toggle_drift(handles);
pause(0.5);
handles = toggle_drift(handles);
pause(0.5);

end

function handles = load_data_at_index(handles, i)

BF_name = handles.BF_files(i).name;
BF_tag = BF_name(end-5:end-4);
BF_path = [handles.BF_dir '\' BF_name];
handles.BF_img = imread(BF_path, 'tif');

DFT_name = handles.DFT_files(i).name;
DFT_tag = DFT_name(end-5:end-4);
DFT_path = [handles.DFT_dir '\' DFT_name];
handles.DFT_img = imread(DFT_path, 'tif');

disp(BF_tag);

COOR_name = handles.COOR_files(i).name;
COOR_tag = DFT_name(end-5:end-4);
COOR_path = [handles.COOR_dir '\' COOR_name];
handles.COOR = load(COOR_path);

% if ~strcmp(BF_tag, DFT_tag)
%     disp('Tags do not match');
% end

end

function handles = refresh_plot(handles)
handles.plt_BF = imshow(handles.BF_img, []);
%handles.plt_BF.Visible = 'off';
hold on
handles.plt_DFT = imshow(handles.DFT_img);
handles.plt_DFT.Visible = 'off';

if handles.drift == 1
    handles.plt_DFT.Visible = 'on';
else
    handles.plt_BF.Visible = 'on';
end
hold off

end

function handles = toggle_drift(handles)
hold on
if handles.drift == 1
    handles.plt_DFT.Visible = 'on';
    handles.plt_BF.Visible = 'off';
    handles.drift = 0;
else
    handles.plt_BF.Visible = 'on';
    handles.plt_DFT.Visible = 'off';
    handles.drift = 1;
end
hold off
end
