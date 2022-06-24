clear; clc;

exp_tag = "FtsA_";
frame_time = 0.5;

probability = 0.75;
R_value = 0.4;
[file, path]=uigetfile('*.mat','select the blinded structure');
load(fullfile(path, file));
Raw_MSDs = [];
index = 6;
mp = get(0,'MonitorPositions');
    figsize = [9 4];
counter = 0;

for idxa = 1:length(IndTrack)
    StateFit = IndTrack(idxa).StateFit;
    if isfield(IndTrack,'StateFit') == 1
        for idxb = 1:length(StateFit)
            if StateFit(idxb).RatioXboot > R_value | StateFit(idxb).P_progressive < probability & StateFit(idxb).P_progressive ~= 0.5
                counter = counter + 1;
                [~,positions] = intersect(IndTrack(idxa).Trace(:,1).*frame_time,StateFit(idxb).Time);
                traj = [IndTrack(idxa).OriginTrace(positions,1).*frame_time IndTrack(idxa).OriginTrace(positions,2) IndTrack(idxa).OriginTrace(positions,3)];
                traj(:,1) = traj(:,1) - traj(1,1);
                kusumidata(counter).frames = traj(:,1);
                kusumidata(counter).coordinates(:,1)=traj(:,2).*0.1;
                kusumidata(counter).coordinates(:,2)=traj(:,3).*0.1;
                kusumidata(counter).intensity=IndTrack(idxa).Trace(positions,4);
                kusumidata(counter).mol_id=counter;
                kusumidata(counter).data_id = [];
                MSD_temp = MSD_Calc(traj,0.1); %Create the MSD matrix.
                Raw_MSDs = [Raw_MSDs; MSD_temp];
            end
        end
    end
end

MSD = [];
for idxc = 1:max(unique(Raw_MSDs(:,1)))
    MSD_temp = [];
    MSD_temp = Raw_MSDs(find(Raw_MSDs(:,1) == idxc),2);
    MSD(idxc,1) = idxc;
    MSD(idxc,2) = nanmean(MSD_temp); % MSD
    MSD(idxc,3) = nanstd(MSD_temp)/sqrt(length(MSD_temp)); % Standard Err
    MSD(idxc,4) = length(MSD_temp); % N
end

close all;
msd_eqn1D = @(P,x) 2*P(1)*x.^(P(2)) + P(3);
param = lsqcurvefit(msd_eqn1D,[0 1 0],MSD(1:index,1),MSD(1:index,2));
xfit = linspace(0,MSD(index,1),500);
yfit = msd_eqn1D(param,xfit); 
results = Kusumi(kusumidata,1,100,index);
%results
f = figure('Units','Inches','Position',[0 0 figsize],'PaperUnits','inches','PaperPosition',[0 0 figsize],'PaperSize',figsize,'CreateFcn','movegui center');
ax1 = subplot(1,2,1);
errorbar(results.D_allx(:,1),results.D_allx(:,2),results.D_allx(:,3),'ok','LineWidth',1);
title('Kusumi Fitting, X');
ylabel('MSD, \mum');
xlabel('Time Lag (s)');
ax2 = subplot(1,2,2);
errorbar(results.D_ally(:,1),results.D_ally(:,2),results.D_ally(:,3),'ok','LineWidth',1);
title('Kusumi Fitting, Y');
xlabel('Time Lag (s)');
set([ax1 ax2],'LineWidth',1.75,'FontSize',14,'TickDir','Out','Box','Off','XColor',[0 0 0],'YColor',[0 0 0]);
print(f,'KusumiMSDs.png','-r600');

out_path = fullfile(path, exp_tag + 'KusumiResults.mat');

save(out_path,'results');
%%
f1 = figure('Units','Inches','Position',[mp(2,1) -mp(2,2) figsize],'PaperUnits','inches','PaperPosition',[0 0 figsize],'PaperSize',figsize,'CreateFcn','movegui center'); 
e1 = errorbar(MSD(1:index,1),MSD(1:index,2),MSD(1:index,3),'ok');
hold on;
p1 = plot(xfit,yfit,'-r','LineWidth',1.5,'Color',rgb('FireBrick'));
legend([p1],{['ZipA Diffusion' 10 'D = ' num2str(round(param(1),3)) '\mum^2/s' 10 '\alpha = ' num2str(round(param(2),2)) 10 'N = ' num2str(MSD(index,4))]},'Box','off','location','southeast');
xlabel('Time (s)');
ylabel('MSD (\mum^2)');
set([e1],'MarkerSize',5,'LineWidth',1,'MarkerEdgeColor',rgb('Black'),'MarkerFaceColor',rgb('LightGray'));
set(gca,'LineWidth',1.75,'FontSize',14,'TickDir','Out','Box','Off','XColor',[0 0 0],'YColor',[0 0 0]);
%print(f1,'ZipA_Unwrap_MSD.pdf','-dpdf');


%%

