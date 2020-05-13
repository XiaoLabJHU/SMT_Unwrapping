function [ GMatnew, Zij, flag ] = redCost( GMat, CMat, In, Jn )
% Calculate the reduced cost if rset the (i,j) of Gmat to be 1, update the
% Gmat if zij < 0

% Method: the reduced cost means the cost change if we switch the (i,j) of
% the Gmax to 1, which will also casue one or two other element in Gmat to
% 0 and one element to 1. 


% input:
%       GMat: the original association matrix 
%       CMat: the cost matrix from costMat, thresholded already
%       In and Jn: the new spots linkage 


% Output:
%        GMatnew: updated association matrix
%        Zij: the reduced cost after switching
%        flag: the flag to check whether the switch is done. 1 or 0


% By Xinxing Yang@Xiaolab 20160703

if nargin < 4
    error('Input enough variables: Gmat, Cmat and i,j');
end
% assigan the initial value for the outputs
%%
flag = 0;
Zij = 0;
GMatnew = GMat;


if In == 1 & Jn ~=1 & GMat(In,Jn) == 0 % the target element is in the first row
        TempCol = GMat(:,Jn);
        Ln = find(TempCol == 1);
        Zij = CMat(1,Jn) - CMat(Ln,Jn) + CMat(Ln,1);
        if Zij < 0
            flag = 1;
            GMatnew(1, Jn) = 1;
            GMatnew(Ln, Jn) = 0;
            GMatnew(Ln, 1) = 1;
        end
end

if In ~= 1 & Jn ==1 & GMat(In,Jn) == 0 % the target element is in the first column
        TempRow = GMat(In,:);
        Kn = find(TempRow ==1);
        Zij = CMat(In,1) - CMat(In,Kn) + CMat(1,Kn);
        if Zij < 0
            flag = 1;
            GMatnew(In,1) = 1;
            GMatnew(In,Kn) = 0;
            GMatnew(1,Kn) = 1;
        end
end

if In ~= 1 & Jn ~=1 & GMat(In,Jn) == 0 % the target element is in middle
        TempCol = GMat(:,Jn);    
        TempRow = GMat(In,:);
        Ln = find(TempCol ==1);
        Kn = find(TempRow ==1);
        Zij = CMat(In,Jn) + CMat(Ln,Kn) - CMat(In,Kn) - CMat(Ln,Jn);
        if Zij < 0
            flag = 1;
            GMatnew(In,Jn) = 1;
            GMatnew(In,Kn) = 0;
            GMatnew(Ln,Kn) = 1;
            GMatnew(Ln,Jn) = 0;
        end
end
    
end

