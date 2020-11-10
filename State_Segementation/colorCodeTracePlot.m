%plot a trajectory colored by time
function colorCodeTracePlot(Time, Trace,linewidth)
% Trace two colomns: X positions and the corresponding Y position
% X has a single column
% linewidth is the thickness of the plot line
% plot the median trajectory in color copied from Josh
xS = [Trace(:,1) ,Trace(:,1)];
yS = [Trace(:,2) ,Trace(:,2)];
zS = zeros(size(xS));
cS = [Time-min(Time),Time-min(Time)];
hs = surf(xS,yS,zS,cS,'EdgeColor','interp'); %// color binded to "y" values
view(2)
colormap(gca,'jet')
caxis([min(cS(:,1)), max(cS(:,1))]);
set(hs,'Linewidth',linewidth)


% hold on
% plot(xS,yS,'ok');
% hold off
