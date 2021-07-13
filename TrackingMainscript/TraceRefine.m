function varargout = TraceRefine(varargin)
% TRACEREFINE MATLAB code for TraceRefine.fig
%      TRACEREFINE, by itself, creates a new TRACEREFINE or raises the existing
%      singleton*.
%
%      H = TRACEREFINE returns the handle to a new TRACEREFINE or the handle to
%      the existing singleton*.
%
%      TRACEREFINE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACEREFINE.M with the given input arguments.
%
%      TRACEREFINE('Property','Value',...) creates a new TRACEREFINE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TraceRefine_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TraceRefine_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TraceRefine

% Last Modified by GUIDE v2.5 13-Jul-2021 16:59:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TraceRefine_OpeningFcn, ...
                   'gui_OutputFcn',  @TraceRefine_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before TraceRefine is made visible.
function TraceRefine_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TraceRefine (see VARARGIN)

% Choose default command line output for TraceRefine
handles.output = hObject;
handles.pxSize = 160;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TraceRefine wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TraceRefine_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Load_BF.
function Load_BF_Callback(hObject, eventdata, handles)
% hObject    handle to Load_BF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load and save the image name and pathname/filename 
pxSize = handles.pxSize;
[filename pathname]=uigetfile('*.tif','select the bright field image');
ImBF=imread([pathname filename],'tif');
% show this image in the figure
axes(handles.image);
imshow(ImBF,[]);
hold all
% show the filename to the text
set(handles.BF_name,'String',[pathname filename]);
% save variable 
handles.ImBF=ImBF;
handles.BFpath=pathname;
handles.BFfile=filename;

handles.output = hObject;
% update the data
guidata(hObject, handles);

% --- Executes on button press in Load_trace.
function Load_trace_Callback(hObject, eventdata, handles)
% hObject    handle to Load_trace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load the structure of traces
pxSize = handles.pxSize;
[filename pathname]=uigetfile('*.mat','input the trace struucture from u-tracker');
load([pathname filename]);
handles.Tracksource=[pathname filename];
handles.trackFinal=tracksFinal;
% reconstruction the structure of tracks
if isfield(handles, 'ImBF')
    axes(handles.image);
    imshow(handles.ImBF,[]);
    hold all
else
    errordlg('You need to load the BF first!','Input Error');
    return;
end
    Intens = [];
for idxT=1:length(tracksFinal)
    % load the current frame info
    Track = tracksFinal(idxT).Coord;
    % rescale the unit
    Track(:,2:4) = Track(:,2:4)/pxSize;
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
[HistI(:,2),HistI(:,1)]=hist(Intens,[min(Intens):20:max(Intens)+1]);
handles.HistI=HistI;
axes(handles.Hist_image);
bar(HistI(:,1),HistI(:,2),'LineWidth',1.1,...
    'FaceColor',[0.859375,0.859375,0.859375],'EdgeColor',[0 0 0]);
set(gca,'Box','Off','LineWidth',1.3,'XColor',[0 0 0],'YColor',[0 0 0],'TickDir','Out');
%set(handles.Hist_image,'xlim',[min(Intens),max(Intens)]);
set(handles.Maxslider_value,'String',max(Intens));
set(handles.Minslider_value,'String',min(Intens));
set(handles.Max_slider,'Value',1);
set(handles.Min_slider,'Value',0)
% show the mean and peak value of Intensity
Mean_value=mean(Intens);
set(handles.Mean_value,'string',Mean_value);
Pidx=find((HistI(:,2)==max(HistI(:,2))));
Peak_value=HistI(Pidx,1);
set(handles.Peak_value,'string',Peak_value);
set(handles.BF_name,'String',[pathname filename]);
% save the data
guidata(hObject, handles);    

% --- Executes on button press in Save_image.
function Save_image_Callback(hObject, eventdata, handles)
% hObject    handle to Save_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% save the image with traces to the harddriver

[filename pathname]=uiputfile('*.tif','save current figure');
saveas(gcf,[pathname filename],'tif');
% close(gcf);
% update the data
guidata(hObject, handles);

