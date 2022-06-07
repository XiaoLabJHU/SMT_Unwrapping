% Code for tracking attrition over the course of the pipeline




Intens = [];
Tracksnew = [];
TF = handles.COOR.tracksFinal;
for idxT=1:length(TF)
    % load the current frame info
    Track = TF(idxT).Coord;
    % rescale the unit
    Track(:,2:4) = Track(:,2:4)/handles.pxSize;
    Tracksnew(idxT).Coordinates = Track; 
    Tracksnew(idxT).Index=idxT;% the index from the original structure
    Intens(idxT) = mean(Track(:,5));
    % plot all the traces
    plot(Track(:,2),Track(:,3),'- .' , 'LineWidth',0.5,'MarkerSize',5);
end

hold off;
handles.Tracksnew=Tracksnew;
handles.Intens=Intens;
% initial the intensity range and refined trace sturcture
handles.Max_value=max(Intens);
handles.Min_value=min(Intens);
handles.TracksRefine=Tracksnew;
% create the structure of selection
handles.TracksSelect=handles.TracksRefine;
% show the histogram of the intenisty
