% This is a code for single molecule trajectories segmentation
% Mainly built for molecules in bacteria
% Current version deals with divisome proteins: 
%                 X-axis: short axis of the cell, Y-axis: long axis of the cell
%          3. The diffusion model is confined diffusion with or without processive movement
%          4. The code should be run block by block with the instructions 
% By Xinxing Yang from Dr. Jie Xiao lab  
%          version1: 2020514
%% Section 0: simulate a set of trajectories with a certain boundary and diffusion coeff 
%         1.This is not a neccessary step for every experiment. As long as the boundary does not change too much, you can use the same file generated in this step for other experiments.
%         2. A way to verify your simulation is to calculate the MSD of your stationary molecules in the end (section X). If the boundary and D are not so different from your setting here, it should be okay.
%         3. In this simulation,we consider the velocity = 0.
% Set the hyperparameters for your simulation, simulate, and save the file
clear
clc
Frame_L = [5:200]; % the range of the possible trajectory length
ExpT = 0.5; % the exposure time (if there is dark interval, this should be total time interval)
D = 0.00013; % diffusion coefficient: in um^2/s
B = 75; % boundary size  in nm
L_err = 31; % localization error in nm
N_traj = 1000; % number of trajectories for simulation in one condition
filenameSimu = 'CcFtsWStationarySimu.mat'; % filename to save the simulation result
% simulation
[R_struc,Traj_struc,TimeMatrix,frameMatrix,SpeedMatrix] = rcdfCal(Frame_L,0,ExpT,D,B,L_err,N_traj);
save(filenameSimu)
%% Section 1: refine the trajectories using intensity and calculate the noise level in both x and y 
%         1.This is the real start of segmentation: combine multiply files from different movie and remove high intensity frames
%         2. this section will generate a matrix called IndTrack (with individule traces) and StatMat (with statistics of intensity and displacement) requires following funtions in path:
%         3. functions required:
%                 a.  lognormalHistfit(I_all)
%                 b.  MSDcalculate_1d(strucD,PixelS,ExpT,0,1,'all');
%                 c.  kusumi_xy(msd_x);
%                 d.  intensityFilter(Trace,Threshold_I);
%                 e.  colorCodeTracePlot(Time,Trace,linewidth)
%                 f.  linfitR(Time,Trace)
%                 g. tracedropout(Time,Trace,Nboot,pdrop)
clear
clc
ExpT = 0.5; % timeinterval in second
PixelS = 81.25; % pixel size in nm
ThreshT = 10; % the threshold of trajectory length. Only select the trajectories longer than this
[filenameIn pathname] = uigetfile('.mat','input the unwrapped trajectory files','multiselect','on');
CountIndex = 1; % an index for later filter

% convert single file selection
if ~iscell(filenameIn)
    filename{1} = filenameIn;
else
    filename = filenameIn;
end

% import trajectroy data to get the statistic properties
I_all = []; % variable to save all the intensity values
display('Loading all files in one condition for intensity analysis...')
for ii = 1 : length(filename)
    filenameX = filename{ii};
    load([pathname filenameX]);
    for jj = 1 : length(TraceInfo)
        %         BFim = TraceInfo(jj).TraceInfo.BFrot;
        Track = TraceInfo(jj).TraceInfo.TrackcOR_unwrap;
        %         Center = TraceInfo(jj).TraceInfo.Center;
        %         Radius = TraceInfo(jj).TraceInfo.Radius;
        %         RangeX = [Center(1) - Radius(2)*0.71, Center(1) + Radius(2)*0.71]; % 0.71 is the edge of
        for kk = 1 : length(Track)
            Time = Track(kk).Time;
            Dtrace = [];
            if length(Time) > ThreshT              % trace length threshold
                % extract the intensity
                Intensity = Track(kk).Intensity;
                I_all = [I_all;Intensity];
                %combine all the traces
                Dtrace(:,1) = Time;
                Dtrace(:,2:3) = Track(kk).XYCoord(:,3:4);% only get the coordinates from average radius
                strucD.TracksROI(CountIndex).Coordinates = Dtrace;
                CountIndex = CountIndex + 1;
            end
        end
    end
end

% fit the intenisy histogram and select a threshold for intenisty based
% filter
[pd1,Ipeak, Isd] = lognormalHistfit(I_all);
waitforbuttonpress
ThreshN = inputdlg('Threshold = Ipeak+XIstd, please input X','Threshold Input');
ThreshN = str2num(ThreshN{1});
Threshold_I = Ipeak + ThreshN*Isd;
close all

