function varargout = TraceRotate(varargin)
%TRACEROTATE M-file for TraceRotate.fig
%      TRACEROTATE, by itself, creates a new TRACEROTATE or raises the existing
%      singleton*.
%
%      H = TRACEROTATE returns the handle to a new TRACEROTATE or the handle to
%      the existing singleton*.
%
%      TRACEROTATE('Property','Value',...) creates a new TRACEROTATE using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to TraceRotate_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      TRACEROTATE('CALLBACK') and TRACEROTATE('CALLBACK',hObject,...) call the
%      local function named CALLBACK in TRACEROTATE.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TraceRotate

% Last Modified by GUIDE v2.5 09-Dec-2017 22:46:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TraceRotate_OpeningFcn, ...
                   'gui_OutputFcn',  @TraceRotate_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before TraceRotate is made visible.
function TraceRotate_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)
% get the data from the input variables
handles.BF1 = varargin{1};% bright field image
handles.TrackcO = varargin{2}; % trace information origin at the lefttop corner
handles.pixelS = varargin{3}; % pixel size of the image
handles.Datahandle = varargin{4}; % Data handle
% show the image
axes(handles.BFimage_tag);
hold off
imshow(handles.BF1,[]);
hold on
for ii = 1 : length(handles.TrackcO)
    trace = handles.TrackcO(ii).XYCoord;
    plot(trace(:,1),trace(:,2))
end
movegui(gcf,'center');
% Choose default command line output 
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes TraceRotate wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TraceRotate_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in Rotate.
function Rotate_Callback(hObject, eventdata, handles)
% hObject    handle to Rotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% [X Y]=ginput(2); % select two points on long axis to get the angle
% Angle=180*(atan((Y(2)-Y(1))/(X(2)-X(1)))+pi/2)/pi;

% get the gray scale of the original image
handles.LowI1 = min(handles.BF1(:));
handles.HighI1 = max(handles.BF1(:));
% rotate the image around the center counterclockwise

Answer = inputdlg('Rotate the image by an angle counterclockwise','Inputp',1);
Angle = str2num(Answer{1});
BFRot = imrotate(handles.BF1,Angle,'bicubic','crop');
% show the rotated image
axes(handles.BFimage_tag);
hold off
imshow(BFRot,[handles.LowI1 handles.HighI1]);

response=questdlg('The rotation Okay?', ...
    'Rotate the Cell', 'Yes' , 'No','Yes');
if strcmp(response,'Yes')
    BFRot = imrotate(handles.BF1,Angle,'bicubic','crop');
    handles.BFRot = BFRot;

    % find the rotation center
    ImX = (size(handles.BF1,2) + 1)/2;
    ImY = (size(handles.BF1,1) + 1)/2;
    % rotate the traces according to the angle and center point
    axes(handles.BFimage_tag);
    hold off
    imshow(BFRot,[handles.LowI1 handles.HighI1]);
    hold on
    for ii = 1 : length(handles.TrackcO)
        trace = handles.TrackcO(ii).XYCoord;
        Time = handles.TrackcO(ii).Time;
        Intensity = handles.TrackcO(ii).Intensity;
        for jj = 1 : size(trace,1)
            Coords = trace(jj,1:2);
            Coord_rot = coord2dRot( Coords,[ImX,ImY],-Angle);
            trace_rot(jj,:) = Coord_rot;
        end
        TrackcOR(ii).XYCoord(:,1:2) = trace_rot;
        TrackcOR(ii).Time = Time;
        TrackcOR(ii).Intensity = Intensity;
        plot(trace_rot(:,1),trace_rot(:,2));
        clear trace_rot
    end
    handles.TrackcOR = TrackcOR;
else
    axes(handles.BFimage_tag);
    hold off
    imshow(handles.BF1,[handles.LowI1 handles.HighI1]);
end
guidata(hObject,handles);

% --- Executes on button press in left_tag.
function left_tag_Callback(hObject, eventdata, handles)
% hObject    handle to left_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% response=questdlg('Double click the two ends of the short axis.', ...
%     'Short Axis selection', 'Yes' , 'No','Yes');
% if strcmp(response,'Yes');

