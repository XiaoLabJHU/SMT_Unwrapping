function Align_GFP_Images(files,tform_2C);
    f = waitbar(0,'Please wait...');
    WBpos = get(f,'Position');
    for idx = 1:length(files);
        waitbar(idx/length(files),f,...
            ['At image ' num2str(idx) ' of ' num2str(length(files))]);
        file_curr = files(idx).name;
        file_info = imfinfo(file_curr);
        file_root = file_curr(1:find(file_curr=='.')-1);
        file_num = file_root(end-1:end);
        projection_gfp = Maximum_Projection([files(idx).folder '\'],file_curr);
        gfp = uint16(projection_gfp);
        minG = min(gfp(:));
        gfp_cali = imwarp2(gfp,tform_2C);
        gfp_cali(gfp_cali == 0) = minG;
        imwrite(gfp_cali,[file_root(1:end-3) '_Align-' file_num '.tif']);
    end
    close(f);
end