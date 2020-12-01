function Two_Color_Image_Align(filename_s,pathname_s,filename_c,pathname_c)
    [optimizer,metric] = imregconfig('monomodal'); % monomodal require similar contrast, so there will be scaling later
    optimizer.MaximumStepLength = 0.01; 
    optimizer.MaximumIterations = 200;
    Image_S = imread([pathname_s filename_s]);
    Image_C = imread([pathname_c filename_c]);
    
    %calculate the transformation matrix
    [movingReg,tform_2C] = imregister2(imadjust(Image_C),imadjust(Image_S),'affine',optimizer,metric);
    save('Bead_Alignment.mat','tform_2C');
    
    %Align the image to standard.
    Image_R = imread([pathname_c filename_c]);
    Image_Cali = imwarp2(Image_R,tform_2C);
    imwrite(Image_Cali,'488_Aligned.tif');
end