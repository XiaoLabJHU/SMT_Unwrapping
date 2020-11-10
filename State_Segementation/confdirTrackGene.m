function Traj = confdirTrackGene(N_frame,T_exp,D_eff,V_x,Boundary,Local_err)
%confinedTrackGene simulate one trajectoy with
% N_frame frames,
% Time interval = T_exp in sec
% D_eff in um^2/s
% Boundary in nm
% V_x the speed in x direction nm/s
% Localization in nm
% the trajectory start from 0
% the molecules reflect on the bounndary
%% for debug
% N_frame = 100;
% T_exp = 0.5;
% Boundary = 92.6;
% D_eff = 0.00042;
% Local_err = 42;
% V_x = 10;
%% first adjust all units to nm
Disp_single_mean = sqrt(2 * T_exp * D_eff)*1000; % in nm
% the traj is confined in a region as below
B_up = Boundary/2;
B_down = -Boundary/2;

% to better simulate the trajectory, average displacement should be about 1/20 of the boundray
Step_sizeMax = Boundary/20; % the maximum step size
N_step = ceil(Disp_single_mean/Step_sizeMax);
Step_size_real = Disp_single_mean/sqrt(N_step);
Step_total = N_frame*N_step;

%% generate the trajectory in small step size and no localization error
TrackAb(1) = 0;
for ii = 2:Step_total
    Posi_prev = TrackAb(ii -1);
    % calculate the absolute distance between the last position to the two
    % boundary lines
    Dist_up = B_up - Posi_prev;
    Dist_down = Posi_prev - B_down;
    % generate a random displacement
    Current_disp = normrnd(0,Step_size_real);
    % a possible localation
    PosiTemp = TrackAb(ii-1) + Current_disp; 
    % check whether the position is outside of the two boundary lines
    Posi_current = PosiTemp;
    if PosiTemp > B_up
        Posi_current = B_up -(Current_disp - Dist_up);
    end
    
    if PosiTemp < B_down
        Posi_current = B_down +(abs(Current_disp) - Dist_down);
    end
    % set the current position in trajectory
    TrackAb(ii) = Posi_current;
end

% plot the result for debug
% plot([1:Step_total],TrackAb,'-ob')

% rearange the matric and averge the small steps
TrackComb = mean(reshape(TrackAb,[N_step,N_frame]),1);
% Add the localization error
Local_error_track = normrnd(0,Local_err,[1,N_frame]);
% generate the final trajecotory
Traj = (TrackComb + Local_error_track)';
% Add directional moving part
Traj = Traj + [1:N_frame]'*T_exp*V_x;
% %plot the result for debug
%  plot(TrackComb,'-ob')
%  hold on
%  plot(Traj,'-dr')
end

