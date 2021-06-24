function crop_files(files,BF_Channel);
    load('Channel_Crop.mat');
    f = waitbar(0,'Please wait...');
    WBpos = get(f,'Position');
    for qq = 1:length(files);
        waitbar(qq/length(files),f,...
        ['At image ' num2str(qq) ' of ' num2str(length(files))]);

        file_curr = files(qq).name;
        I_info = imfinfo(file_curr);
        name = file_curr(6:find(file_curr == '.')-4); %%Assumes filename is 'Cell-NAME-XX.tif
        file_num = file_curr(end-5:end-4);   

        if length(I_info) > 1
            ff = waitbar(0,'Please wait...','Position',[WBpos(1) WBpos(2)-(WBpos(4)*1.5) WBpos(3) WBpos(4)]);
            for ii = 1:length(I_info)
                waitbar(ii/length(I_info),ff,...
                    ['At slice ' num2str(ii) ' of ' num2str(length(I_info))]);
                I_temp = imread(file_curr,ii);
                I_temp_488 = imcrop(I_temp,Channel_Crop(1,:));
                I_temp_647 = imcrop(I_temp,Channel_Crop(2,:));
                if strcmp(name,'JF646');
                    imwrite(I_temp_488,['488-' num2str(file_num) '.tif'],'WriteMode','Append');
                    imwrite(I_temp_647,['646-' num2str(file_num) '.tif'],'WriteMode','Append');
                else
                    imwrite(I_temp_647,[name '-' num2str(file_num) '.tif'],'WriteMode','Append');
                end
            end
            close(ff);
        elseif strcmp('top',BF_Channel);
            I_temp = imread(file_curr);
            I_temp_647 = imcrop(I_temp,Channel_Crop(2,:));
            imwrite(I_temp_647,[name '_Crop-' num2str(file_num) '.tif']);
        elseif strcmp('bottom',BF_Channel);
            I_temp = imread(file_curr);
            I_temp_488 = imcrop(I_temp,Channel_Crop(1,:));
            imwrite(I_temp_647,[name '_Crop-' num2str(file_num) '.tif']);
        end
    end

    close(f);
end