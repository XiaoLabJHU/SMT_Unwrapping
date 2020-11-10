function [R_struc,Traj_struc,TimeMatric,frameMatrix,SpeedMatrix] = rcdfCal(N_frame_list,V_x_list,T_exp,D_eff,Boundary,Local_err,N_traj)
%rcdfCal run N_traj simulations to calculate the Ratio based on the input
%parameters and record the trajectory
% N_frame_list: a vector with all the frame length to simulate
% V_x_list: avector with all the velocities to simulate
% N_traj = 1000; % number of traces to simulate
% T_exp = 0.5; % exposure time in sec
% D_eff = 0.001; % diffusion coefficient in um^2/s
% Boundary = 84; % boundary in nm
% Local_err = 37; % localization in error
% 
for ii = 1 : length(N_frame_list) % the rows are different frame length
    tic
    for jj = 1 : length(V_x_list) % the columns are different speed
        N_frame = N_frame_list(ii);
        V_x = V_x_list(jj);
        R = []; % initialize R
        Time = [1:N_frame]'*T_exp;
        Traj_temp = []; % initialize the temporal matrix for saving traces from the same condition
        parfor kk = 1 : N_traj % loop for real simulation
            Traj = confdirTrackGene(N_frame,T_exp,D_eff,V_x,Boundary,Local_err);
            [FitTrace, p, Displ, StD, Ratio] = linfitR_forcdf(Time,Traj); % fit the speed and get ratio of noise and displacement
            R(kk) = abs(Ratio);
            Traj_temp(kk,:) = Traj;
        end
        R_struc{ii,jj} = R;
        Traj_struc{ii,jj} = Traj_temp;
        frameMatrix(ii,jj) = N_frame;
        SpeedMatrix(ii,jj) = V_x;
        display(['Simulating: frame = ' num2str(ii) 'of' num2str(length(N_frame_list)) ' V = ' num2str(jj) 'of' num2str(length(V_x_list)) '...']);
    end
        TimeMatric{ii,1} = [1:N_frame]*T_exp; % the x axis
    toc
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