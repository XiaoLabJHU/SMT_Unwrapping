function [ phi12] = costPairwise( Coord1, Coord2, Zf, If)
%   Calculate the pair wise cost value of two individule spots
%   Function Description:
%   The cost function is like:
%   phi = (x1-x2)^2 + (y1-y2)^2 + Zf(z1-z2)^2 + If(I1-I2)^2;

%   The coordinates use pixel as unit.

%   input: 
%         Coord1 and Coord2: The coordinates of the two spots(1 and 2) with
%                            column 1: x-coordinates
%                            column 2: y-coordinates
%                            column 3: z-coordinates
%                            column 4: spots intensity or other aspect as
%                            use defined
%         fill the columns with zero is no intenisty or Z information is
%         needed.

%         Zf: the weight of z-coordinates. When Z accuracy is lower, Zf<1
%         and when it is higher, Zf>1. The default value is 1.

%         If: the weight of intensity. This is for normalize the effect of
%         intensity. One way is to set the If = 1/<I>^2. The default value is 0.


%   output:
%         phi12 the cost value of the two spots for future minimization

%   By Xinxing Yang @ Xiaolab 20160630

if nargin < 4
    If = 0;
    if nargin < 3
        Zf = 1;
    end
end

if nargin < 2
    error('Please input at least two coordinats');
end

if length(Coord1) < 4 | length(Coord2) < 4
    error('Please make sure the coordinates contain four columns');
end

% sqaure of diference 
Dif_V = (Coord1-Coord2).^2;
Dif_V(:,3) = Zf * Dif_V(:,3);
Dif_V(:,4) = If * Dif_V(:,4);

phi12 =sum(Dif_V);

end

