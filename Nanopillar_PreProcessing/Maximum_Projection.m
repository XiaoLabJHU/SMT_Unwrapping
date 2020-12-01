function [projection mean_intensity] = Maximum_Projection(pathname, filename);


gfp_info = imfinfo([pathname filename]);
num_images = numel(gfp_info);

for insde = 1:num_images;
    data_temp{insde} = imread([pathname filename],insde);
end

pxs=zeros(num_images,1);
for y = 1:size(data_temp{1},1)
    for x = 1:size(data_temp{2},2)
        for Zstack = 1:num_images;
            I = data_temp{Zstack};
            pxs(Zstack) = I(y,x);
        end
        projection(y,x) = max(pxs);
        mean_intensity(y,x) = mean(pxs);
    end
end
end