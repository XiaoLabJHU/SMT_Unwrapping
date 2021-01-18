function [ Coord_rot] = coord2dRot( Coord,Center,Angle)
%   coord2dRot rotate a pair of data points(x and y) by the angle refering
%   to the center points Center
%   Input: Coord : X and Y coordinates of a point
%          Center: X and Y coordinates where the rotation centered at
%          Angle: degree of counter-clock wise rotation
%   Output: Coord_rot: the rotated coordinates in the original frame

% translate the coords centering to the reference point
Coord_temp = Coord - Center;
% rotate the Coordinates
Drg = Angle/180*pi;
Coord_temp_rot(1) = Coord_temp(1)*cos(Drg) - Coord_temp(2)*sin(Drg);
Coord_temp_rot(2) = Coord_temp(1)*sin(Drg) + Coord_temp(2)*cos(Drg);
% translate back to the orginal frame
Coord_rot = Coord_temp_rot + Center;
end

