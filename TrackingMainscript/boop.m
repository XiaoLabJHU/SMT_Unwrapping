datafolder = uigetdir([],'Choose main data folder');
BF_folder = uigetdir(datafolder, 'Choose brightfield image folder');
drift_folder = uigetdir(datafolder, 'Choose drift image folder');
cd(BF_folder);
BF_imgs = dir('*.tif');
cd(drift_folder);
drift_imgs = dir('*.tif');

for i = 1:60
cd(BF_folder);
BF_name = BF_imgs(i).name;
BF = imread(BF_name, 'tif');
%tag = extractBefore(BF_name, '.');
%tag = extractAfter(tag,);
tag1 = BF_name(end-5:end-4);
cd(drift_folder);
drift_name = drift_imgs(i).name;
drift = imread(drift_name, 'tif');
tag2 = drift_name(end-5:end-4);
if ~strcmp(tag1, tag2)
    disp('Tags do not match');
end
imshow(BF, []);
pause(0.5);
imshow(drift, []);
pause(0.5);
end
