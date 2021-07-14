function varargout = drift_tst(varargin)
% DRIFT_TST MATLAB code for drift_tst.fig
%      DRIFT_TST, by itself, creates a new DRIFT_TST or raises the existing
%      singleton*.
%
%      H = DRIFT_TST returns the handle to a new DRIFT_TST or the handle to
%      the existing singleton*.
%
%      DRIFT_TST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DRIFT_TST.M with the given input arguments.
%
%      DRIFT_TST('Property','Value',...) creates a new DRIFT_TST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before drift_tst_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to drift_tst_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help drift_tst

% Last Modified by GUIDE v2.5 14-Jul-2021 08:26:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @drift_tst_OpeningFcn, ...
                   'gui_OutputFcn',  @drift_tst_OutputFcn, ...
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


% --- Executes just before drift_tst is made visible.
function drift_tst_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to drift_tst (see VARARGIN)

% Choose default command line output for drift_tst
handles.output = hObject;
handles.BF_dir = 'C:\Users\Martin\Xiao Lab Dropbox\Lab Members\Yepes_Martin\Projects\Lytic Transglycolase Project\Images\20210407_MltA-Halo-JF646_SMT\BF';
handles.drift_dir = 'C:\Users\Martin\Xiao Lab Dropbox\Lab Members\Yepes_Martin\Projects\Lytic Transglycolase Project\Images\20210407_MltA-Halo-JF646_SMT\drift';
cd(handles.BF_dir);
handles.BF_imgs = dir('*.tif');
cd(handles.drift_dir);
handles.drift_imgs = dir('*.tif');

%add in a checkpoint that makes sure the directories are of the same size

drift_toggle_Callback(handles.drift_toggle, eventdata, handles);

% cd(handles.BF_dir);
% handles.BF_name = handles.BF_imgs(idx).name;
% handles.BF = imread(handles.BF_name, 'tif');
% axes(handles.disp_image);
% imshow(handles.BF,[]);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes drift_tst wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = drift_tst_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in drift_toggle.
function drift_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to drift_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of drift_toggle
show_drift = get(hObject, 'Value');
val = str2double(get(handles.img_idx,'String'));
if show_drift
    cd(handles.drift_dir);
    handles.DT_name = handles.drift_imgs(val).name;
    IMG = imread(handles.DT_name, 'tif');
else
    cd(handles.BF_dir);
    handles.BF_name = handles.BF_imgs(val).name;
    IMG = imread(handles.BF_name, 'tif');
end
axes(handles.disp_image);
imshow(IMG,[]);



% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%val = get(hObject,'Value');

val=round(hObject.Value);
hObject.Value=val;

set(handles.img_idx,'String',num2str(val));

drift_toggle_Callback(handles.drift_toggle, eventdata, handles);

% cd(handles.BF_dir);
% handles.BF_name = handles.BF_imgs(val).name;
% handles.BF = imread(handles.BF_name, 'tif');
% axes(handles.disp_image);
% imshow(handles.BF,[]);
% update data

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.

%val = str2double(get(handles.img_idx,'String'));
set(hObject, 'min', 1);
set(hObject, 'max', 60);
set(hObject, 'Value', 1);
sliderStep = [1, 1] / (60 - 1);
set(hObject, 'SliderStep', sliderStep);


if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function img_idx_Callback(hObject, eventdata, handles)
% hObject    handle to img_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of img_idx as text
%        str2double(get(hObject,'String')) returns contents of img_idx as a double

val = str2double(get(hObject,'String'));
set(handles.slider1, 'Value', val);

drift_toggle_Callback(handles.drift_toggle, eventdata, handles);

% cd(handles.BF_dir);
% handles.BF_name = handles.BF_imgs(val).name;
% handles.BF = imread(handles.BF_name, 'tif');
% axes(handles.disp_image);
% imshow(handles.BF,[]);

%handles.img_idx = imageIndex;
% update data
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function img_idx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to img_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