% --- Executes on slider movement.
function Max_slider_Callback(hObject, eventdata, handles)
% hObject    handle to Max_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% get the current value of the max and min
Max_p=get(handles.Max_slider,'Value');
Min_p=get(handles.Min_slider,'Value');
if Max_p<=Min_p
    errordlg('Too small!','Range Error');
    set(handles.Refine_Inten,'Enable','off');
    return
end
% get the real range 
Range=[handles.HistI(1,1),handles.HistI(end,1)];
Max_value=Max_p*(Range(2)-Range(1))+Range(1);
Min_value=Min_p*(Range(2)-Range(1))+Range(1);
% update the max value
set(handles.Maxslider_value,'String',Max_value);
% updata the xscale of the histogram
set(handles.Hist_image,'xlim',[Min_value,Max_value]);
handles.Max_value=Max_value;
handles.Min_value=Min_value;
set(handles.Refine_Inten,'Enable','on');
% update data
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Max_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Max_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Executes on slider movement.
function Min_slider_Callback(hObject, eventdata, handles)
% hObject    handle to Min_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% get the current value of the max and min
Max_p=get(handles.Max_slider,'Value');
Min_p=get(handles.Min_slider,'Value');
if Max_p<=Min_p
    errordlg('Too Big!','Range Error');
    set(handles.Refine_Inten,'Enable','off');
    return
end
% get the real range 
Range=[handles.HistI(1,1),handles.HistI(end,1)];
Max_value=Max_p*(Range(2)-Range(1))+Range(1);
Min_value=Min_p*(Range(2)-Range(1))+Range(1);
% update the max value
set(handles.Minslider_value,'String',Min_value);
% updata the xscale of the histogram
set(handles.Hist_image,'xlim',[Min_value,Max_value]);
handles.Max_value=Max_value;
handles.Min_value=Min_value;
set(handles.Refine_Inten,'Enable','on');
% update data
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Min_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Min_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in Refine_Inten.
function Refine_Inten_Callback(hObject, eventdata, handles)
% hObject    handle to Refine_Inten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'ImBF')
errordlg('You need to load the BF first!','Input Error');
return;
end
if ~isfield(handles,'Tracksnew')
errordlg('You need to load the trace structure!','Input Error');
return;
end
% choose the traces in the intenisty range
if handles.Max_value<=handles.Min_value
    errordlg('Your min intenisty is bigger than the max!','Range Error');
end
cst=1;
handles.TracksRefine=[];
% reshow the image
    axes(handles.image);
    hold off
    imshow(handles.ImBF,[]);
    hold all
for ii=1:length(handles.Tracksnew)
            Track=handles.Tracksnew(ii).Coordinates;
    if handles.Intens(ii)>handles.Min_value & handles.Intens(ii)<handles.Max_value
        handles.TracksRefine(cst,1).Coordinates=Track;
        handles.TracksRefine(cst,1).Index=handles.Tracksnew(ii).Index;
        cst=cst+1;
        plot(Track(:,2),Track(:,3),'- .' , 'LineWidth',0.5,'MarkerSize',5);
    end
end
% create the structure of selection
handles.TracksSelect=handles.TracksRefine;
% updata data
guidata(hObject, handles);
    
% --- Executes on button press in Selection1.
function Selection1_Callback(hObject, eventdata, handles)
% hObject    handle to Selection1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check the data is exsit
if ~isfield(handles,'TracksSelect')
errordlg('Please load the traces and do the intensity refine first!','Input Error');
return;
end
Tracksnew=handles.Tracksnew;
% caluclate the center of every trace(x and y plane), Z won't be considered
for idx=1:length(handles.TracksSelect)
    Mean_position=mean(handles.TracksSelect(idx).Coordinates,1);
    Track_Center(idx,1:2)=Mean_position(2:3);
    Track_Center(idx,3)=handles.TracksSelect(idx).Index;
