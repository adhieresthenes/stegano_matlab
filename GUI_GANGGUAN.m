function varargout = GUI_GANGGUAN(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_GANGGUAN_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_GANGGUAN_OutputFcn, ...
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

function GUI_GANGGUAN_OpeningFcn(hObject, eventdata, handles, varargin)
addpath([cd '\mmread']);
addpath([cd '\mmwrite']);
movegui('center');
handles.output = hObject;
guidata(hObject, handles);

function varargout = GUI_GANGGUAN_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


function ambil_video_Callback(hObject, eventdata, handles)
global vid1 audio1 frame_video1 
% membaca video---------------------------------------------------------
[filename,pathname] = uigetfile('*.avi','Ambil File Video');
if filename~=0
    [vid1,audio1]=mmread([pathname,filename]);
    frame_video1=vid1.frames;
    set(handles.filename,'string',filename);
    axes(handles.axes1);imshow(frame_video1(1).cdata);
    set(handles.jumlah_frame_video,'string',vid1.nrFramesTotal);
    set(handles.resolusi_frame,'string',[num2str(vid1.width) 'x' num2str(vid1.height)]);
    set(handles.frame_per_detik,'string',round(vid1.rate));
end

function proses_Callback(hObject, eventdata, handles)
global vid1 frame_video1 frames1
frames1=frame_video1;
pil=get(handles.popupmenu1,'value');
koef=str2num(get(handles.koefisien,'string'));
tic
if length(koef)>0
switch pil
    case 2
        wbd=waitbar(0,'Please Wait...');
        for ii=1:length(frames1)
            frame_terpilih=frames1(ii).cdata;
            awal=frame_terpilih;
            [ub,uk,l]=size(awal);
            resize=imresize(awal,koef,'nearest');
            hasil=imresize(resize,[ub,uk],'nearest');
            mse(ii)=mean(mean(mean(abs(hasil-awal))));
            frames1(ii).cdata=hasil;
            waitbar(ii/length(frames1))
        end
        vid1.frames=frames1;
        close(wbd);
    case 3
        wbd=waitbar(0,'Please Wait...');
        for ii=1:length(frames1)
            frame_terpilih=frames1(ii).cdata;
            awal=frame_terpilih;
            hasil=imnoise(awal,'salt & pepper',koef);
            mse(ii)=mean(mean(mean(abs(hasil-awal))));
            frames1(ii).cdata=hasil;
            waitbar(ii/length(frames1))
        end
        vid1.frames=frames1;
        close(wbd);
    case 4
        wbd=waitbar(0,'Please Wait...');
        for ii=1:length(frames1)
            frame_terpilih=frames1(ii).cdata;
            awal=frame_terpilih;
            h = fspecial('gaussian',[3 3], koef);
            hasil=imfilter(awal,h,'replicate');
            mse(ii)=mean(mean(mean(abs(hasil-awal))));
            frames1(ii).cdata=hasil;
            waitbar(ii/length(frames1))
        end
        vid1.frames=frames1;
        close(wbd);
end
mse=mean(mse);
psnr=10*log10(255^2/mse);
waktu=toc;
set(handles.waktu,'string',waktu);
set(handles.mse,'string',mse);
set(handles.psnr,'string',psnr);
axes(handles.axes3);imshow(frames1(1).cdata);
else
    errordlg('input nilai koefisien terlebih dahulu');
end

function jumlah_frame_video_Callback(hObject, eventdata, handles)
function jumlah_frame_video_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function resolusi_frame_Callback(hObject, eventdata, handles)
function resolusi_frame_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function frame_per_detik_Callback(hObject, eventdata, handles)
function frame_per_detik_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filename_Callback(hObject, eventdata, handles)
function filename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function play_input_Callback(hObject, eventdata, handles)
global vid1 status_play
if strcmp(get(handles.play_input,'string'),'Play')
    set(handles.play_input,'string','Stop');
    status_play=1;
    frame_video=vid1.frames;
    for i=1:length(frame_video)
        if status_play==0
            break
        else
            axes(handles.axes1);imshow(frame_video(i).cdata);pause(1/vid1.rate);
        end
    end
    set(handles.play_input,'string','Play');
    status_play=0;
else
    set(handles.play_input,'string','Play');
    status_play=0;
end

function play_hasil_Callback(hObject, eventdata, handles)
global frames1 vid1 status_play
if strcmp(get(handles.play_hasil,'string'),'Play')
    set(handles.play_hasil,'string','Stop');
    status_play=1;
    frame_video=frames1;
    for i=1:length(frame_video)
        if status_play==0
            break
        else
            axes(handles.axes3);imshow(frame_video(i).cdata);pause(1/vid1.rate);
        end
    end
    set(handles.play_hasil,'string','Play');
    status_play=0;
else
    set(handles.play_hasil,'string','Play');
    status_play=0;
end

function save_video_Callback(hObject, eventdata, handles)
global frames1 vid1 audio1
[filename,pathname] = uiputfile('*.avi');
if filename~=0
    vid1.frames=frames1;
    mmwrite([pathname,filename],audio1,vid1);
end

function popupmenu1_Callback(hObject, eventdata, handles)
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
close(GUI_GANGGUAN);GUI;
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function koefisien_Callback(hObject, eventdata, handles)
function koefisien_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mse_Callback(hObject, eventdata, handles)
% hObject    handle to mse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mse as text
%        str2double(get(hObject,'String')) returns contents of mse as a double


% --- Executes during object creation, after setting all properties.
function mse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function psnr_Callback(hObject, eventdata, handles)
% hObject    handle to psnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psnr as text
%        str2double(get(hObject,'String')) returns contents of psnr as a double


% --- Executes during object creation, after setting all properties.
function psnr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function waktu_Callback(hObject, eventdata, handles)
% hObject    handle to waktu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of waktu as text
%        str2double(get(hObject,'String')) returns contents of waktu as a double


% --- Executes during object creation, after setting all properties.
function waktu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to waktu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
