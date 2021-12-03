function varargout = spotsLinking(varargin)
% SPOTSLINKING MATLAB code for spotsLinking.fig
%      SPOTSLINKING, by itself, creates a new SPOTSLINKING or raises the existing
%      singleton*.
%
%      H = SPOTSLINKING returns the handle to a new SPOTSLINKING or the handle to
%      the existing singleton*.
%
%      SPOTSLINKING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPOTSLINKING.M with the given input arguments.
%
%      SPOTSLINKING('Property','Value',...) creates a new SPOTSLINKING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spotsLinking_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spotsLinking_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spotsLinking

% Last Modified by GUIDE v2.5 25-Jun-2018 10:15:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @spotsLinking_OpeningFcn, ...
    'gui_OutputFcn',  @spotsLinking_OutputFcn, ...
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


% --- Executes just before spotsLinking is made visible.
function spotsLinking_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spotsLinking (see VARARGIN)

% Choose default command line output for spotsLinking
handles.output = hObject;

handles.ST = 400; % spatial threshold
handles.TT = 20;  % time threshold
handles.Wz = 0; % weight of Z position
handles.Wi = 0; % weight of intensity
handles.MinL = 1; % trajectory length lower bound
handles.ZcF = 1; % z position correction factor
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes spotsLinking wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = spotsLinking_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadFile_tag.
function loadFile_tag_Callback(hObject, eventdata, handles)
% hObject    handle to loadFile_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load all the files and calculate the gap distribution
ST = handles.ST; % spatial threshold
TT = handles.TT;  % time threshold
Wz = handles.Wz; % weight of Z position
Wi = handles.Wi; % weight of intensity
MinL = handles.MinL; % trajectory length lower bound
ZcF = handles.ZcF; % z position correction factor

% load trajectory files
[filename pathname] = uigetfile('.csv','Select the spot coordinate list-in THunderSTROM format','multiselect','on');
if length(filename) == 1
    return;
end
if iscell(filename)
    filenameL = filename;
else
    filenameL{1} = filename;
end

% calculate a part of the files to get the gap distribution
for ii = 1:ceil(length(filenameL)/5) % only do 20% of the data
    spot_table = readtable([pathname filenameL{ii}]); %read the .csv file.
    data = spot_table.Variables;
    Frame = data(:,2); % frame number
    Coordxyz = data(:,3:4); % xy-coordinates
    if sum(strcmp(spot_table.Properties.VariableNames,'z_nm_'));
        Coordxyz(:,3) = data(:,5)*ZcF; % z-coordinates
    else
        Coordxyz(:,3) = 0; % z-coordinates
    end
    IndexC = find(strcmp(spot_table.Properties.VariableNames, 'intensity_photon_'));
    Intensity = data(:,IndexC); % spots intensity
    Tn = max(Frame);
    Spots = [];
    for kk = 1:Tn
        Findex = find(Frame == kk);
        FrameT = Frame(Findex,:);
        CoordT = Coordxyz(Findex,:);
        IntensityT = Intensity(Findex,:);
        id = [1:length(Findex)]';
        Coord = [id,CoordT,IntensityT];
        Coord(:,6:9) = 0;
        Spots(kk).Coord = Coord;
        clear Coord
    end
    
    %step 2: optimize and link the spots
    SpotsLink  = gmtOptimize( Spots, TT, ST, Wz, Wi );
    %step 3: construct the trajectory list
    TrajList  = closeLink(SpotsLink);
    %step 4: construct the tracksFinal sttucture
    tracksFinal = trackConv( TrajList );
%     % step 5: save the structures
%     save([pathname filesave],'Spots','tracksFinal');
    % step 6: filter out trajs shorter than TraceL
    tracksFinalL =[];
    kk = 1;
    for il = 1 : length(tracksFinal)
        Coords = tracksFinal(il).Coord;
        if size(Coords,1) >= MinL
            tracksFinalL(kk).Coord = Coords;
            kk = kk+1;
        end
    end
    tracksRaw(ii).tracksFinal = tracksFinalL;
    %     save([pathname filesaveL],'Spots','tracksFinal');
end
handles.tracksRaw = tracksRaw;

% calculate the gap histogram and display
Gap = [];
for ii = 1:length(tracksRaw)
    tracksFinal = tracksRaw(ii).tracksFinal;
    for jj =  1: length(tracksFinal)
        Trace = tracksFinal(jj).Coord;
        if size(Trace,1) > 1
            G = diff(Trace(:,1));
            Gap = [Gap;G];
        end
    end
end
axes(handles.gapDis_tag)
hold off
[GapT GapTx] = hist(Gap,[1:max(Gap)]);
s1 = semilogy(GapTx,GapT,'o-','LineWidth',1.3,'Color',[0.6953125,0.1328125,0.1328125]);
s1.MarkerEdgeColor = [0.54296875,0,0];
s1.MarkerFaceColor = [0.979166666666667,0.5,0.4453125];
title(['Mean Lifetime = ' num2str(mean(Gap)) 's']);
xlabel('Off Time (Frame)');
ylabel('Events');
set(gca,'Box','Off','LineWidth',1.5,'FontSize',12,'TickDir','out','XColor','k','YColor','k')
set(handles.figure1,'PaperUnits','inches','PaperPosition',[0 0 11.5 6.5],'PaperSize',[11.5 6.5]);
print(handles.figure1,['Gap_Distribution-' num2str(max(Gap)) '.pdf'],'-dpdf');
% save the filenames
handles.filename = filenameL;
handles.pathname = pathname;
% Update handles structure
guidata(hObject, handles);


