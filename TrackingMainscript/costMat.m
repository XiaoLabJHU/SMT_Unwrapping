function [ Cmat ] = costMat( frame1, frame2, Zf, If )
% calculate the cost matrix between two paricular frames : frame1
% and frame2

% Method: for every spot in frame1, calculate the cost value to every spots
% in frame2. Find the closest one and assign the corresponding element in
% Gmat to 1, if the cost is smaller than the EdgeThreshold.

% input:
%       frame1 and frame2: the coordinates of all spots in a single frame
%                            column 1: x-coordinates
%                            column 2: y-coordinates
%                            column 3: z-coordinates
%                            column 4: spots intensity or other aspect as
%                            use defined



% Output:
%        Cmat: the cost matrix described in Sbalzarini,2005.No 0-1 or 1-0
%        elements will be patted .

% By Xinxing Yang@Xiaolab 20160630

if nargin < 4
    If = 0;
    if nargin <3
        Zf = 1;
    end
end

if size(frame1,2) < 4 | size(frame2,2) < 4
    error('the format of frame data is incorrect');
end
%
% construct the empty Gmat
L1 = size(frame1,1);
L2 = size(frame2,1);

% calculate the cost value 

for ii = 1 : L1
    for jj = 1 : L2
        costV(ii, jj) = costPairwise(frame1(ii,:),frame2(jj,:),Zf,If);
    end
end

Cmat = costV;

end

