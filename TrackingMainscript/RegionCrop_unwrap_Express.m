function varargout = RegionCrop_unwrap_Express(varargin)
% REGIONCROP_UNWRAP_EXPRESS MATLAB code for RegionCrop_unwrap_Express.fig
%      REGIONCROP_UNWRAP_EXPRESS, by itself, creates a new REGIONCROP_UNWRAP_EXPRESS or raises the existing
%      singleton*.
%
%      H = REGIONCROP_UNWRAP_EXPRESS returns the handle to a new REGIONCROP_UNWRAP_EXPRESS or the handle to
%      the existing singleton*.
%
%      REGIONCROP_UNWRAP_EXPRESS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGIONCROP_UNWRAP_EXPRESS.M with the given input arguments.
%
%      REGIONCROP_UNWRAP_EXPRESS('Property','Value',...) creates a new REGIONCROP_UNWRAP_EXPRESS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RegionCrop_unwrap_Express_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RegionCrop_unwrap_Express_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RegionCrop_unwrap_Express

% Last Modified by GUIDE v2.5 04-Aug-2021 15:43:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @RegionCrop_unwrap_Express_OpeningFcn, ...
    'gui_OutputFcn',  @RegionCrop_unwrap_Express_OutputFcn, ...
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


% --- Executes just before RegionCrop_unwrap_Express is made visible.
function RegionCrop_unwrap_Express_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RegionCrop_unwrap_Express (see VARARGIN)

% initialize
handles.ROInum=0;                           % number of ROIs
handles.ROIinfo=[];                         % the coordinates of ROI vertex
handles.Datahandle=handles.listbox1;        % handle to set appdata
handles.ROIlist=[];                         % list of ROIs
setappdata(handles.Datahandle,'CellInformation',[]); % initialize appdata
handles.pixelS = 81.25;

handles.Date = datestr(now,'yyyymmdd');
set(handles.edit3, 'String', handles.Date);

% handles.RfTr_dir = uigetdir([],'Choose refined trajectory folder');
% %handles.OUT_dir = uigetdir(handles.ROOT_dir, 'Choose refined tracjectory (output) folder');
% cd(handles.RfTr_dir);
% handles.RfTr_files = dir('*.mat');
% handles.num_RfTr = length(handles.RfTr_files);
% 
% set(handles.idx_slider, 'max', handles.num_RfTr);
% set(handles.idx_slider, 'Value', 1);
% sliderStep = [1, 1] / (handles.num_RfTr - 1);
% set(handles.idx_slider, 'SliderStep', sliderStep);
% 
% set(handles.idx_box, 'Value', 1);
% 
% handles = load_data_at_index(hObject, handles);
% %handles = guidata(hObject);

% Choose default command line output for RegionCrop_unwrap_Express
handles.output = hObject;
movegui(gcf,'center');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RegionCrop_unwrap_Express wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function handles = load_data_at_index(self, handles)

i = str2double(get(handles.idx_box,'String'));

