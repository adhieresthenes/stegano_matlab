function varargout = GUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_OutputFcn, ...
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

function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
addpath([cd '\mmread']);
addpath([cd '\mmwrite']);
movegui('center');
handles.output = hObject;
guidata(hObject, handles);

function varargout = GUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function ambil_video_cover_Callback(hObject, eventdata, handles)
global vid audio frame_video_cover
% membaca video---------------------------------------------------------
[filename,pathname] = uigetfile({'*.mp4';'*.avi'},'Ambil File Video');
if filename~=0
    [vid,audio]=mmread([pathname,filename]);
    frame_video_cover=vid.frames;
    set(handles.filename,'string',filename);
    axes(handles.axes1);imshow(frame_video_cover(1).cdata);
    set(handles.jumlah_frame_video,'string',vid.nrFramesTotal);
    set(handles.resolusi_frame,'string',[num2str(vid.width) 'x' num2str(vid.height)]);
    set(handles.frame_per_detik,'string',round(vid.rate));
end

function ambil_gambar_pesan_Callback(hObject, eventdata, handles)
global pesan bit
[FileName,PathName] = uigetfile('*.txt');
if FileName~=0
    fileID = fopen([PathName,FileName]);
    pesan = fread(fileID,'*char')';
    ascii=double(pesan);
    bit=reshape((double(dec2bin(ascii,8))-48)',[],1);
    set(handles.listbox3,'string',pesan);
end

function listbox1_Callback(hObject, eventdata, handles)
function listbox1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function steganografi_Callback(hObject, eventdata, handles)
global vid frame_video_cover frames pil nframe audio bit
tic
frames=frame_video_cover;
frame_awal=frames(1).cdata;
wbd=waitbar(0,'Please Wait...');
y=audio.data;
ymono=mean(y,2);
fs=audio.rate;
fps=vid.rate;
nsample=round(1/fps*fs);
ybuffer=buffer(ymono,nsample);
jumsam=mean(sign(ybuffer(1:end-1,:)-ybuffer(2:end,:)),1)/2;
nframe=find(jumsam<mean(jumsam));
nbit=1;
posframe=1;
while nbit<=length(bit)
    frame_terpilih=frames(nframe(posframe)).cdata;
    baris=1;
    kolom=1;
    layer=1;
    ukuran_baris=size(frame_terpilih,1);
    ukuran_kolom=size(frame_terpilih,2);
    ukuran_layer=size(frame_terpilih,3);
    status=1;
    while nbit<=length(bit)&& status==1
        piksel=frame_terpilih(baris,kolom,layer);
        bit_piksel=de2bi(piksel,8,'left-msb');
                if bit_piksel(4)~=bit(nbit)
                    if bit_piksel(4)==0
                        bit_piksel(4)=1;
                        if bit_piksel(5)==0 && bit_piksel(6)==0
                            bit_piksel(6)=0;
                            bit_piksel(7)=0;
                            bit_piksel(8)=0;
                        else
                            bit_piksel(6)=1;
                            bit_piksel(7)=1;
                            bit_piksel(8)=1;
                        end
                    else
                        bit_piksel(4)=0;
                        if bit_piksel(5)==1 && bit_piksel(6)==0
                            bit_piksel(6)=1;
                            bit_piksel(7)=1;
                            bit_piksel(8)=1;
                        else
                            bit_piksel(6)=0;
                            bit_piksel(7)=0;
                            bit_piksel(8)=0;
                        end
                    end
                end
                 frame_terpilih(baris,kolom,layer)=bi2de(bit_piksel,'left-msb');
                 posisi=1;
        nbit=nbit+1;
        waitbar(nbit/length(bit));
        kolom=kolom+posisi;
        if kolom>ukuran_kolom
            if baris<ukuran_baris
                baris=baris+1;
                kolom=mod(kolom,ukuran_kolom);
            else
                if layer<ukuran_layer
                    layer=layer+1;
                    baris=1;
                    kolom=1;
                else
                    status=0;
                end
            end
        end
    end
    frames(nframe(posframe)).cdata=frame_terpilih;
    posframe=posframe+1;
end
close(wbd)
vid.frames=frames;

waktu=toc;
mse=[];
for i=1:posframe
    mse(i)=mean(mean(mean(((double(frames(i).cdata)-double(frame_video_cover(i).cdata)).^2))));
end
mse=mean(mse);
psnr=10*log10(255^2/mse);
set(handles.mse,'string',mse);
set(handles.psnr,'string',psnr);
set(handles.waktu_sisip,'string',waktu);
axes(handles.axes8);imshow(frames(1).cdata);

function ambil_video_ekstraksi_Callback(hObject, eventdata, handles)
global vid1 audio1 frame_video
% membaca video---------------------------------------------------------
[filename,pathname] = uigetfile('*.avi','Ambil File Video');
if filename~=0
    [vid1,audio1]=mmread([pathname,filename]);
    frame_video=vid1.frames;
    axes(handles.axes4);imshow(frame_video(1).cdata);
end

function ekstraksi_Callback(hObject, eventdata, handles)
global vid1 bit pesan nframe lebih audio1
frames=vid1.frames;
frame_awal=frames(1).cdata;
tic
y=audio1.data;
ymono=mean(y,2);
fs=audio1.rate;
fps=vid1.rate;
nsample=round(1/fps*fs);
ybuffer=buffer(ymono,nsample);
jumsam=mean(sign(ybuffer(1:end-1,:)-ybuffer(2:end,:)),1)/2;
nframe=find(jumsam<mean(jumsam));
        wb=waitbar(0,'Please Wait...');
        nbit=1;
        posframe=1;
        while nbit<=length(bit)
            frame_terpilih=frames(nframe(posframe)).cdata;
            baris=1;
            kolom=1;
            layer=1;
            ukuran_baris=size(frame_terpilih,1);
            ukuran_kolom=size(frame_terpilih,2);
            ukuran_layer=size(frame_terpilih,3);
            status=1;
            while nbit<=length(bit)&& status==1
                piksel=frame_terpilih(baris,kolom,layer);
                                        bit_piksel=de2bi(piksel,8,'left-msb');
                        bit_hasil(nbit,1)=double(bit_piksel(4));
                                        posisi=1;
                nbit=nbit+1;
                waitbar(nbit/length(bit));
                kolom=kolom+posisi;
                if kolom>ukuran_kolom
                    if baris<ukuran_baris
                        baris=baris+1;
                        kolom=mod(kolom,ukuran_kolom);
                    else
                        if layer<ukuran_layer
                            layer=layer+1;
                            baris=1;
                            kolom=1;
                        else
                            status=0;
                        end
                    end
                end
            end
            frames(nframe(posframe)).cdata=frame_terpilih;
            posframe=posframe+1;
        end
        hasil_pesan=char(bin2dec(char(reshape(bit_hasil,8,[])'+48)))';
        close(wb)
waktu=toc;
[jumbit,ber]=symerr(bit,bit_hasil);
error=0;
for i=1:length(pesan)
    if pesan(i)~= hasil_pesan(i)
        error=error+1;
    end
end
cer=error/length(pesan);
set(handles.listbox4,'string',hasil_pesan);
set(handles.waktu_ekstraksi,'string',waktu);
set(handles.mselogo,'string',ber);
set(handles.psnrlogo,'string',cer);

function save_video_Callback(hObject, eventdata, handles)
global frames vid audio
[filename,pathname] = uiputfile('*.avi');
if filename~=0
    vid.frames=frames;
    mmwrite([pathname,filename],audio,vid);
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


% --- Executes on selection change in pilih_metode.
function pilih_metode_Callback(hObject, eventdata, handles)
% hObject    handle to pilih_metode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pilih_metode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pilih_metode


% --- Executes during object creation, after setting all properties.
function pilih_metode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pilih_metode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
close(GUI);GUI_GANGGUAN;
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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



function mselogo_Callback(hObject, eventdata, handles)
% hObject    handle to mselogo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mselogo as text
%        str2double(get(hObject,'String')) returns contents of mselogo as a double


% --- Executes during object creation, after setting all properties.
function mselogo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mselogo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function waktu_ekstraksi_Callback(hObject, eventdata, handles)
% hObject    handle to waktu_ekstraksi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of waktu_ekstraksi as text
%        str2double(get(hObject,'String')) returns contents of waktu_ekstraksi as a double


% --- Executes during object creation, after setting all properties.
function waktu_ekstraksi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to waktu_ekstraksi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function waktu_sisip_Callback(hObject, eventdata, handles)
% hObject    handle to waktu_sisip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of waktu_sisip as text
%        str2double(get(hObject,'String')) returns contents of waktu_sisip as a double


% --- Executes during object creation, after setting all properties.
function waktu_sisip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to waktu_sisip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in resolusi.
function resolusi_Callback(hObject, eventdata, handles)
% hObject    handle to resolusi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns resolusi contents as cell array
%        contents{get(hObject,'Value')} returns selected item from resolusi


% --- Executes during object creation, after setting all properties.
function resolusi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resolusi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in jum_frame.
function jum_frame_Callback(hObject, eventdata, handles)
% hObject    handle to jum_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns jum_frame contents as cell array
%        contents{get(hObject,'Value')} returns selected item from jum_frame


% --- Executes during object creation, after setting all properties.
function jum_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to jum_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function psnrlogo_Callback(hObject, eventdata, handles)
% hObject    handle to psnrlogo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psnrlogo as text
%        str2double(get(hObject,'String')) returns contents of psnrlogo as a double


% --- Executes during object creation, after setting all properties.
function psnrlogo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psnrlogo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox4.
function listbox4_Callback(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox4


% --- Executes during object creation, after setting all properties.
function listbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
