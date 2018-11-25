function varargout = testwebcam(varargin)
% TESTWEBCAM MATLAB code for testwebcam.fig
%      TESTWEBCAM, by itself, creates a new TESTWEBCAM or raises the existing
%      singleton*.
%
%      H = TESTWEBCAM returns the handle to a new TESTWEBCAM or the handle to
%      the existing singleton*.
%
%      TESTWEBCAM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTWEBCAM.M with the given input arguments.
%
%      TESTWEBCAM('Property','Value',...) creates a new TESTWEBCAM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testwebcam_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testwebcam_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testwebcam

% Last Modified by GUIDE v2.5 24-Nov-2018 19:46:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testwebcam_OpeningFcn, ...
                   'gui_OutputFcn',  @testwebcam_OutputFcn, ...
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


% --- Executes just before testwebcam is made visible.
function testwebcam_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testwebcam (see VARARGIN)

% Choose default command line output for testwebcam
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes testwebcam wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = testwebcam_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in webcam.
function webcam_Callback(hObject, eventdata, handles)
% hObject    handle to webcam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
noframes = str2double(get(handles.frames, 'String'));
axes(handles.axes1);
Inputimage = "";

a = imaqhwinfo;
[camera_name, camera_id, format] = getCameraInfo(a);

% Capture the video frames using the videoinput function
% You have to replace the resolution & your installed adaptor name.
vid = videoinput(camera_name, camera_id, format);

% Set the properties of the video object
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')
vid.FrameGrabInterval = 5;

%start the video aquisition here
start(vid)

% Set a loop that stop after 100 frames of aquisition
while(vid.FramesAcquired<=noframes)
    Inputimage = getsnapshot(vid);
    
    Inputimage=rgb2gray(Inputimage);

    %% Convert to binary image
    threshold = graythresh(Inputimage);
    Inputimage = ~im2bw(Inputimage,threshold);

    %% Remove all object containing fewer than 30 pixels
    Inputimage = bwareaopen(Inputimage,30);
    %pause(1);

    %% Label connected components
    [L Ne]=bwlabel(Inputimage);

    propied=regionprops(L,'BoundingBox');
    imshow(~Inputimage);
    hold on
    for n=1:size(propied,1)
      rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2)
    end
    hold off
end

% Stop the video aquisition.
stop(vid);

% Flush all the image data stored in the memory buffer.
flushdata(vid);

% Clear all variables
%clear all

pause (1);

%% Objects extraction
figure('Name', 'Extracted Texts'); 
for n=1:Ne
  [r,c] = find(L==n);
  n1=Inputimage(min(r):max(r),min(c):max(c));
  subplot(2,Ne/2,n);
  imshow(~n1);
  pause(0.5)
end

%% Extract object from image into plain text using Matlab OCR function
result = ocr(~Inputimage, 'TextLayout', 'Block');

%% Show alert result
success = msgbox({'Image selected successfully processed.'; strcat('Result: ',result.Text)},'Success');


function frames_Callback(hObject, eventdata, handles)
% hObject    handle to frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frames as text
%        str2double(get(hObject,'String')) returns contents of frames as a double


% --- Executes during object creation, after setting all properties.
function frames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