% calculate the MSD of X and Y and fit with kusimu
% MSD
display('MSD processing... might take a while...')
s_xMSD = MSDcalculate_1d(strucD,PixelS,ExpT,0,1,'all');
s_yMSD = MSDcalculate_1d(strucD,PixelS,ExpT,0,2,'all');
% kusumi
T_cut = 10; % the upper bound for fitting in sec
% short axis: x
Xindex = find(s_xMSD(:,1) <= T_cut);
msd_x = s_xMSD(Xindex,:);
KusumiFit_x = kusumi_xy(msd_x);
% long axis: y
Yindex = find(s_yMSD(:,1) <= T_cut);
msd_y = s_yMSD(Yindex,:);
KusumiFit_y = kusumi_xy(msd_y);
% subplot(1,3,1)
errorbar(msd_x(:,1),sqrt(msd_x(:,2)),sqrt(msd_x(:,3)),'ob','linewidth',3);
hold on
plot(msd_x(:,1),sqrt(KusumiFit_x.F(2:end)),'-b','linewidth',3);
errorbar(msd_y(:,1),sqrt(msd_y(:,2)),sqrt(msd_y(:,3)),'og','linewidth',3);
plot(msd_y(:,1),sqrt(KusumiFit_y.F(2:end)),'-g','linewidth',3);
ylabel('sqrt(MSD) /nm')
xlabel('LagTime /s')
legend({'short axis','fit','long axis','fit'})
waitforbuttonpress
DispInput = inputdlg({'Noise level of X (suggestion: the first displacement','Confinement of Y (suggestion: the plateau of Y'},'MSD');
DispX = str2num(DispInput{1});
DispY = str2num(DispInput{2});
close all
[filenameO pathnameO] = uiputfile('.mat','Save the IndTrack structure');
PlotFilename = ['Ithreshold-' filenameO(1:find(filenameO =='.')) 'tif'];
% filter the high intensity points out from the trajectories.
display('reimport all files and filter the high intensity ones...')
CountIndex2 = 1;

for ii = 1 : length(filename)
    filenameX = filename{ii};
    load([pathname filenameX]);
    for jj = 1 : length(TraceInfo)
        BFim = TraceInfo(jj).TraceInfo.BFrot;
        Track = TraceInfo(jj).TraceInfo.TrackcOR_unwrap;
        Center = TraceInfo(jj).TraceInfo.Center;
        Radius = TraceInfo(jj).TraceInfo.Radius;
        RangeX = [Center(1) - Radius(2)*0.71, Center(1) + Radius(2)*0.71]; % 0.71 is the edge of
        for kk = 1 : length(Track)
            Trace = [];
            Time = Track(kk).Time;
            if length(Time) > ThreshT              % trace length threshold
                %set the intensity plot
                hi = figure;
                set(hi, 'position',[100,100,800,400]);
                set(hi, 'Visible', 'off');
                
                Trace(:,1) = Track(kk).Time;
                Trace(:,2:3) = Track(kk).XYCoord(:,3:4);
                Trace(:,4) = Track(kk).Intensity;
                plot(Trace(:,1),Trace(:,4),'-db');
                hold on
                % intensity filter
                NewTrace = intensityFilter(Trace,Threshold_I);
                plot(NewTrace(:,1),NewTrace(:,4),'-or');
                yline(Ipeak,'-k','mode');
                yline(Ipeak + Isd,'--k','1 sigma');
                yline(Threshold_I,'-r','threshold');
                IndTrack(CountIndex2).OriginTrace = Trace;
                IndTrack(CountIndex2).Trace = NewTrace;
                IndTrack(CountIndex2).Radius = Radius;
                IndTrack(CountIndex2).Center = Center;
                IndTrack(CountIndex2).RangeX = RangeX;
                IndTrack(CountIndex2).BFim = BFim;
                IndTrack(CountIndex2).file = filenameX;
                IndTrack(CountIndex2).cell = jj;
                IndTrack(CountIndex2).index = kk;
                CountIndex2 = CountIndex2 + 1;
                % save the plot
                saveas(hi,'temp.tif','tif');
                close(hi);
                % save the tiff movie
                TempIm = imread('temp.tif');
                imwrite(TempIm,[pathnameO PlotFilename],'WriteMode','append');
            end
        end
    end
