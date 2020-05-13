function [ CmatT ] = costMatThresh(Cmat,EdgeThresh)
% Thresholding the cost matrix by a given threshold EdgeThresh

% Method: All the elements larger than T will be set to Inf pat a column
% and row with the threshold T

% input:
%       Cmat: the cost matrix from costMat


% Output:
%        CmatT: the cost matrix described in Sbalzarini,2005 with Inf, 0-1
%        and 1-0 elements

%      EdgeThresh: the spatial threshold to remove all the un reasonable
%      linkage. The rL^2 value in Sbalzarini,2005)

% By Xinxing Yang@Xiaolab 20160703

if nargin < 2
    error('Please input the threshold.');
end

[Row Col] = size(Cmat);

Cmat(find(Cmat > EdgeThresh)) = Inf;

Trow = ones(1,Col) * EdgeThresh;
Tcol = ones(Row + 1,1) * EdgeThresh;

CmatT = [Trow; Cmat];
CmatT = [Tcol, CmatT];

end

