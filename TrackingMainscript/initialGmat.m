function [ Gmat ] = initialGmat( frame1, frame2, EdgeThresh )
% produce a initial association matrix for two paricular frames : frame1
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

% (the cost function here does not consider the Z weight and I weight(Zf and
% If in function costPairwise)

%      EdgeThresh: the spatial threshold to remove all the un reasonable
%      linkage. The rL^2 value in Sbalzarini,2005)

% Output:
%        Gmat: the association matrix described in Sbalzarini,2005.

% By Xinxing Yang@Xiaolab 20160703

if nargin < 3
    error('Input enough variables: frame1, frame2 and edgethreshold');
end

if size(frame1,2) < 4 | size(frame2,2) < 4
    error('the format of frame data is incorrect');
end

% construct the empty Gmat
L1 = size(frame1,1);
L2 = size(frame2,1);
Gmat = zeros(L1+1, L2+1);

% calculate the cost value 

costV = costMat( frame1, frame2);

% set the elements bigger than threshold to be inf

costV(costV > EdgeThresh) = inf;

% find the minimum of the rows one by one

for ii = 1 : L1
    RowTemp = costV(ii,:);
    MinTemp = min(RowTemp);
    if MinTemp(1) == Inf
        Gmat(ii+1,1) = 1;
    else
        index = find(RowTemp == MinTemp);
        Gmat(ii+1,index(1)+1) = 1;
        costV(:,index(1)) = Inf;
    end
end

% check the columns of Gmat

for kk =  2: L2 + 1
    if sum(Gmat(2:L1+1,kk)) == 0
        Gmat(1,kk) = 1;
    end
end

end

