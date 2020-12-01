function Align_Brightfield_Images(files,tform_2C,varargin)
for qq = 1:length(files);
    file_curr = files(qq).name;
    file_root = file_curr(1:find(file_curr=='.')-1);
    file_num = file_root(end-1:end);   
    Image_R = imread(file_curr);
    minI = min(Image_R(:));
    Image_Cali = imwarp2(Image_R,tform_2C);
    Image_Cali(Image_Cali == 0) = minI;
    imwrite(Image_Cali,['BF-' file_num '.tif']);
end
end