% get the left region for averaging 
     
     Xfine = handles.Xfine ;
     Xpixel = handles.Xpixel;
     ScanLine = handles.ScanLine;
     ScanFine = handles.ScanFine;
     
     % select the region
     axes(handles.LineScan_tag);
     [X Y] = ginput(2);
     Index = find(Xpixel > min(X) & Xpixel < max(X));
     MeanLeft = mean(ScanLine(Index));
     
     % plot the line
     hold on
     plot(Xfine,ones(size(Xfine))*MeanLeft,'b');
     handles.MeanLeft = MeanLeft;
guidata(hObject,handles);


% --- Executes on button press in SaveStruc.
function SaveStruc_Callback(hObject, eventdata, handles)
% hObject    handle to SaveStruc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'TrackcOR_unwrap')
    errordlg('Analysis the data first!');
    return;
end


TraceInfo.TrackcOR_unwrap = handles.TrackcOR_unwrap;
TraceInfo.Center = handles.Center;
TraceInfo.Radius = handles.SRadius;
TraceInfo.BFrot = handles.BFRot;
setappdata(handles.Datahandle,'TraceInformation',TraceInfo);
delete(handles.figure1);


% --- Executes on button press in center_tag.
function center_tag_Callback(hObject, eventdata, handles)
% hObject    handle to center_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% find the center position of the septum for line scanning
axes(handles.BFimage_tag);
[X Y] = ginput(1);
handles.CenterY = Y;
BFImage = handles.BFRot;
% calculate the profile on the horizatal line and spline to a finer curve
ScanLine = BFImage(round(Y),:);
Xpixel = [1:size(BFImage,2)];
Xfine = linspace(1,size(BFImage,2),size(BFImage,2)*10);
ScanFine = spline(Xpixel,ScanLine,Xfine); % smooth 10 folds by 
% plot the line out
axes(handles.LineScan_tag);
hold off
plot(Xpixel,ScanLine,'ob');
hold on
plot(Xfine,ScanFine,'-r','LineWidth',3);
% save the curves
handles.Xfine = Xfine;
handles.Xpixel = Xpixel;
handles.ScanLine = ScanLine;
handles.ScanFine = ScanFine;
guidata(hObject,handles);


% --- Executes on button press in Z_gen_tag.
function Z_gen_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Z_gen_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% generate the unwrapped coordinates
     Xfine = handles.Xfine;
     Xpixel = handles.Xpixel;
     ScanLine = handles.ScanLine;
     ScanFine = handles.ScanFine;
     
% choice 1: automatically calculate the boundray, when the cell is well
% seperated and image qulity good

% % chop the bright field in half (from left to maximum, and from maximum to right)
%      MaxLine = find(ScanLine == max(ScanLine));
%      MaxFine = find(ScanFine == max(ScanFine));
%      XfineLeft = Xfine(1:MaxFine(1));
%      XfineRight = Xfine(MaxFine(1)+1:end);
%      ScanFineLeft = ScanFine(1:1:MaxFine(1));
%      ScanFineRight = ScanFine(MaxFine(1)+1:end);  
% % subtract the scanline by the mean value of left and right line
%      MeanRight = handles.MeanRight;
%      MeanLeft = handles.MeanLeft;
%      
%      DiffLeft = ScanFineLeft - MeanLeft;
%      DiffRight = ScanFineRight - MeanRight;
%      
%      % left point
%      Index1 = find(DiffLeft < 0);
%      IndexLeft = Index1(end);%+1;
%      
%      % right point
%      Index2 = find(DiffRight <0);
%      IndexRight = Index2(1);%-1;
     