function SpacialTh_tag_Callback(hObject, eventdata, handles)
% hObject    handle to SpacialTh_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SpacialTh_tag as text
%        str2double(get(hObject,'String')) returns contents of SpacialTh_tag as a double
handles.ST = str2double(get(hObject,'String')); % spatial threshold
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SpacialTh_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpacialTh_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timeTH_tag_Callback(hObject, eventdata, handles)
% hObject    handle to timeTH_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeTH_tag as text
%        str2double(get(hObject,'String')) returns contents of timeTH_tag as a double
handles.TT = str2double(get(hObject,'String'));  % time threshold
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function timeTH_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeTH_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Zweight_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Zweight_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Zweight_tag as text
%        str2double(get(hObject,'String')) returns contents of Zweight_tag as a double
handles.Wz = str2double(get(hObject,'String')); % weight of Z position
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Zweight_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Zweight_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Iweight_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Iweight_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Iweight_tag as text
%        str2double(get(hObject,'String')) returns contents of Iweight_tag as a double
handles.Wi = str2double(get(hObject,'String')); % weight of intensity
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Iweight_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Iweight_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function traceL_tag_Callback(hObject, eventdata, handles)
% hObject    handle to traceL_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of traceL_tag as text
%        str2double(get(hObject,'String')) returns contents of traceL_tag as a double
handles.MinL = str2double(get(hObject,'String')); % trajectory length lower bound
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function traceL_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to traceL_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Relink_tag.
function Relink_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Relink_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load all the files and calculate the gap distribution
ST = handles.ST; % spatial threshold
TT = handles.TT;  % time threshold
Wz = handles.Wz; % weight of Z position
Wi = handles.Wi; % weight of intensity
MinL = handles.MinL; % trajectory length lower bound
ZcF = handles.ZcF; % z position correction factor
pathname = handles.pathname;
filename = handles.filename;

% link the spots and save the files
h = waitbar(0,'Link the molecules...');
for ii = 1:ceil(length(filename)) % only do 20% of the data
    filecurr = filename{ii};
    fileroot = filecurr(1:find(filecurr=='.')-1);
    filesave = ['Coord-' fileroot '.mat'];
    filesaveL = ['long-' num2str(MinL) '-Coord-' fileroot '.mat'];
    spot_table = readtable([pathname filename{ii}]); %read the .csv file.
    data = spot_table.Variables;
    Frame = data(:,2); % frame number
    Coordxyz = data(:,3:4); % xy-coordinates
    if sum(strcmp(spot_table.Properties.VariableNames,'z_nm_'));
        Coordxyz(:,3) = data(:,5)*ZcF; % z-coordinates
    else
        Coordxyz(:,3) = 0; % z-coordinates
    end
    IndexC = find(strcmp(spot_table.Properties.VariableNames, 'intensity_photon_'));
    Intensity = data(:,IndexC); % spots intensity
    Tn = max(Frame);
    Spots = [];
    Coord = [];
    for kk = 1:Tn
        Findex = find(Frame == kk);
        FrameT = Frame(Findex,:);
        CoordT = Coordxyz(Findex,:);
        IntensityT = Intensity(Findex,:);
        id = [1:length(Findex)]';
        Coord = [id,CoordT,IntensityT];
        Coord(:,6:9) = 0;
        Spots(kk).Coord = Coord;
    end
    
    %step 2: optimize and link the spots
    SpotsLink  = gmtOptimize( Spots, TT, ST, Wz, Wi );
    %step 3: construct the trajectory list
    TrajList  = closeLink(SpotsLink);
    %step 4: construct the tracksFinal sttucture
    tracksFinal = trackConv( TrajList );
    % step 5: save the structures
    save([pathname filesave],'Spots','tracksFinal');
    % step 6: filter out trajs shorter than TraceL
    tracksFinalL =[];
    kk = 1;
    for il = 1 : length(tracksFinal)
        Coords = tracksFinal(il).Coord;
        if size(Coords,1) >= MinL
            tracksFinalL(kk).Coord = Coords;
            kk = kk+1;
        end
    end
    tracksFinal = tracksFinalL;
    save([pathname filesaveL],'Spots','tracksFinal');
    waitbar(ii/length(filename),h,'Linking the molecules...');
end
close(h);


function Zcorr_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Zcorr_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Zcorr_tag as text
%        str2double(get(hObject,'String')) returns contents of Zcorr_tag as a double
handles.ZcF = str2double(get(hObject,'String')); % z position correction factor
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Zcorr_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Zcorr_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in comb_tag.
function comb_tag_Callback(hObject, eventdata, handles)
% hObject    handle to comb_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
kk = 1;
MinL = handles.MinL;
[filename pathname] = uigetfile('.mat', 'select ttajectories','multiselect','on');
if isstring(filename)
    filenameL{1} = filename;
elseif iscell(filename)
    filenameL = filename;
    for ii = 1:length(filename)
        load([pathname filename{ii}])
        for jj =  1: length(tracksFinal)
            Trace = tracksFinal(jj).Coord;
            if size(Trace,1) >= MinL
                trackFinal(kk).Coord = Trace;
                kk = kk + 1;
            end
        end
    end
    tracksFinal = trackFinal;
    [filename1 pathname1] = uiputfile('.mat',['Save the trace file of' filename{1}]);
    save([pathname1 filename1],'tracksFinal');
end
