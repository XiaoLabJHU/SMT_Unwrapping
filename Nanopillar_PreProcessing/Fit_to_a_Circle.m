function Fit_to_a_Circle(filenameIN, TRpathname, BFfilename, BFpathname, GFPfilename, GFPpathname);

    %Make a figure with the GFP image and super-imposed BF-Traj image

    %First check to see if there is one TraceRefine or multiple.
    %One TR file will be counted as ''Char'', while multiple would be a
    %structure.
    % convert single file selection
    
    % convert single file selection
    if ~iscell(filenameIn)
        TRfilename{1} = filenameIn;
    else
        TRfilename = filenameIn;
    end
    
    for idxa = 1:length(TRfilename);
        TRname = TRfilename{idxa}
        tracks = load([TRpathname TRname]);
        TracksROI = tracks.tracksRefine.TracksROI;
        file_root = TRname(1:find(TRname=='.')-1);
        file_num = TRname(find(TRname=='-')+1:find(TRname=='.')-1);
        file_ref = TRname(find(TRname=='-')+1:find(TRname=='-')+2);

        BFname = BFfilename{str2num(file_ref)};
        GFPname = GFPfilename{str2num(file_ref)};

        fMain = figure('units','normalized','outerposition',[0 0 1 1],'name','Circle Fit');
        %Plot Trajectories over BF for reference.
        ax2 = subplot(2,2,2);
        PoC(BFname,BFpathname,TRname,TRpathname,10);

        %Plot the GFP image and select the cell to fit.
        ax1 = subplot(2,2,1);
        GFP = imread([GFPpathname GFPname]);
        GFPimage = imshow(mat2gray(GFP));
        title(GFPname(1:find(GFPname=='.')-1),'interpreter','none','FontSize',12);

        axes(ax1);
        questdlg('Please hit ''Select'' to grab a cell.',...
        'Select a cell.','Select','Cancel','Cancel');
        u = drawrectangle('Color',[1 0 0],'FaceAlpha',0,'LineWidth',1);
        rec_488 = u.Position;
        rec_488 = [round(rec_488(1)) round(rec_488(2)) rec_488(3) rec_488(4)]
        I_crop = uint16(imcrop(GFP,rec_488));

        EndFlag = 1; % the flag to end the selection
        while EndFlag ~= 0
            response=questdlg(['Is there a good threshold?'], ...
                'Yes or No.', 'Yes' , 'No','Yes');

            if strcmp(response,'No')
                prompt = {'Enter a threshold between 0 and 1'};
                dlgtitle = 'Input to threshold'
                answer = inputdlg(prompt,dlgtitle);

                %Threshold the cropped GFP region and extract coords of
                %brightest intensity
                [ytemp, xtemp] = find(imbinarize(mat2gray(I_crop),str2num(cell2mat(answer))));

                %Normalize the coordinates so they are 0,0. Makes plotting
                %over easier.
                xbound = xtemp + rec_488(1)-1;
                ybound = ytemp + rec_488(2)-1;

                %Plot the high-intensity points over the pixels.
                hold off;
                clear ax3;
                ax3 = subplot(2,2,3);
                imshow(mat2gray(I_crop));
                hold on;
                scatter(xtemp,ytemp,'ob','LineWidth',1.5);
                set(gca,'Ydir','reverse');
                title('Circle Fit','FontSize',12);

                %Plot the circle over the cropped region.
                hold on;
                Fit = CircleFitByPratt([xtemp,ytemp]);
                th = 0:pi/50:2*pi;
                xCircleGFP = Fit(3) * cos(th) + Fit(1);
                yCircleGFP = Fit(3) * sin(th) + Fit(2);

                pCirc = plot(xCircleGFP,yCircleGFP,'-r','LineWidth',1.5);

                clear ax4;
                ax4 = subplot(2,2,4);
                Fit = CircleFitByPratt([xbound,ybound]);
                th = 0:pi/50:2*pi;
                xCircleGFP = Fit(3) * cos(th) + Fit(1);
                yCircleGFP = Fit(3) * sin(th) + Fit(2);

                CircleFits(idxa).Source = file_root;
                CircleFits(idxa).CircleFitLine = [xCircleGFP yCircleGFP];
                CircleFits(idxa).Radius = Fit(3);
                CircleFits(idxa).CenterCoord = [Fit(1) Fit(2)];

                plot(xCircleGFP,yCircleGFP,'-k','LineWidth',1.5);
                hold on;
                w = 0;

                for jj =  1: length(TracksROI);
                    Trace = TracksROI(jj).Coordinates;
                    filenameP = ['Plot over Fit-' file_root]; %PoC = Plot over Cell
                    w = w + 1
                    xS = [Trace(:,2), Trace(:,2)]; %List the X points
                    yS = [Trace(:,3), Trace(:,3)]; %List the Y points
                    CoodCent = [xS(:,1),yS(:,1)]; %Define the center of the coordinate plane
                    zS = zeros(size(xS)); %For plotting in 2D, define the Z axis with zeros.
                    cS = [(Trace(:,1)-min(Trace(:,1))),(Trace(:,1)-min(Trace(:,1)))]; %Color spectrum 
                    hs = surf(xS,yS,zS,cS,'EdgeColor','interp','FaceColor','interp','LineWidth',1.5); %// color binded to "y" values
                    view(2); %View the plot in 2D
                    colormap(gca,'jet'); %Set a colormap to the current axis.
                    caxis([min(cS(:,1)), max(cS(:,1))]); %Confines the colormap on each iteration to the min and max of the dataset.
                    title(filenameP);
                    hold on;
                end
                axis equal;
                xlabel('X (px)');
                ylabel('Y (px)');
                c = colorbar;
                c.Label.String = 'Trajectory Time (s)';
                set(ax4,'Ydir','reverse','Box','Off','LineWidth',1.3,'FontSize',12,'TickDir','Out','XColor',[0 0 0],'YColor',[0 0 0]);
                hold off;
                clear pCirc;
            else
                EndFlag = 0;
                set(fMain,'PaperUnits','inches','PaperPosition',[0 0 10 10],'PaperSize',[10 10]);
                print(fMain,['CircleFit_GFP-' num2str(file_num) '.pdf'],'-dpdf');
                print(fMain,['CircleFit_GFP-' num2str(file_num) '.png'],'-dpng','-r1200');
                close(fMain);
            end
        end
    end
    save('CircleFits.mat','CircleFits','-v7.3');
end