% choice 2: manually select the boundray based on the fitting and base
% line, when the image is not great or cells packed together
     axes(handles.LineScan_tag);
     [X Y] = ginput(2);
     % left point
     PosiLeft = min(X);
     Index1 = find(Xfine <= PosiLeft);
     IndexLeft = Index1(end);
     
     % right point
     PosiRight = max(X);
     Index2 = find(Xfine >= PosiRight);
     IndexRight = Index2(1);
     
     
     PixelS = handles.pixelS;
     Offset = 33/PixelS; % the real boundary is inward of the position from test
     
     % get the cell outline
     CellOut(1,1) = Xfine(IndexLeft) + Offset;
     CellOut(1,2) = ScanFine(IndexLeft); % first row, the position and intensity of the left point
     CellOut(2,1) = Xfine(IndexRight) - Offset;
     CellOut(2,2) = ScanFine(IndexRight);% second row, the position and intensity of the right point
     CellOut(3,1) = (Xfine(IndexLeft) + Xfine(IndexRight))/2; 
     CellOut(3,2) = mean(max(ScanFine));% third row, the position and intensity of the center of the cell
     
     handles.CellOut = CellOut;
     handles.SeptalD = CellOut(2,1) - CellOut(1,1);
     SRadius = [(CellOut(2,1) - CellOut(1,1))/2 + 35/PixelS, (CellOut(2,1) - CellOut(1,1))/2 , (CellOut(2,1) - CellOut(1,1))/2 - 35/PixelS];
     handles.SRadius = SRadius; % The radius with std of the estimation
     % label the center point
     Center(1) = CellOut(3,1);
     Center(2) = handles.CenterY;
     handles.Center = Center;
     % plot the points out
     
     axes(handles.LineScan_tag);
     hold on
     plot(CellOut(1,1),CellOut(1,2),'+b','MarkerSize', 20);
     plot(CellOut(2,1),CellOut(2,2),'+g','MarkerSize', 20);
     plot(CellOut(3,1),CellOut(3,2),'dk','MarkerSize', 15);
    
     Y = size(handles.BFRot,1);
     axes(handles.BFimage_tag);
     hold on
     plot(CellOut(1,1)*ones(Y),[1:Y],'-b');
     plot(CellOut(2,1)*ones(Y),[1:Y],'-g');
     plot(CellOut(3,1)*ones(Y),[1:Y],'-r');
     
     % Show the result on the panel
     OutputS{1,1} = ['Cell centered at X = ' num2str(CellOut(3,1)) ' pixel'];
     OutputS{2,1} = ['Septum radius = ' num2str(SRadius(2)) ' pixel'];
     OutputS{3,1} = ['Septum radius = ' num2str(SRadius(2)*handles.pixelS) ' nm'];
     OutputS{4,1} = ['Septum radius in a range from ' num2str(SRadius(3)) ' to ' num2str(SRadius(1)) ' pixel'];
     set(handles.data_tag, 'String', OutputS);
     
     % unwrap the coordinates based on the center and radius
     TrackcOR = handles.TrackcOR;
     axes(handles.unwrap_trace_tag);
     hold off
     for ii = 1 : length(TrackcOR)
         trace = TrackcOR(ii).XYCoord;
         Time = TrackcOR(ii).Time;
         Intensity = TrackcOR(ii).Intensity;
         for jj = 1 : size(trace,1)
             Coord_temp = trace(jj,:);
             Coord_unwrap_1 = unwrapTraj( Center, SRadius(1), Coord_temp ); % big radius
             Coord_unwrap_2 = unwrapTraj( Center, SRadius(2), Coord_temp ); % median radius
             Coord_unwrap_3 = unwrapTraj( Center, SRadius(3), Coord_temp ); % small radius
             trace_unwrap(jj,:) = [Coord_unwrap_1,Coord_unwrap_2,Coord_unwrap_3];
         end
         TrackcOR_unwrap(ii).XYZCoord = trace_unwrap;
         TrackcOR_unwrap(ii).Time = Time;
         TrackcOR_unwrap(ii).Intensity = Intensity;
         plot(trace_unwrap(:,3),trace_unwrap(:,4));
         hold on
         clear trace_unwrap
     end
     % save the tracks
     handles.TrackcOR_unwrap = TrackcOR_unwrap;
     % plot the t
     
guidata(hObject,handles);

% --- Executes on button press in right_tag.
function right_tag_Callback(hObject, eventdata, handles)
% hObject    handle to right_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the right region for averaging 
     
     Xfine = handles.Xfine ;
     Xpixel = handles.Xpixel;
     ScanLine = handles.ScanLine;
     ScanFine = handles.ScanFine;
     
     % select the region
     axes(handles.LineScan_tag);
     [X Y] = ginput(2);
     Index = find(Xpixel > min(X) & Xpixel < max(X));
     MeanRight = mean(ScanLine(Index));
     
     % plot the line
     hold on
     plot(Xfine,ones(size(Xfine))*MeanRight,'g');
     handles.MeanRight = MeanRight;
     
guidata(hObject,handles);