end
% save the threshold used here
Threshold_all.Ipeak = Ipeak;
Threshold_all.Isd = Isd;
Threshold_all.N = ThreshN;
Threshold_all.I = Threshold_I;
Threshold_all.Time = ThreshT;
Threshold_all.Xnoise = DispX;
Threshold_all.Ynoise = DispY;

save([pathnameO filenameO],'IndTrack','Threshold_all');
display('pre-processing finished!')
%% Section 2: Load the file saved from section1 
%         1. This section is to get the path and filename of the trajectories filtered in section1
%         2. The variable will be used in section3, don't clear the workspace until you finishe section3
%         3. Set up hyperparameters in this section as well for the next section
clear
clc
[filename pathname] = uigetfile('.mat','input the pre-processed trace file (with IndTrack)');
load([pathname filename]);
display(['There are ' num2str(length(IndTrack)) 'trajectories in the file']);

% set up some parameters
PixelS = 100; % pixel size in nm
ExpT = 0.5; % time interval in second
TimeRange = [-10,210]; % the time range for trajectory ploting in sec ,better to have some space on both side
PosiXRang = [-600,600]; % the position range of short axis for plotting in nm
PosiYRang = [-500,500]; % the position range of short axis for plotting in nm
Nboot = 100; % number of the bootstrapping to get linear fitting
Pdrop = 0.1; %dropout probability in bootstrapping

% Load the simulated trajectories from section 1
[filenameSimu pathnameSimu] = uigetfile('.mat','Select the simulated stationary trajectories');
load([pathnameSimu filenameSimu]);
%% Section 3: Iteratively segment all trajectories  
%         1. Change the first line from 1 to max number of the trajectories (showed in last section, or check the length of IndTrack)
%         2. The variable will be saved automatically. If you cannot finish all trajectories in a single time, don't worry. You can re-run section two and start from the next trajectories haven't processed by the last time.
%         3. The segmentation file will also be saved by segment and named automatically.
%         4. functions required:
%                 a.  lognormalHistfit(I_all)
%                 b. [V, DisplXb, StDXb, RatioXb, NXb] = tracedropout(TimeT_TXY,TraceTx,Nboot,Pdrop)
%                 c. [R_V,R_0,Traj_V,Traj_0] = addVoneFLtrajs(Traj_struc,R_struc,Frame_L,frameL,TimeMatrix,V)
%                 d. Prob = getProbR(R_sample,Bin,epsl)


Index = 38; % change this line from 1 to the max index of trajectories

% segmentation start here
Trace = IndTrack(Index).Trace;% load the trace
Time = Trace(:,1)*ExpT; % in sec
TraceXY = Trace(:,2:3); % for plotting, in pixel
TraceX = Trace(:,2)*PixelS; % in nm
TraceY = Trace(:,3)*PixelS; % in nm
ImBF = IndTrack(Index).BFim; % load the bright field image
RangeX = IndTrack(Index).RangeX; % load boundary of trajectories on each side
Center = IndTrack(Index).Center; % load the center of the cell
TraceXY(:,1) = TraceXY(:,1) + Center(1);
TraceXY(:,2) = TraceXY(:,2) + Center(2);
Xnoise = Threshold_all.Xnoise;
% GUI
h = figure;
set(h, 'position',[100,100,1800,800]);

hs1 = subplot('position',[0.03,0.36,0.18,0.60]);

% show the bright field image
imshow(ImBF,[median(ImBF(:)),max(ImBF(:))]);
colormap('Gray');
freezeColors;
hold on
% plot the radius range within 70% range of the center
Y = size(ImBF,1);
xline(RangeX(1),'-r');
xline(RangeX(2),'-r');
% plot the median trajectory in color copied from Josh
colorCodeTracePlot(Time, TraceXY,0.8)
title(['Trace-' num2str(Index)]);



