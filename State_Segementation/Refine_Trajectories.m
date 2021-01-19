function Refine_Trajectories(filenameIn,pathname,Experiment,ExpT,PixelS,ThreshT);

CountIndex = 1; % an index for later filter

% convert single file selection
if ~iscell(filenameIn)
    filename{1} = filenameIn;
else
    filename = filenameIn;
end

% import trajectroy data to get the statistic properties
I_all = []; % variable to save all the intensity values
time_all = []; % variable to save time boundary in nanopillar condition.
display('Loading all files in one condition for intensity analysis...')
for ii = 1 : length(filename)
    filenameX = filename{ii};
    load([pathname filenameX]);
    for jj = 1 : length(TraceInfo)
        Track = TraceInfo(jj).TraceInfo.TrackcOR_unwrap;
        for kk = 1 : length(Track)
            Time = Track(kk).Time;
            Dtrace = [];
            if length(Time) > ThreshT              % trace length threshold
                % extract the intensity
                Intensity = Track(kk).Intensity;
                I_all = [I_all;Intensity];
                %combine all the traces
                Dtrace(:,1) = (Time - Time(1));  
                time_all = [time_all; (Time-Time(1))];
                switch Experiment
                    case 'Nanopillar'
                        Dtrace(:,2:3) = Track(kk).XYCoord(:,1:2);
                    otherwise
                        Dtrace(:,2:3) = Track(kk).XYZCoord(:,3:4);% only get the coordinates from average radius
                end
                strucD.TracksROI(CountIndex).Coordinates = Dtrace;
                CountIndex = CountIndex + 1;
            end
        end
    end
end

% fit the intenisy histogram and select a threshold for intenisty based
% filter. Input # of SDs.
[pd1,Ipeak, Isd] = lognormalHistfit(I_all);
waitforbuttonpress
ThreshN = inputdlg('Threshold = Ipeak+XIstd, please input X','Threshold Input (# SDs)');
ThreshN = str2num(ThreshN{1});
Threshold_I = Ipeak + ThreshN*Isd;
close all

% calculate the MSD of X and Y and fit with kusimu
% MSD
display('MSD processing... might take a while...')
switch Experiment
    case 'Nanopillar'
        s_MSD = MSDcalculate_2d(strucD,PixelS,ExpT,0,'all');
    otherwise
        s_xMSD = MSDcalculate_1d(strucD,PixelS,ExpT,0,1,'all');
        s_yMSD = MSDcalculate_1d(strucD,PixelS,ExpT,0,2,'all');
end
% kusumi
T_cut = 10; % the upper bound for fitting in sec
switch Experiment
    case 'Nanopillar'
        index = find(s_MSD(:,1) <= T_cut);
        msd_2d = s_MSD(index,:);
        KusumiFit =  kusumi_xy(msd_2d);
        errorbar(msd_2d(:,1),sqrt(msd_2d(:,2)),sqrt(msd_2d(:,3)),'ob','linewidth',1.5,'Color',[0 0 0.5430]);
        hold on
        plot(msd_2d(:,1),sqrt(KusumiFit.F(2:end)),'-b','linewidth',1.5,'Color',[0 0 0.5430]);
        legend({'MSD','Fit'},'Box','Off','Location','northwest');
    otherwise
        % short axis: x
        Xindex = find(s_xMSD(:,1) <= T_cut);
        msd_x = s_xMSD(Xindex,:);
        KusumiFit_x = kusumi_xy(msd_x);
        % long axis: y
        Yindex = find(s_yMSD(:,1) <= T_cut);
        msd_y = s_yMSD(Yindex,:);
        KusumiFit_y = kusumi_xy(msd_y);
        errorbar(msd_x(:,1),sqrt(msd_x(:,2)),sqrt(msd_x(:,3)),'ob','linewidth',1.5,'Color',[0 0 0.5430]);
        hold on
        plot(msd_x(:,1),sqrt(KusumiFit_x.F(2:end)),'-b','linewidth',1.5,'Color',[0 0 0.5430]);
        errorbar(msd_y(:,1),sqrt(msd_y(:,2)),sqrt(msd_y(:,3)),'og','linewidth',1.5,'Color',[0 0.3906 0]);
        plot(msd_y(:,1),sqrt(KusumiFit_y.F(2:end)),'-g','linewidth',1.5,'Color',[0 0.3906 0]);
        legend({'short axis','fit','long axis','fit'},'Box','Off','Location','northwest')
end
ylabel('$\sqrt{MSD}$ (nm)','Interpreter','Latex')
xlabel('LagTime /s')
set(gca,'Box','Off','LineWidth',1.3,'XColor',[0 0 0],'YColor',[0 0 0],'FontSize',12,'TickDir','Out');
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

