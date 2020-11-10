function [R_V,R_0,Traj_V,Traj_0] = addVoneFLtrajs(Traj_struc,R_struc,Frame_L,frameL,TimeMatrix,V)
%addVoneFLtrajs find out the set of trjactories simulated from rcdfCal (V =
%0)
%function with a certain length frameL. Then add a speed V on each one to
%generate a new set of trajectories for further calculation
% Arguments: Traj_struc, Frame_L, R_struc, and TimeMatrix are the outputs of rcdfCal
%            frameL is the specific length we need (should be int)
%            V is the directional speed to add on
% returns:   R_V and Traj_R are the new trajectories and R value
%            R_0 and Traj_R are from the original simulation
%   by Xinxing Yang

% check whether the frameL make sense
F_idx = find(Frame_L == frameL);
if isempty(F_idx)
    F_idX_temp = find(Frame_L<=frameL);
    F_idx = F_idX_temp(end);
    warning(['There is no exact match of the index, you are using the closest smaller index ' num2str(Frame_L(F_idx)) ' instead of ' num2str(frameL) '...']);
end
% get the trajectories and R structure of V = 0
Traj_0 = Traj_struc{F_idx,1};
R_0 = R_struc{F_idx,1};
TimeX = TimeMatrix{F_idx};
% add the speed to every trajectories
V_dir = TimeX*V;
Traj_V =  Traj_0 + V_dir;
% calculate R from each Traj
R_V = [];
for jj = 1 : size(Traj_V,1)
    Traj_temp = Traj_V(jj,:);
    [FitTrace, p, Displ, StD, Ratio] = linfitR_forcdf(TimeX,Traj_temp); % fit the speed and get ratio of noise and displacement
    R_V(1,jj) = abs(Ratio);
end


function [FitTrace, p, Displ, StD, Ratio] = linfitR_forcdf(Time,Trace)
% function linfitR fit a trace with linear function
% Input: Time and the corresponding position
% Output: FitTrace: fit line
%         p: fit parameter, p(1) is velocity
%         Displ: the total displacement
%         StD: the average standard deviation
%         Ratio: the ratio of StD to Displ
p = polyfit(Time,Trace,1); % linear fit
Displ = p(1) * (Time(end) - Time(1)); % the displacement of x from linear fit of this segment
FitTrace = p(1)*Time + p(2);
StD = std(Trace-FitTrace);
Ratio = StD/Displ;

