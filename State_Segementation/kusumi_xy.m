% Given a structure, this
% function will compute the confinement length and corrected diffusion
% coefficient using an equation derived from
% Kusumi et. al., Biophysical Journal, 1993.
% 
% The time is the frame length and the "n" is how far along in each
% trajectory you want to calculate the mean-squared displacement.
% 
% The equation is as follows: MSD(t) = L^2/6 -L^2/16 * Sum(n=1 to inf)
% 1/n^4 * exp(-0.5 * (n*pi*sigma_d/L)^2 * t).
% 
% Input:
% s = structure in Octane format (in pixels) - use UTrackerConverter
% function
% t = frame length interval 
% conversion = um per pixel
%
% Output:
% results.L = confinement length of particle in the x-direction, in um
% results.Ly = confinement length of particle in the y-direction, in um
% results.sigma = average displacement in x-direction, in um
% results.sigma_y = average displacement in y-direction, in um
% results.D = "corrected" diffusion coefficient 
% results.F = Kusumi equation fit for the x-direction (MSD using the equation
% above)
% Code written by Kelsey Bettridge, 8-29-2017
% kelsey2 and ApproxSum functions were written with help from my dad, Jeff
% Gray
% Xinxing modified for a flexible data
% you only need to input the msd: column 1: time in sec, 2:msd in um^2,
% 3: sem of the colume2
function results = kusumi_xy(msd)
    
%     % calculate all displacements
%     d_all = [];
%     D_all = [];
%     D_ally = [];
%     
%     % calculates ALL displacements
%     for i = 1: length(s)
%         dr = TrajDispl(s(i).coordinates(:,1:2), t, s(i).frames);
%         d_all(end+1:end+size(dr, 1), :) = dr;
%     end
%     
%     time_lags = unique(d_all(:, 1));
%     
%     % finds the mean displacement squared from above displacements
%     for i = 1:size(time_lags, 1)
%         ind=find(d_all(:, 1) == time_lags(i));
%         D_all(i, 1) = t * time_lags(i); % converts to real time lag
%         D_all(i, 2) = mean(d_all(ind, 2)); %MSD in for timelag i
%         D_all(i, 3) = std(d_all(ind, 2))/sqrt(length(ind)); %sem in x-direction for timelag i
%     end
    D_all = msd;
% estimate initial conditions from the data
    coefficients = [];
    sApprox = [];
    LApprox = [];
    
    coefficients = polyfit(D_all(1:5, 1), D_all(1:5, 2), 1); 
    sApprox = sqrt(coefficients(1)); %starting value for s
    LApprox = sqrt(D_all(end,2)); %starting value for L
    
% calculate the best fit to get Kusumi equation parameters

    guess = [LApprox, sApprox,0];
    [Coeff, g, exitflag] = fminsearch(@(x) kelsey2(x, D_all), guess,...
        optimset('Display','iter','MaxIter',10000,'TolX',5e-7,'TolFun',5e-7,'MaxFunEvals',100000));
    
    L = Coeff(1)
    sigma = Coeff(2)
    D = (Coeff(2)^2)/2
    
    F=[];
    for i = 1:length(D_all(:,1))+1
        if i == 1
            F(i) = L^2/6-16*L^2/pi^4*ApproxSum(Coeff, 0) + Coeff(3);
        else
            F(i)=L^2/6-16*L^2/pi^4*ApproxSum(Coeff, D_all(i-1,1)) + Coeff(3);
        end
    end
    
    %D_allx, D_ally, Lx, Ly, sigma_x, sigma_y, Dx, Dy, Fx, Fy
    results.D_all = D_all;
    results.L = L;
    results.sigma = sigma;
    results.D = D;
    results.F = F;
    
end