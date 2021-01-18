function [ Coord_unwrap ] = unwrapTraj( Center, R, Coord_2d )
%unwrapTraj convert a x-y trace in 3D spatce to a x-y trace on 2D cylinder
%surface
%   if X excess R, R = X
% the curved surface  is aligned in x-z plane
% input Coord should be x, and y
% output is a new x y  coordinates the center is located at [0,0]
%%
Xc = Center(1);
Yc = Center(2);

% Coord = Coord_2d; % x-y coordinates of the trace
Coord(2) = Coord_2d(2) - Yc; % y is from direct translation
DisX = abs(Coord_2d(1) - Xc); % distance between X and the center

if DisX > R % keep the far points at their original position
    R = DisX;
end

Xnew = R*asin(DisX/R);
if Coord_2d(1) - Xc >= 0
    Coord(1) =  Xnew;
else
    Coord(1) =  - Xnew;
end

Coord_unwrap = Coord;

end