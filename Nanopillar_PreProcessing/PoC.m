function PoC(BFfilename, BFpathname, TRfilename, TRpathname, TraceThresh)


load([TRpathname TRfilename]);
[ImageBF,map] = imread([BFpathname BFfilename]);
TrackROI = tracksRefine.TracksROI;

imshow(ImageBF,[],'InitialMagnification',200);
colormap('Gray');
freezeColors;
hold on;
w = 0;
 for jj =  1: length(TrackROI);
     Trace = TrackROI(jj).Coordinates;
     name = TRfilename;
     fileroot = name(1:find(name=='.')-1)
     filenameP = ['Plot over Cell-' fileroot]; %PoC = Plot over Cell
     if size(Trace,1) > TraceThresh;
        w = w + 1
        xS = [Trace(:,2), Trace(:,2)]; %List the X points
        yS = [Trace(:,3), Trace(:,3)]; %List the Y points
        CoodCent = [xS(:,1),yS(:,1)]; %Define the center of the coordinate plane
        zS = zeros(size(xS)); %For plotting in 2D, define the Z axis with zeros.
        cS = [(Trace(:,1)-min(Trace(:,1))),(Trace(:,1)-min(Trace(:,1)))]; %Color spectrum 
        hs = surf(xS,yS,zS,cS,'EdgeColor','interp','FaceColor','interp','LineWidth',2); %// color binded to "y" values
        view(2); %View the plot in 2D
        colormap(gca,'jet'); %Set a colormap to the current axis.
        cS_scale = cS;
        caxis([min(cS_scale(:,1)), max(cS_scale(:,1))]); %Confines the colormap on each iteration to the min and max of the dataset.
        title(filenameP,'FontSize',12);
        hold on;
    end
 end
     
end