% plot the long axis and segment the trace by select the region
% first make a vector for saving the Time
Time_TY  = [] ;
YaxisCheck = 0; % label for longaxis selcetion
while YaxisCheck == 0
    hs3 = subplot('position',[0.25,0.05,0.70,0.27]);
    %subplot(3,5,[12:15])
    plot(Time,TraceY,'-b','linewidth',1.5);
    xlim(TimeRange)
    ylim(PosiYRang)
    ylabel('Long Axis Position(nm)');
    xlabel('Time/second')
    % first select a region where long axis looks correct
    responseLong=questdlg(['Select the middle of the cell in long axis'], ...
        'Select', 'Okay' , 'Useall','Bad Trajectory','Okay');
    if strcmp(responseLong,'Okay')
        [Xl Yl] = ginput(2);
    elseif strcmp(responseLong,'Useall')
        Xl = [min(Time),max(Time)];
    else
        close(h)
        error('User terminated the session since the trajectory is not great!')
    end
    
    IndexL = find(Time > min(Xl) & Time < max(Xl));
    MeanY = mean(TraceY(IndexL));
    Y_up = MeanY + Threshold_all.Ynoise; % upper bound of the long axis
    Y_down = MeanY - Threshold_all.Ynoise; % lower bound of the long axis
    yline(Y_up,'r','Upper bound')
    yline(Y_down,'r','Lower bound')
    IndexY = find(TraceY>=Y_down & TraceY<=Y_up);
    hold on
    plot(Time(IndexY),TraceY(IndexY)-min(MeanY,50),'-.r','linewidth',1.5)
    responseLongC=questdlg( ['Is the selected region good?'],'Selection check', 'Yes' ,'No','Yes');
    if strcmp(responseLongC,'Yes')
        YaxisCheck = 1;
        Time_TY = Time(IndexY);
        TraceX_TY = TraceX(IndexY);
        TraceY_TY = TraceY(IndexY);
    end
end


% plot the trajectory along short axis
hs2 = subplot('position',[0.25,0.36,0.70,0.63]);
handles.hs2 = hs2;
guidata(h,handles);
% plot(Time,TraceX,'-b','linewidth',1.5);
colorCodeTracePlot(Time_TY, [Time_TY,TraceX_TY],1.5)
xlim(TimeRange)
ylim(PosiXRang)
ylabel('Septal Position(nm)');
hold on
plot(Time,TraceX,'+k');
plot(Time_TY,TraceX_TY,'ok');
yline((RangeX(1)-Center(1))*PixelS,'r');
yline((RangeX(2)-Center(1))*PixelS,'r');
set(gca,'xtick',[])
set(gca,'xticklabel',[])
box on
grid on


% start segmentation
Istate = 1; % state counter
EndFlag = 1; % the flag to end the selection
while EndFlag ~= 0
    response=questdlg(['Select the ' num2str(Istate) 'state in the trace'], ...
        'Select a state?', 'Yes' , 'No','Yes');
    if strcmp(response,'Yes')
        SelectFlag = 0  % flag for saving one selection
        while SelectFlag == 0
            FigSave = ['Fig-' filename(1:find(filename == '.')-1) '-ind' num2str(Index) '-seg' num2str(Istate) '.jpg'];
            [X Y] = ginput(2);
            X_1 = min(X);
            X_2 = max(X);
            hold on
            IndexT = find (Time_TY>= X_1 & Time_TY <= X_2);
            TimeT_TXY = Time_TY(IndexT);
            %       TimeState = (TimeT(end) - TimeT(1))*ExpT;
            TraceTx = TraceX_TY(IndexT);
            TraceTy = TraceY_TY(IndexT);
            %       single fitting
            [FitTraceX, pX, DisplX, StDX, RatioX] = linfitR(TimeT_TXY,TraceTx);
            Vx = pX(1);
            [FitTraceY, pY, DisplY, StDY, RatioY] = linfitR(TimeT_TXY,TraceTy);
            Vy = pY(1);
            % plot the linear fitting
            hx1 = xline(X_1,'b',['V= ' num2str(pX(1),2) 'nm/s; R=' num2str(RatioX,2)]);
            hx2 = xline(X_2,'b');
            hy = plot(TimeT_TXY,FitTraceX,'-k');
            hy1 = plot(TimeT_TXY,FitTraceX + Xnoise,'color',[0,0,0] + 0.4);
            hy2 = plot(TimeT_TXY,FitTraceX - Xnoise,'color',[0,0,0] + 0.4);
            
            %       Bootstraping
            [V, DisplXb, StDXb, RatioXb, NXb] = tracedropout(TimeT_TXY,TraceTx,Nboot,Pdrop);
            Vxboot(1,1) = mean(V);
            Vxboot(1,2) = std(V);
            DisplXboot(1,1) = mean(DisplXb);
            DisplXboot(1,2) = std(DisplXb);
            StDXboot(1,1) = mean(StDXb);
            StDXboot(1,2) = std(StDXb);
            RatioXboot(1,1) = mean(RatioXb);
            RatioXboot(1,2) = std(RatioXb);
            
            % start the probabiliry calculation
            Ratio_region = [RatioXboot(1,1) - RatioXboot(1,2), RatioXboot(1,1) + RatioXboot(1,2)]; % consider the Ratio is in a range of bootstrapping
            frameL = round((X_2-X_1)/ExpT); % the closest frame length of the trajectories
            [R_V,R_0,Traj_V,Traj_0] = addVoneFLtrajs(Traj_struc,R_struc,Frame_L,frameL,TimeMatrix,Vxboot(1,1)); % get the R distributions
            % calculate the probability of each mode
            P_0 = getProbR(R_0,Ratio_region); % probability of stationary
            P_V = getProbR(R_V,Ratio_region); % probability of directional moving with speed V
            P_directional = P_V/(P_0+P_V); % final probability of the directional movement
            
            
            % make a nice histogram for each speed
            [hRV,hRVx] = hist(R_V,[0:0.05:2.5]);
            [hR0,hR0x] = hist(R_0,[0:0.05:2.5]);
            

            
            
            hs4 = subplot('position',[0.04,0.06,0.15,0.25])