function MSD = MSD_Calc(traj,pixelsize);
frames = traj(:,1)-traj(1,1)+1; %Makes the frame count starting from one. 
r=[]; %creates a blank matrix named "r."
MSD=[]; %creates a blank matrix named "MSD."
N = (max(traj(:,1))-min(traj(:,1)));
for j = 1:N;
    r = [];
    for i = 1:min(frames(end)-j,length(frames));
        Endf=find(frames==(frames(i)+j)); %End frame for calculating endpoint.
        if Endf > 0;
        Endp=traj(Endf,2:3); %defines the endpoint for timelag.
        r(i,1) = sum((((traj(i,2)-Endp)*pixelsize).^2)); %squared displacement in micrometers
        end;
        %r = [r; squared]; %Writes the matrix
    end;
    MSD(j, 1) = j; %First column, time lag.
    MSD(j, 2) = mean(r); %Second column, MSD value.
    MSD(j, 3) = std(r)/sqrt(length(r)); %Third column, standard error.
end;
MSD(:,1) = MSD(:,1);
end

function results = Kusumi(s, t, px, n)

% first get the MSD vs T in both the x and y direction (need rotated data!)
    s = TrajConsc(s, 1);
    s_n = TrajSelect(s, n);
    
    % calculate all displacements
    d_allx = [];
    d_ally = [];
    D_allx = [];
    D_ally = [];
    
    % calculates ALL displacements
    for i = 1: length(s_n)
        dx = TrajDispl(s_n(i).coordinates(:,1), t);
        dy = TrajDispl(s_n(i).coordinates(:,2), t);
        d_allx(end+1:end+size(dx, 1), :) = dx;
        d_ally(end+1:end+size(dy, 1), :) = dy;
    end
    
    time_lags = unique(d_allx(:, 1));
    
    % finds the mean displacement squared from above displacements
    for i = 1:size(time_lags, 1)
        indx=find(d_allx(:, 1) == time_lags(i));
        indy = find(d_ally(:, 1) == time_lags(i));
        D_allx(i, 1) = t * time_lags(i); % converts to real time lag
        D_allx(i, 2) = mean(d_allx(indx, 2)); %MSD in x-direction for timelag i
        D_allx(i, 3) = std(d_allx(indx, 2))/sqrt(length(indx)); %sem in x-direction for timelag i
        D_ally(i, 1) = t * time_lags(i);
        D_ally(i, 2) = mean(d_ally(indy, 2)); %MSD in y-direction for timelag i
        D_ally(i, 3) = std(d_ally(indy, 2))/sqrt(length(indy)); %sem in y-direction for timelag i
    end
    
% estimate initial conditions from the data
    coefficients_x = [];
    coefficients_y = [];
    sxApprox = [];
    LxApprox = [];
    syApprox = [];
    LyApprox = [];
    
    coefficients_x = polyfit(D_allx(1:5, 1), D_allx(1:5, 2), 1); 
    sxApprox = sqrt(coefficients_x(1)); %starting value for sx
    LxApprox = sqrt(D_allx(end,2)); %starting value for Lx
    
    coefficients_y = polyfit(D_ally(1:5, 1), D_ally(1:5, 2), 1);
    syApprox = sqrt(coefficients_y(1)); %starting value for sy
    LyApprox = sqrt(coefficients_y(1)); %starting value for Ly
    
% calculate the best fit to get Kusumi equation parameters

    guess = [LxApprox, sxApprox];
    [Coeff, g, exitflag] = fminsearch(@(x) kelsey2(x, D_allx), guess,...
        optimset('Display','iter','MaxIter',10000,'TolX',5e-7,'TolFun',5e-7,'MaxFunEvals',100000));
    
    Lx = Coeff(1); % IN MICRONS!!!
    sigma_x = Coeff(2); 
    Dx = (Coeff(2)^2)/2;
    
    Fx=[];
    for i=1:length(D_allx(:,1))+1
        if i == 1
            fx(i) = Lx^2/6-16*Lx^2/pi^4*ApproxSum(Coeff, 0);
        else
            Fx(i)=Lx^2/6-16*Lx^2/pi^4*ApproxSum(Coeff, D_allx(i-1,1));
        end
    end
    
    guess = [LyApprox, syApprox];
    [Coeff, g, exitflag] = fminsearch(@(x) kelsey2(x, D_ally), guess,...
        optimset('Display','iter','MaxIter',10000,'TolX',1e-6,'TolFun',1e-6,'MaxFunEvals',50000));
    
    Ly = Coeff(1);
    sigma_y = Coeff(2);
    Dy = (Coeff(2)^2)/2;
    
    Fy=[];
    for i=1:length(D_ally(:,1))+1
        if i == 1
            Fy(i) = Ly^2/6-16*Ly^2/pi^4*ApproxSum(Coeff, 0);
        else
            Fy(i)=Ly^2/6-16*Ly^2/pi^4*ApproxSum(Coeff, D_ally(i-1,1));
        end
    end
    
    %D_allx, D_ally, Lx, Ly, sigma_x, sigma_y, Dx, Dy, Fx, Fy
    results.D_allx = D_allx;
    results.D_ally = D_ally;
    results.Lx = Lx;
    results.Ly = Ly;
    results.sigma_x = sigma_x;
    results.sigma_y = sigma_y;
    results.Dx = Dx;
    results.Dy = Dy;
    results.Fx = Fx;
    results.Fy = Fy;
    
end
% given a trajectory (traj), t, the time interval (in s) between subsequent frames, and the corresponding frame index of each coordinate pair in traj, 
% calculate the displacements at all possible time lags.
% the output is a list with first column being the time lags, 2nd column mean squared displacement of all pairs with the same time lag, 3rd column the calculated diffusion coefficient
% 

%traj = traj(2).coordinates 

