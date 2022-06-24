function Segment_Blinded_Trajectories(Index, Ind_path, Input_Params)

load(Ind_path);

% if Input_Params.martin_is_in_lab
%     MartinsMonitors = get(0,'MonitorPositions');
%     questdlgpos = [0.01+MartinsMonitors(1,2),0.05];
% else
%     questdlgpos = [0.01,0.32];
% end

%Parse arguments
Experiment =  Input_Params.Experiment;
PixelS = Input_Params.PixelS;
ExpT = Input_Params.ExpT;
TimeRange = Input_Params.TimeRange;
PosiXRang = Input_Params.PosiXRang;
PosiYRang = Input_Params.PosiYRang;
Nboot = Input_Params.Nboot;
Pdrop = Input_Params.Pdrop;
Frame_L = Input_Params.Simul_strucs.Frame_L;
R_struc = Input_Params.Simul_strucs.R_struc;
SpeedMatrix = Input_Params.Simul_strucs.SpeedMatrix;
TimeMatrix = Input_Params.Simul_strucs.TimeMatrix;
Traj_struc = Input_Params.Simul_strucs.Traj_struc;
frameMatrix = Input_Params.Simul_strucs.frameMatrix;
Strain_Curr = IndTrack(Index).StrainName;
Threshold = Threshold_all(strcmp(Strain_Curr,{Threshold_all.Strain}));

%Parse Optional Arguments
questdlgpos = Input_Params.questdlgpos;
figpos = Input_Params.figpos;

% pause_length = 0;


% segmentation start here
Trace = IndTrack(Index).Trace;% load the trace
Time = Trace(:,1)*ExpT; % in sec
Center = IndTrack(Index).Center; % load the center of the cell
switch Experiment
    case 'Nanopillar'
        Time = Time - Time(1);
        TraceTheta = Trace(:,2);
        TraceTheta = TraceTheta - mean(TraceTheta);
        CF = IndTrack(Index).CircleFit;
        RawTraj = IndTrack(Index).RawTraj;
        RawTrajTime = RawTraj(:,1) - RawTraj(1,1);
        Radius = IndTrack(Index).Radius;
    case '2D_Tracking'
        TraceXY = Trace(:,2:3); % for plotting, in pixel
        TraceX = Trace(:,2)*PixelS; % in nm
        TraceY = Trace(:,3)*PixelS; % in nm
        ImBF = IndTrack(Index).BFim; % load the bright field
        TraceXY(:,1) = TraceXY(:,1) + Center(1);
        TraceXY(:,2) = TraceXY(:,2) + Center(2);
        RangeX = IndTrack(Index).RangeX; % load boundary of trajectories on each side
    case '3D_Tracking'
        Time = Time - Time(1);
        TraceXY = Trace(:,2:3); % for plotting, in pixel
        TraceX = Trace(:,4)*PixelS; % in nm
        TraceY = (Trace(:,3) - Center(2))*PixelS; % in nm
        ImBF = IndTrack(Index).BFim; % load the bright field
        TraceXY(:,1) = TraceXY(:,1) + Center(1);
        TraceXY(:,2) = TraceXY(:,2);
end
Xnoise = Threshold.Xnoise;
% GUI
Pix_SS = get(0,'screensize');
%h = figure('Visible','On','position',[1,1,Pix_SS(3),Pix_SS(4)],'CreateFcn','movegui center');
h = figure('Visible','On','position',figpos);
%%pause to avoid crashes
%pause(pause_length);

% show the bright field image
switch Experiment
    case 'Nanopillar'
        hs1 = subplot('position',[0.04,0.55,0.16,0.40]);
        plot(CF(:,1).*PixelS,CF(:,2).*PixelS,'-k','LineWidth',1.5);
        hold on;
        tDiam = text(Center(1).*PixelS,Center(2).*PixelS,...
            [num2str(round(Radius*2*PixelS)) 'nm']);
        tDiam_pos = get(tDiam,'Position');
        set(tDiam,'Position',[tDiam_pos(1)-100 tDiam_pos(2) tDiam_pos(3)]);
        hold on;
        colorCodeTracePlot(RawTrajTime,RawTraj(:,2:3).*PixelS,1.5);
        xlabel('X (nm)');
        ylabel('Y (nm)');
        c = colorbar;
        c.Label.String = 'Trajectory Time (s)';
        axis equal;
        set(gca,'Box','Off','TickDir','Out','XColor',[0 0 0],'YColor',[0 0 0],'LineWidth',1.3,'FontSize',10);

    otherwise
        hs1 = subplot('position',[0.03,0.36,0.18,0.60]);
        imshow(ImBF,[median(ImBF(:)),max(ImBF(:))]);
        colormap('Gray');
        freezeColors;
        hold on
        switch Experiment
            case '2D_Tracking'
                % plot the radius range within 70% range of the center
                Y = size(ImBF,1);
                xline(RangeX(1),'-r');
                xline(RangeX(2),'-r');
        end
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
            