Theta_All = [];
TraceX_All = [];
for ii = 1 : length(filename)
    filenameX = filename{ii};
    load([pathname filenameX]);
    for jj = 1 : length(TraceInfo)
        Track = TraceInfo(jj).TraceInfo.TrackcOR_unwrap;
        Center = TraceInfo(jj).TraceInfo.Center;
        Radius = TraceInfo(jj).TraceInfo.Radius;
        switch Experiment
            case '2D_Tracking'
                RangeX = [Center(1) - Radius(2)*0.71, Center(1) + Radius(2)*0.71]; % 0.71 is the edge of
                BFim = TraceInfo(jj).TraceInfo.BFrot;
            case '3D_Tracking'
                BFim = TraceInfo(jj).TraceInfo.BFrot;
        end
        for kk = 1 : length(Track)
            Trace = [];
            Time = Track(kk).Time;
            if length(Time) > ThreshT              % trace length threshold
                %set the intensity plot
                hi = figure;
                set(hi, 'position',[100,100,800,400]);
                set(hi, 'Visible', 'off');
                
                Trace(:,1) = Track(kk).Time;
                switch Experiment
                    case 'Nanopillar'
                        Trace(:,2) = Track(kk).thetas_peeled-mean(Track(kk).thetas_peeled);
                    case '2D_Tracking'
                        Trace(:,2:3) = Track(kk).XYZCoord(:,3:4);
                    case '3D_Tracking'
                        Trace(:,2:4) = [Track(kk).XYZCoord(:,3:4),Track(kk).XYZCoord(:,3)-mean(Track(kk).XYZCoord(:,3))];
                        TraceX_All = [TraceX_All; Track(kk).XYZCoord(:,3)-mean(Track(kk).XYZCoord(:,3))*PixelS];
                end 
                            
                Trace(:,end+1) = Track(kk).Intensity;
                plot(Trace(:,1),Trace(:,end),'-db');
                hold on
                % intensity filter
                NewTrace = Trace(Trace(:,end) < Threshold_I,:);
                plot(NewTrace(:,1),NewTrace(:,end),'-or');
                yline(Ipeak,'-k','mode');
                yline(Ipeak + Isd,'--k','1 sigma');
                yline(Threshold_I,'-r','threshold');
                IndTrack(CountIndex2).OriginTrace = Trace;
                IndTrack(CountIndex2).Trace = NewTrace;
                IndTrack(CountIndex2).Radius = Radius;
                IndTrack(CountIndex2).Center = Center;
                IndTrack(CountIndex2).file = filenameX;
                IndTrack(CountIndex2).cell = jj;
                IndTrack(CountIndex2).index = kk;
                switch Experiment
                    case 'Nanopillar'
                        Theta_All = [Theta_All; Track(kk).thetas_peeled-mean(Track(kk).thetas_peeled)];
                        IndTrack(CountIndex2).Filedate = TraceInfo(jj).TraceInfo.FileDate;
                        IndTrack(CountIndex2).Source = TraceInfo(jj).TraceInfo.Source;
                        IndTrack(CountIndex2).RawTraj = Track(kk).RawTraj(Trace(:,end) < Threshold_I,:);
                        IndTrack(CountIndex2).CircleFit = TraceInfo(jj).TraceInfo.CircleFit; 
                        IndTrack(CountIndex2).RawThetas = Track(kk).rawthetas(Trace(:,end) < Threshold_I,:);
                        IndTrack(CountIndex2).Thetas_Peeled = Track(kk).thetas_peeled(Trace(:,end) < Threshold_I,:);
                        IndTrack(CountIndex2).rhos_peeled = Track(kk).rhos_peeled(Trace(:,end) < Threshold_I,:);
                        IndTrack(CountIndex2).rho_residuals = Track(kk).rho_residuals(Trace(:,end) < Threshold_I,:);
                        IndTrack(CountIndex2).Diameter = Track(kk).Diameter;
                    case '3D_Tracking'
                        IndTrack(CountIndex2).BFim = BFim;
                    case '2D_Tracking'
                        IndTrack(CountIndex2).RangeX = RangeX;
                        IndTrack(CountIndex2).BFim = BFim;
                end
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
switch Experiment
    case 'Nanopillar' %Calculate the time range for the x-axis in segmentation.
        Time_vals = unique(time_all);
        theta_vals = unique(Theta_All);
        T_Range = [min(Time_vals)-10 ceil(max(Time_vals)/10)*10];
        Theta_Range = [ceil(min(theta_vals)/10)*10 ceil(max(theta_vals)/10)*10];
        Threshold_all.TimeRange = T_Range;
        Threshold_all.Thetas = Theta_Range;
    case '3D_Tracking'
        Time_vals = unique(time_all);
        trace_vals = unique(TraceX_All);
        T_Range = [min(Time_vals)-10, ceil(max(Time_vals)/10)*10];
        TraceX_Range = [ceil(min(trace_vals)/10)*10, ceil(max(trace_vals)/10)*10];
        Threshold_all.TimeRange = T_Range;
        Threshold_all.TraceXrange = TraceX_Range;
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
end