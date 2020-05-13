function [ TrajList ] = closeLink(Spots)

%   Close the gap from the Spots structure and produce a list with all the
%   trajectories one by one
% 

% input:
%       Spots: the coordinates list of all spots 
%              each .Coord is the coordinates of all the spots in that
%              frame
%              column 1: spot id (unique for every spot in the frame)
%              column 2: y-coordinates
%              column 3: y-coordinates
%              column 4: z-coordinates
%              column 5: spots intensity or other aspect as use defined
%              column 6: the previous frame linked to this spot, 0 means no
%              linkage now.
%              column 7: the spot id in the previous frame linked to this spot, 0 means no
%              linkage now.
%              column 8: the next frame linked to this spot, 0 means no
%              linkage now.
%              column 9: the spot id in the previous frame linked to this spot, 0 means no
%              linkage now.          

% Output:
%        TrajList: A list with all the trajectories.
%              column 1: traj id 
%              column 2: frame id
%              column 3: spot id
%              column 4: x-coordinates
%              column 5: y-coordinates
%              column 6: z-coordinates
%              column 7: spots intensity or other aspect as use defined
%              column 8: the previous frame linked to this spot, 0 means no
%              linkage now.
%              column 9: the spot id in the previous frame linked to this spot, 0 means no
%              linkage now.
%              column 10: the next frame linked to this spot, 0 means no
%              linkage now.
%              column 11: the spot id in the previous frame linked to this spot, 0 means no
%              linkage now.  

% By Xinxing Yang@Xiaolab 20160704

%% reconstruct a matrix from Spot to contain all spots
Traj = [];
for ii = 1: length(Spots)
    CoordTraj = [];
    [Cy Cx] = size(Spots(ii).Coord);
    CoordTraj(1:Cy,3:11) = Spots(ii).Coord;
    CoordTraj(1:Cy,2) = ii; % the second column is the frame number
    % the first column is node of trajectory, 0 means not included in any
    % trajectory yet
    Traj = [Traj;CoordTraj];
end

% link the spots one by one
kk = 1; %counter of trajectorie
for ii = 1 : size(Traj,1)
    CoordTempTraj = Traj(ii,:); % the current spot
    if CoordTempTraj(1) == 0
        % check no spot is missed in previous steps
        if CoordTempTraj(8) ~=0
            error(['spots_' num2str(ii) ' is linked to pervious spots but identified correctly.']);
        end
        
        trajNode = kk;
        kk = kk + 1;
        traEnd = 0; % indicator of the ending of one trajectory, 1 means the current trajectory is ended.
        traCurr = ii; % the current spot position in the Traj matrix
        Traj(traCurr,1) = trajNode;
        while traEnd == 0
           if CoordTempTraj(10) == 0
                traEnd = 1;
           else
                Nextframe = CoordTempTraj(10);
                Nextid = CoordTempTraj(11);
                Nextline = find(Traj(:,2)== Nextframe & Traj(:,3)== Nextid);
                CoordTempTraj = Traj(Nextline,:); % update the current spot
                Traj(Nextline,1) = trajNode;
            end
        end
    end
end

TrajList = Traj;
end