%             %pause to avoid crashes
%             pause(pause_length);
            responseLong=MFquestdlg(questdlgpos,['Select the middle of the cell in long axis'], ...
                'Select', 'Okay' , 'Useall','Bad Trajectory','Okay');
            if strcmp(responseLong,'Okay')
                [Xl, Yl] = ginput(2);
            elseif strcmp(responseLong,'Useall')
                Xl = [min(Time),max(Time)];
            else
                close(h);
                disp('User terminated the session since the trajectory is not great!');
                return;
                
            end

            IndexL = find(Time > min(Xl) & Time < max(Xl));
            MeanY = mean(TraceY(IndexL));
            Y_up = MeanY + Threshold.Ynoise; % upper bound of the long axis
            Y_down = MeanY - Threshold.Ynoise; % lower bound of the long axis
            yline(Y_up,'r','Upper bound')
            yline(Y_down,'r','Lower bound')
            IndexY = find(TraceY>=Y_down & TraceY<=Y_up);
            hold on
            plot(Time(IndexY),TraceY(IndexY)-min(MeanY,50),'-.r','linewidth',1.5)

%             %pause to avoid crashes
%             pause(pause_length);
            responseLongC=MFquestdlg(questdlgpos,['Is the selected region good?'],'Selection check', 'Yes' ,'No','Yes');
            if strcmp(responseLongC,'Yes')
                YaxisCheck = 1;
                Time_TY = Time(IndexY);
                TraceX_TY = TraceX(IndexY);
                TraceY_TY = TraceY(IndexY);
            end
        end
end

switch Experiment
    case 'Nanopillar'
        Time_TY = Time;
        TraceX_TY = TraceTheta;
        TraceX = TraceTheta;
end


% plot the trajectory along short axis
hs2 = subplot('position',[0.26,0.36,0.70,0.63]);
handles.hs2 = hs2;
guidata(h,handles);
% plot(Time,TraceX,'-b','linewidth',1.5);
colorCodeTracePlot(Time_TY, [Time_TY,TraceX_TY],1.5)
switch Experiment
    case 'Nanopillar'
        xlim(Threshold.TimeRange);
        ylim(Threshold.Thetas)
    case '2D_Tracking'
        xlim(TimeRange)
        ylim(PosiXRang)
    case '3D_Tracking'
        xlim(Threshold.TimeRange);
        if Threshold.TraceXrange(1) < -1000 & Threshold.TraceXrange(2) > 1000;
            ylim(PosiXRang);
        elseif Threshold.TraceXrange(1) < -1000;
            ylim([-1000, Threshold.TraceXrange(2)]);
        elseif Threshold.TraceXrange(2) > 1000;
            ylim([Threshold.TraceXrange(1),1000]);
        end
end
ylabel('Septal Position(nm)');
hold on
plot(Time,TraceX,'+k');
plot(Time_TY,TraceX_TY,'ok');
switch Experiment
    case '2D_Tracking'
    yline((RangeX(1)-Center(1))*PixelS,'r');
    yline((RangeX(2)-Center(1))*PixelS,'r');
end
set(gca,'xtick',[],'xticklabel',[],'XColor','k','YColor','k','TickDir','Out')
box on
grid on

switch Experiment
    case 'Nanopillar'
        rho_residuals = IndTrack(Index).rho_residuals;
        hs3 = subplot('position',[0.26,0.05,0.70,0.27]);
        hold off;
        pResid = plot(Time,rho_residuals.*PixelS,'.k','Color',rgb('FireBrick'),'MarkerSize',10);
        xlim(Threshold.TimeRange);
        hold on;
        yline(0,'--k','Color',rgb('MidnightBlue'),'LineWidth',1.5);
        hold on;
        for k = 1 : length(rho_residuals)
          yActual = rho_residuals(k).*PixelS;
          yFit = 0;
          x = Time(k);
          line([x, x], [yFit, yActual], 'Color', rgb('FireBrick'),'LineWidth',1);
          hold on;
        end
        hold on;
        pRhoResMean = plot(linspace(min(Time),max(Time),200),repmat(mean(rho_residuals.*PixelS), 1, 200, 1),...
            '--k','LineWidth',1.3,'Color',rgb('SteelBlue'));
        ylabel('Residual Distance (nm)');
        set(gca,'XColor','k','YColor','k','Box','Off','TickDir','Out','LineWidth',1.3,'xtick',[],'xticklabel',[])
end
        