RfTr_name = handles.RfTr_files(i).name;
%handles.BF_tag = handles.BF_name(end-5:end-4);
handles.RfTr_path = [handles.RfTr_dir '\' RfTr_name];
load(handles.RfTr_path);
pixelS = handles.pixelS;
handles.tracks = tracksRefine.TracksROI;
handles.BF_path = tracksRefine.BFsource;

%Load_BF1_Callback(handles.Load_BF1, eventdata, handles);
%handles = guidata(handles.Load_BF1);

ImBF = imread(handles.BF_path);
%set(handles.BF_name,'String',handles.BF_path);
[pathname, name, ext] = fileparts(handles.BF_path);
filename = [name ext];

% change the image to double
ImBF2 = double(ImBF);
% show this image in the figure
axes(handles.image);
hold off
imshow(ImBF2,[]);
% save variables

% handles.curr_image=ImBF1;
handles.ImBF = ImBF2;

set(handles.BF_name,'String',[pathname filename]);
% save variable
% handles.ImBF1=ImBF1;
handles.BF1path=pathname;
handles.BF1file=filename;

axes(handles.image);
hold on
handles.trackP = [];
for ii = 1 : length(handles.tracks)
    trace = handles.tracks(ii).Coordinates;    
                                                     % 
    plot(trace(:,2),trace(:,3),'LineWidth',3);
    handles.trackP(ii,1).XYCoord = trace(:,2:3) + 0.5; % extract the x-y coordinates and convert to pixel unit
    % plus 0.5 because the thunderstorm thinks the topleft corner of a image is [0,0] while matlab thinks it is [0.5,0.5]
    handles.trackP(ii,1).XYCenter = mean( trace(:,2:3) + 0.5,1); % find the center of each trace
    handles.trackP(ii,1).Time = trace(:,1);
    handles.trackP(ii,1).Intensity = trace(:,5);
end
hold off

%set(handles.saved_text,'String', handles.OUT_paths(i));

%Clear tracks from previous image

% Update handles structure
%handles.output = hObject;

guidata(self, handles);

% --- Outputs from this function are returned to the command line.
function varargout = RegionCrop_unwrap_Express_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Load_BF1.
function Load_BF1_Callback(hObject, eventdata, handles)
% hObject    handle to Load_BF1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load and save the image name and pathname/filename
if isfield(handles,'BF_path')
    ImBF = imread(handles.BF_path);
    %set(handles.BF_name,'String',handles.BF_path);
    [pathname, name, ext] = fileparts(handles.BF_path);
    filename = [name ext];
else
    [filename pathname]=uigetfile('*.tif','select the bright field image');
    ImBF = imread([pathname filename]);
    %set(handles.BF_name,'String',[pathname filename]);
end
% change the image to double
ImBF2 = double(ImBF);
% show this image in the figure
axes(handles.image);
hold off
imshow(ImBF2,[]);
% save variables

% handles.curr_image=ImBF1;
handles.ImBF = ImBF2;

set(handles.BF_name,'String',[pathname filename]);
% save variable
% handles.ImBF1=ImBF1;
handles.BF1path=pathname;
handles.BF1file=filename;

handles.output = hObject;

% update the data
guidata(hObject, handles);

% --- Executes on button press in Selection1.
function Selection1_Callback(hObject, eventdata, handles)
% hObject    handle to Selection1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check the image is exsit
if ~isfield(handles,'ImBF')
    errordlg('You need to load the bright field image first!','Input Error');
    return;
end

if ~isfield(handles,'trackP')
    errordlg('You need to load the structure of trajectories!','Input Error');
    return;
end
% load the bf image
ImBF = handles.ImBF;
TrackP = handles.trackP;

% show the BF
axes(handles.image);
imshow(ImBF,[]); % show the bf image
hold on
for ii = 1 : length(TrackP) % plot the traces
    trace = TrackP(ii).XYCoord;    
    plot(trace(:,1),trace(:,2),'LineWidth',3);
end
% present the exsited ROIs
if handles.ROInum>0
    for ii=1:handles.ROInum
        hold on
        ROI_t = handles.ROIinfo(ii).ROI;
        plot(ROI_t(:,1),ROI_t(:,2),'-g');
        text((ROI_t(1,1)+ROI_t(2,1))/2,(ROI_t(1,2)+ROI_t(3,2))/2,num2str(ii),'color','g');
    end
end
% select rectangle ROI
[X,Y] = ginput(2); % make sure get an integer for both X and Y boundary
X = round(X);
Y = round(Y);
% get the vertex of the rectangle
Vx = [X(1);X(2);X(2);X(1);X(1)];
Vy = [Y(1);Y(1);Y(2);Y(2);Y(1)];
ROI = cat(2,Vx,Vy);
ROI_BF = ImBF(ROI(2,2):ROI(3,2),ROI(1,1):ROI(2,1),:);

hold on
plot(Vx,Vy,'-y');
response=questdlg('Use the current ROI?', ...
    'ROI selection', 'Yes' , 'No','Yes');
if  strcmp(response,'Yes')
    % get traces in the ROI
    kk = 1;
    TrackROI = [];
    for jj = 1 : length(TrackP)
        xyCenter = TrackP(jj).XYCenter;
        if xyCenter(1) > min(X) & xyCenter(1) < max(X) & xyCenter(2) > min(Y) & xyCenter(2) < max(Y)
            TrackROI(kk,1).XYCoord(:,1) = TrackP(jj,1).XYCoord(:,1) - min(X)+1;
            TrackROI(kk,1).XYCoord(:,2) = TrackP(jj,1).XYCoord(:,2) - min(Y)+1;
            TrackROI(kk,1).XYCenter(:,1) = TrackP(jj,1).XYCenter(1) - min(X)+1;
            TrackROI(kk,1).XYCenter(:,2) = TrackP(jj,1).XYCenter(2) - min(Y)+1; 
            TrackROI(kk,1).Time = TrackP(jj,1).Time;
            TrackROI(kk,1).Intensity = TrackP(jj,1).Intensity;
            kk = kk + 1;
        end
    end
    % rotate the cell and unwrap the cell envelope
    hIC = TraceRotate(ROI_BF,TrackROI,handles.pixelS,handles.Datahandle);
    waitfor(hIC);
    TraceInfo = getappdata(handles.Datahandle,'TraceInformation');
    TraceInfo.Cell.CellPOsition = ROI;
    handles.ROInum=handles.ROInum+1;
    handles.ROIinfo(handles.ROInum).ROI=ROI;
    handles.TraceInfo(handles.ROInum).TraceInfo=TraceInfo;
%     handles.CellInfo(handles.ROInum).ROI=ROI;
    ROI_name=['ROI' num2str(handles.ROInum) '_X' num2str(round(ROI(1,1))) 'Y' num2str(round(ROI(1,2)))];
    handles.ROIlist{handles.ROInum}=ROI_name;
%     value1=get(handles.listbox1,'Value')
    set(handles.listbox1,'String',handles.ROIlist);
%     set(handles.listbox1,'Value',value1+1);
end

% update data
guidata(hObject, handles);


% --- Executes on button press in Load_Traj.
function Load_Traj_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Traj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% load and save the image name and pathname/filename

% [filenameT pathnameT]=uigetfile('*.mat','Select the refined trajectory structure.');
% load([pathnameT filenameT]);
% pixelS = handles.pixelS;
% handles.tracks = tracksRefine.TracksROI;
% handles.BF_path = tracksRefine.BFsource;
% 
% Load_BF1_Callback(handles.Load_BF1, eventdata, handles);
% handles = guidata(handles.Load_BF1);
% 
% axes(handles.image);
% hold on
% handles.trackP = [];
% for ii = 1 : length(handles.tracks)
%     trace = handles.tracks(ii).Coordinates;    
%                                                      % 
%     plot(trace(:,2),trace(:,3),'LineWidth',3);
%     handles.trackP(ii,1).XYCoord = trace(:,2:3) + 0.5; % extract the x-y coordinates and convert to pixel unit
%     % plus 0.5 because the thunderstorm thinks the topleft corner of a image is [0,0] while matlab thinks it is [0.5,0.5]
%     handles.trackP(ii,1).XYCenter = mean( trace(:,2:3) + 0.5,1); % find the center of each trace
%     handles.trackP(ii,1).Time = trace(:,1);
%     handles.trackP(ii,1).Intensity = trace(:,5);
% end
% hold off

handles.RfTr_dir = uigetdir([],'Choose refined trajectory folder');
%handles.OUT_dir = uigetdir(handles.ROOT_dir, 'Choose refined tracjectory (output) folder');
cd(handles.RfTr_dir);
handles.RfTr_files = dir('*.mat');
handles.num_RfTr = length(handles.RfTr_files);

set(handles.idx_slider, 'max', handles.num_RfTr);
set(handles.idx_slider, 'Value', 1);
sliderStep = [1, 1] / (handles.num_RfTr - 1);
set(handles.idx_slider, 'SliderStep', sliderStep);

set(handles.idx_box, 'Value', 1);

handles = load_data_at_index(hObject, handles);

% update the data
guidata(hObject, handles);


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
contents = cellstr(get(hObject,'String'));
if length(contents) >1
curitem=contents{get(hObject,'Value')};
for ii=1:length(contents)
    L=strcmp(curitem,contents{ii});
    if L==1
        handles.curitem=ii;
    end
end
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Data_save_tag.
function Data_save_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Data_save_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% save the data automatically
if ~isfield(handles,'BF1path')
    errordlg('No image loaded!');
    return;end

if ~isfield(handles,'TraceInfo')
    errordlg('Do some analysis first!');
    return;
end
TraceInfo=handles.TraceInfo;
path=handles.BF1path;
name=handles.BF1file;
index=find(name=='.');
% Newfolder=name(1:index-1);
Newname=[handles.Date '-TraceInfo-' name(1:index) 'mat'];
% Folderex=exist(Newfolder,'file');
% if Folderex==0
% mkdir(path,Newfolder);
% end
% pathnew=[path '\' Newfolder '\' Newname];
save(Newname,'TraceInfo');

%DeteALL_Callback(handles.DeteALL, eventdata, handles);
%handles = guidata(handles.DeteALL);

%After data is saved, clear the active traces.
handles.ROIlist=[];    
handles.ROIinfo=[];
handles.TraceInfo=[];
handles.ROInum=0;
set(handles.listbox1,'String',handles.ROIlist);
set(handles.listbox1,'Value',1);

guidata(hObject, handles);


% --- Executes on button press in DeleteTrace.
function DeleteTrace_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ROIname=handles.ROIlist; 
valuenum=get(handles.listbox1,'Value');
if isfield(handles,'curitem')
    Idx=handles.curitem;
    handles.ROInum=handles.ROInum-1;
    ROIname{Idx}=[];
    handles.ROIlist=ROIname(~cellfun('isempty',ROIname));
%     c=handles.ROIlist
    handles.ROIinfo(Idx)=[];
    handles.TraceInfo(Idx)=[];
    set(handles.listbox1,'string',handles.ROIlist);
    set(handles.listbox1,'Value',valuenum-1);
    if valuenum==1
        set(handles.listbox1,'Value',1);
    end
end
guidata(hObject,handles);


% --- Executes on button press in DeteALL.
function DeteALL_Callback(hObject, eventdata, handles)
% hObject    handle to DeteALL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
response=questdlg('Delete all data?','Warning!','Yes','Cancel','Cancel');
if strcmp(response,'Yes')
    handles.ROIlist=[];    
    handles.ROIinfo=[];
    handles.TraceInfo=[];
    handles.ROInum=0;
    set(handles.listbox1,'String',handles.ROIlist);
    set(handles.listbox1,'Value',1);
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function DisplayPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisplayPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
handles.pixelS = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
handles.Date = get(hObject,'String');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

%automatically initializes the text box with today's date

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function idx_slider_Callback(hObject, eventdata, handles)
% hObject    handle to idx_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val=round(hObject.Value);
hObject.Value=val;

set(handles.idx_box,'String',num2str(val));

load_data_at_index(hObject, handles);
handles = guidata(hObject);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function idx_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to idx_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function idx_box_Callback(hObject, eventdata, handles)
% hObject    handle to idx_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of idx_box as text
%        str2double(get(hObject,'String')) returns contents of idx_box as a double

val = str2double(get(hObject,'String'));
set(handles.idx_slider, 'Value', val);

load_data_at_index(hObject, handles);
handles = guidata(hObject);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function idx_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to idx_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