%             scatter(V,RatioXb,'filled');
            hold off
            plot(hRVx(2:end-1),hRV(2:end-1),'g-','linewidth',1.5);
            hold on
            plot(hR0x(2:end-1),hR0(2:end-1),'r-','linewidth',1.5);
            xline(Ratio_region(1),'k','linewidth',2);
            xline(Ratio_region(2),'k','linewidth',2);
%             xlabel('V_fit(nm/s)');
%             ylabel('Ratio SD/disp');
            xlabel('Ratio');
            ylabel('Freq');
            title(['V = ' num2str(Vxboot(1),2) '; R=' num2str(RatioXboot(1),2) ';P-progress = ' num2str(P_directional,2)]);
            
            
%             response=questdlg(['What type of the state is?'], ...
%                 'Select the fitting function of msd', 'Diffusion' , 'Directional','Diffusion');
%             set(gcf,'CurrentAxes',handles.hs2)
%             if strcmp(response,'Diffusion')
%                 ht = text(X_1,PosiXRang(1)+diff(PosiXRang)*0.1,['S']);
%                 Mlabel = 'Stationary';
%             else
%                 ht = text(X_1,PosiXRang(1)+diff(PosiXRang)*0.1,['P']);
%                 Mlabel = 'Processive';
%             end
%             handles.ht = ht;
%             guidata(h,handles);
            % ask whether it is okay to select this
            response=questdlg(['Is this selection okay?'], ...
                'Check', 'Yes' , 'No','Yes');
            if strcmp(response,'Yes')
                saveas(h,FigSave,'jpg');
%               StateFit(Istate).mode = Mlabel;
                StateFit(Istate).P0 = P_0;
                StateFit(Istate).PV = P_V;
                StateFit(Istate).P_progressive = P_directional;
                StateFit(Istate).Time = TimeT_TXY;
                StateFit(Istate).Xposi = TraceTx;
                StateFit(Istate).Xfit = FitTraceX;
                StateFit(Istate).Yposi = TraceTy;
                StateFit(Istate).Yfit = FitTraceY;
                StateFit(Istate).Vx = Vx;
                StateFit(Istate).Vy = Vy;
                StateFit(Istate).Displx = DisplX;
                StateFit(Istate).Disply = DisplY;
                StateFit(Istate).SDx = StDX;
                StateFit(Istate).SDy = StDY;
                StateFit(Istate).Vxboot = Vxboot;
                StateFit(Istate).DisplXboot = DisplXboot;
                StateFit(Istate).StDXboot = StDXboot;
                StateFit(Istate).RatioXboot = RatioXboot;
                StateFit(Istate).DwellT =  TimeT_TXY(end)-TimeT_TXY(1);
                Istate = Istate + 1;
                IndTrack(Index).StateFit = StateFit;
                SelectFlag = 1;
            else
                delete(hx1);
                delete(hx2);
                delete(hy);
                delete(hy1);
                delete(hy2);
            end
        end
    else
        EndFlag = 0;
    end
    
end
clear StateFit
save([pathname filename],'IndTrack','Threshold_all');
close(h);