end
handles.Track_Center=Track_Center;
% update the image using the center of the tracks
axes(handles.image);
hold off
imshow(handles.ImBF,[]);
hold on
%scatter(Track_Center(:,1),Track_Center(:,2),5,'r');
for idxT=1:length(Tracksnew)
    % load the current frame info
    Track = Tracksnew(idxT).Coordinates;
    % plot all the traces
    plot(Track(:,2),Track(:,3),'-.' , 'LineWidth',3,'MarkerSize',5);
end
%
response=questdlg('Left click get each vertex, double click on the first vertex to complete one ROI', ...
                  'Select the ROI you want', 'Select' , 'Finished','Finished');
% initialize the reference image
[Im_X Im_Y]=size(handles.ImBF);
cell0=logical(zeros(Im_X,Im_Y));
TrackROI=[];
while ~strcmp(response,'Finished')    
    axes(handles.image);
    [cell,Ver_x,Ver_y]=roipoly;
    response=questdlg('Select the next ROI', ...
                  'Select the ROI you want', 'ReSelect', 'Select' , 'Finished','Finished');
    if ~strcmp(response,'ReSelect')
            cell0=cell|cell0;
            hold on
            plot(Ver_x,Ver_y,'-y');
    end

end
Area=sum(sum(cell0))/(Im_X*Im_Y);
cst=1;
for idxT=1:size(Track_Center,1)
    Center_location=Track_Center(idxT,:);
    C_x=round(Center_location(1));
    C_y=round(Center_location(2));
%     cell0(C_x,C_y)
    if cell0(C_y,C_x)==1
        Local_Index=Center_location(3);
        TrackROI(cst,1).Coordinates=double(Tracksnew(Local_Index).Coordinates); 
        TrackROI(cst,1).Index=Local_Index;% the index from the original structure
        axes(handles.image);
        %TrackROI(cst,1).CoordSource=handles.Tracksource;
        hold on
        plot(TrackROI(cst,1).Coordinates(:,2),TrackROI(cst,1).Coordinates(:,3),'-b','LineWidth',2);
        cst=cst+1;
    end
end

if cst==1
    errordlg('No trace selected!','redo the selection');
    return;
end
handles.region=cell0;
handles.TracksROI=TrackROI;
handles.Area=Area;
    
% imshow(cell0);
% update data
guidata(hObject, handles);

% --- Executes on button press in Selection2.
function Selection2_Callback(hObject, eventdata, handles)
% hObject    handle to Selection2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Save_trace.
function Save_trace_Callback(hObject, eventdata, handles)
% hObject    handle to Save_trace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check the structure exist or not
% pxSize = handles.pixelSize;
if ~isfield(handles,'TracksROI')
    errordlg('Please select first','Nothing to save');
    return;
end
[filename pathname]=uiputfile('.mat','save the selected traces');
varname=['tracksRefine'];%filename(1:find(filename=='.')-1);
eval([varname '=[];']);
eval([varname '.Area = handles.Area;']);
eval([varname '.region=handles.region;']);
eval([varname '.TracksROI=handles.TracksROI;']);
BFsource=[handles.BFpath handles.BFfile];
eval([varname '.BFsource=BFsource;']);
eval([varname '.Tracksource=handles.Tracksource;']);
eval([varname '.TracksALL=handles.Tracksnew;']);
save([pathname filename],varname);

% save the ROI image
filenameI = ['Select-' filename(1:find(filename == '.')-1) '.tif'];
% [filename pathname]=uiputfile('*.tif','save current figure');
saveas(gcf,[pathname filenameI],'tif');


% --- Executes on button press in Show_trace.
function Show_trace_Callback(hObject, eventdata, handles)
% hObject    handle to Show_trace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ToCombine.
function ToCombine_Callback(hObject, eventdata, handles)
% hObject    handle to ToCombine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf);
DataCombine;

% --- Executes on button press in undo.
function undo_Callback(hObject, eventdata, handles)
% hObject    handle to undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function pixSize_Callback(hObject, eventdata, handles)
% hObject    handle to pixSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pixSize as text
%        str2double(get(hObject,'String')) returns contents of pixSize as a double
pixelSize = str2double(get(hObject,'String'));
handles.pxSize = pixelSize;
% update data
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function pixSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