% start segmentation
Istate = 1; % state counter
EndFlag = 1; % the flag to end the selection
while EndFlag ~= 0
%     %pause before dlg to avoid crashes
%     pause(pause_length);
    response=MFquestdlg(questdlgpos,['Select the ' num2str(Istate) 'state in the trace'], ...
        'Select a state?', 'Yes' , 'No','Yes');
    if strcmp(response,'Yes')
        SelectFlag = 0;  % flag for saving one selection
        while SelectFlag == 0
            period = find(IndTrack(Index).file == '.');
            FigSave = ['Ind-' num2str(Index) '-Str-' IndTrack(Index).StrainName '-' IndTrack(Index).file(1:8) '-' IndTrack(Index).file(period-2:period-1) '-seg-' num2str(Istate) '.jpg'];
            set(h, 'currentaxes', hs2);
            [X, Y] = ginput(2);
            X_1 = min(X);
            X_2 = max(X);
            hold on
            IndexT = find (Time_TY>= X_1 & Time_TY <= X_2);
            TimeT_TXY = Time_TY(IndexT);
            %       TimeState = (TimeT(end) - TimeT(1))*ExpT;
            TraceTx = TraceX_TY(IndexT);
            switch Experiment
                case {'2D_Tracking','3D_Tracking'}
                TraceTy = TraceY_TY(IndexT);
                [FitTraceY, pY, DisplY, StDY, RatioY] = linfitR(TimeT_TXY,TraceTy);
                Vy = pY(1);
            end
            %       single fitting
            [FitTraceX, pX, DisplX, StDX, RatioX] = linfitR(TimeT_TXY,TraceTx);
            Vx = pX(1);
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
            
            hs4 = subplot('position',[0.04,0.06,0.15,0.25]);
            hold off
            plot(hRVx(2:end-1),hRV(2:end-1),'g-','linewidth',1.5);
            hold on
            plot(hR0x(2:end-1),hR0(2:end-1),'r-','linewidth',1.5);
            xline(Ratio_region(1),'k','linewidth',2);
            xline(Ratio_region(2),'k','linewidth',2);
            xlabel('Ratio');
            ylabel('Freq');
            set(gca,'Box','Off','TickDir','Out','LineWidth',1.1,'XColor','k','YColor','k');
            title(['V = ' num2str(Vxboot(1),2) '; R=' num2str(RatioXboot(1),2) ';P-progress = ' num2str(P_directional,2)]);
            
            % ask whether it is okay to select this

%             pause(pause_length);
            response=MFquestdlg(questdlgpos,'Is this selection okay?', ...
                'Check', 'Yes' , 'No','Yes');
            if strcmp(response,'Yes')
%                 if isfield(Input_Params, 'img_pathname')
%                     img_pathname = Input_Params.img_pathname;
%                     img_path = fullfile(img_pathname, FigSave);
%                 else
%                     if 7 ~= exist('SegmentedTrajs','dir')
%                         mkdir('SegmentedTrajs');
%                     end
%                     img_path = [pwd '/SegmentedTrajs/' FigSave];
%                 end

                img_pathname = Input_Params.img_pathname;
                img_path = fullfile(img_pathname, FigSave);
                saveas(h, img_path,'jpg');
                %puase(0.5)
                StateFit(Istate).P0 = P_0;
                StateFit(Istate).PV = P_V;
                StateFit(Istate).P_progressive = P_directional;
                StateFit(Istate).Time = TimeT_TXY;
                StateFit(Istate).Xposi = TraceTx;
                StateFit(Istate).Xfit = FitTraceX;
                StateFit(Istate).Yposi = TraceTx;
                StateFit(Istate).Vx = Vx;
                StateFit(Istate).Displx = DisplX;
                StateFit(Istate).SDx = StDX;
                StateFit(Istate).Vxboot = Vxboot;
                StateFit(Istate).DisplXboot = DisplXboot;
                StateFit(Istate).StDXboot = StDXboot;
                StateFit(Istate).RatioXboot = RatioXboot;
                StateFit(Istate).DwellT =  TimeT_TXY(end)-TimeT_TXY(1);
                switch Experiment
                    case {'2D_Tracking','3D_Tracking'}
                       StateFit(Istate).Yfit = FitTraceY; 
                       StateFit(Istate).Vy = Vy;
                       StateFit(Istate).Disply = DisplY;
                       StateFit(Istate).SDy = StDY;
                end
                Istate = Istate + 1;
                IndTrack(Index).StateFit = StateFit;
                SelectFlag = 1;
            else
                delete(hx1);
                delete(hx2);
                delete(hy);
                delete(hy1);
                delete(hy2);

                if Istate == 1
                %If user does not pick ANY seg for the index, overwrite all
                %previous segs at that index. (for reviewing bad trajs.)
                    IndTrack(Index).StateFit = [];
                end
            end
        end
    else
        EndFlag = 0;
    end
    
end
clear StateFit
save(Ind_path,'IndTrack','Threshold_all');
close(h);
end