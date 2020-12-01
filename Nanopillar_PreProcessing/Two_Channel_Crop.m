function Two_Channel_Crop(filename,pathname);
    %Assumes the two channels are vertically oriented.
    %Make a max-intenisty projection of the bead stack.
    projection = Maximum_Projection(pathname,filename);
    imshow(mat2gray(projection));
    disp('Select the 488 channel.');
    u = drawrectangle('Label','488','Color',[0.1328125,0.54296875,0.1328125]);
    rec_488 = u.Position;
    disp('Select the 647 channel.');
    v = drawrectangle('Label','647','Color',[0.6953125,0.1328125,0.1328125]);
    rec_647 = v.Position;

    %Make sure the two rectangles have even dimensions
    rec_488(4) = round(rec_488(4));
    rec_647 = [rec_488(1) rec_647(2) rec_488(3:4)];
    
    %Create cropped images from the projection.
    I1 = uint16(imcrop(projection,rec_488));
    I2 = uint16(imcrop(projection,rec_647));
    
    %Save the cropped images.
    imwrite(I1,'488-Crop.tif');
    imwrite(I2,'647-Crop.tif');

    %Create the cropping matrix and save it..
    Channel_Crop(1,:) = rec_488;
    Channel_Crop(2,:) = rec_647;
    save('Channel_Crop.mat','Channel_Crop');
end