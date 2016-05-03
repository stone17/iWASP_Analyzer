function varargout = srimcalc(varargin)
% Edit the above text to modify the response to help srimcalc

% Last Modified by GUIDE v2.5 16-May-2011 17:26:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @srimcalc_OpeningFcn, ...
                   'gui_OutputFcn',  @srimcalc_OutputFcn, ...
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


% --- Executes just before srimcalc is made visible.
function srimcalc_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = srimcalc_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in layer1.
function layers_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function layers_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function thickness_Callback(hObject, eventdata, handles)
tg=get(hObject,'Tag');
thick=str2double(get(hObject,'String'));
if isnan(thick)
    if strcmp(tg,'thickness1')
        thick=10;
    elseif strcmp(tg,'thickness2')
        thick=1000;
    elseif strcmp(tg,'thickness3')
        thick=1000;
    elseif strcmp(tg,'thickness4')
        thick=1000;
    end
elseif thick<0
    thick=-thick;
end
set(hObject,'String',num2str(thick))


% --- Executes during object creation, after setting all properties.
function thickness_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in calc.
function calc_Callback(hObject, eventdata, handles)
%set(hObject, 'Enable', 'off');
global dEdx_electron dEdx_ion range_int
clear dEdx_electron dEdx_ion range_int
set(handles.Elayer1,'string','Calculating..')
set(handles.Elayer2,'Visible','off')
set(handles.Elayer3,'Visible','off')
set(handles.Elayer4,'Visible','off')
set(handles.Elayer5,'Visible','off')
set(handles.Elayer6,'Visible','off')

pause(0.01)


%obtain species
species=get(handles.species,'string');
value=get(handles.species,'value');
species=cell2mat(species(value));

%load stopping range tables
if strcmp(species,'H')
    if 1==1
        Alu=load('AlusrimH.txt');
        W=load('WsrimH.txt');
        Cu=load('CusrimH.txt');
        Ta=load('TasrimH.txt');
        CR=load('CR39srimH.txt');
    else
        load(H)
    end
elseif strcmp(species,'C')
    if 1==1
        Alu=load('AlusrimC.txt');
        W=load('WsrimC.txt');
        Cu=load('CusrimC.txt');
        Ta=load('TasrimC.txt');        
        CR=load('CR39srimC.txt');
    else
        load(C)
    end
end
    
if 1==1
    E_alu=Alu(:,1); %ion energy in keV
    dE_electron_alu=Alu(:,2); %stopping in units of  keV / micron 
    dE_ion_alu=Alu(:,3);
    range_alu=Alu(:,4); %range in um

    E_Cu=Cu(:,1); %ion energy in keV
    dE_electron_Cu=Cu(:,2); %stopping in units of  keV / micron 
    dE_ion_Cu=Cu(:,3);
    range_Cu=Cu(:,4); %range in um
    
    E_Ta=Ta(:,1); %ion energy in keV
    dE_electron_Ta=Ta(:,2); %stopping in units of  keV / micron 
    dE_ion_Ta=Ta(:,3);
    range_Ta=Ta(:,4); %range in um

    E_W=W(:,1); %ion energy in keV
    dE_electron_W=W(:,2); %stopping in units of  keV / micron 
    dE_ion_W=W(:,3);
    range_W=W(:,4); %range in um

    E_CR39=CR(:,1); %ion energy in keV
    dE_electron_CR39=CR(:,2); %stopping in units of  keV / micron 
    dE_ion_CR39=CR(:,3);
    range_CR39=CR(:,4); %range in um

    %interpolate stopping range tables
    if strcmp(species,'H')
        E=[1:1:1e6];
    elseif strcmp(species,'C')
        E=[1:1:4e6]';  %keV steps
        max(E)
    end
    %alu
    dEdx_electron(:,1)=interp1(E_alu,dE_electron_alu,E);
    dEdx_ion(:,1)=interp1(E_alu,dE_ion_alu,E);
    range_int(:,1)=interp1(E_alu,range_alu,E);

    %Cu
    dEdx_electron(:,2)=interp1(E_Cu,dE_electron_Cu,E);
    dEdx_ion(:,2)=interp1(E_Cu,dE_ion_Cu,E);
    range_int(:,2)=interp1(E_Cu,range_Cu,E);
    
    %W
    dEdx_electron(:,3)=interp1(E_W,dE_electron_W,E);
    dEdx_ion(:,3)=interp1(E_W,dE_ion_W,E);
    range_int(:,3)=interp1(E_W,range_W,E);
    
    %Ta
    dEdx_electron(:,4)=interp1(E_Ta,dE_electron_Ta,E);
    dEdx_ion(:,4)=interp1(E_Ta,dE_ion_Ta,E);
    range_int(:,4)=interp1(E_Ta,range_Ta,E);


    %cr39
    dEdx_electron(:,5)=interp1(E_CR39,dE_electron_CR39,E);
    dEdx_ion(:,5)=interp1(E_CR39,dE_ion_CR39,E);
    range_int(:,5)=interp1(E_CR39,range_CR39,E);
    
    %save 
end

%obtain layers and thicknesses
for l=1:6
    if l==1
        layer1=get(handles.layer1,'string');
        layer1index=get(handles.layer1,'value');
        layer1=cell2mat(layer1(value));        
    elseif l==2
        layer2=get(handles.layer2,'string');
        layer2index=get(handles.layer2,'value');
        layer2=cell2mat(layer2(value));
    elseif l==3
        layer3=get(handles.layer3,'string');
        layer3index=get(handles.layer3,'value');
        layer3=cell2mat(layer3(value));        
    elseif l==4
        layer4=get(handles.layer4,'string');
        layer4index=get(handles.layer4,'value');
        layer4=cell2mat(layer4(value)); 
	elseif l==5
        layer5=get(handles.layer5,'string');
        layer5index=get(handles.layer5,'value');
        layer5=cell2mat(layer5(value)); 
    elseif l==6
        layer6=get(handles.layer6,'string');
        layer6index=get(handles.layer6,'value');
        layer6=cell2mat(layer6(value)); 
    end
end

thickness1=str2double(get(handles.thickness1,'string'));
thickness2=str2double(get(handles.thickness2,'string'));
thickness3=str2double(get(handles.thickness3,'string'));
thickness4=str2double(get(handles.thickness4,'string'));
thickness5=str2double(get(handles.thickness5,'string'));
thickness6=str2double(get(handles.thickness6,'string'));

layer1end=round(thickness1);
layer2end=round(thickness1+thickness2);
layer3end=round(thickness1+thickness2+thickness3);
layer4end=round(thickness1+thickness2+thickness3+thickness4);
layer5end=round(thickness1+thickness2+thickness3+thickness4+thickness5);
layer6end=round(thickness1+thickness2+thickness3+thickness4+thickness5+thickness6);

E_in=1;
um=0;
E1=0;
E2=0;
E3=0;
E4=0;
E5=0;
E6=0;

if strcmp(species,'H')
    limit=20;
else
    limit=100;
end
indexE=1;
index_Ein=0;
n=1;
%clear deposition
while um<=layer6end
    if E_in<1e5
        E_in=E_in+1;
    else
        E_in=E_in+10;
    end
    E_remain=[0,0,0,0,0,0];
    index_Ein=index_Ein+1;
    check=max(E_in==[1e3:1e3:100e3,110e3:10e3:5000e3,5100e3:100e3:20000e3]);
    if check==1
        if n==1
            dots='.   ';
            n=2;
        elseif n==2
            dots='..  ';
            n=3;
        elseif n==3
            dots='... ';
            n=1;
        end
        set(handles.Elayer1,'string',['Calculating',dots,' (Input energy: ',num2str(E_in/1e3),'MeV / Layer: ',num2str(indexE),')'])
        pause(0.00001)
    end
    E_out=E_in;
    um=0;
    while E_out>=limit && um<=layer6end
        um=um+1;
        if um<=layer1end
            layerindex=layer1index;
        elseif um>layer1end && um<=layer2end
            layerindex=layer2index;
        elseif um>layer2end && um<=layer3end
            layerindex=layer3index;      
        elseif um>layer3end && um<=layer4end
            layerindex=layer4index;
        elseif um>layer4end && um<=layer5end
            layerindex=layer5index;
        elseif um>layer5end && um<=layer6end
            layerindex=layer6index;    
        end
        
        if um==layer1end
            E_remain(1)=E_out;
        elseif um==layer2end
            E_remain(2)=E_out;
        elseif um==layer3end
            E_remain(3)=E_out;      
        elseif um==layer4end
            E_remain(4)=E_out;
        elseif um==layer5end
            E_remain(5)=E_out;
        elseif um==layer6end
            E_remain(6)=E_out;    
        end
        
        E_out_index=E_out;
        E_out=round(E_out-dEdx_electron(E_out_index,layerindex)+dEdx_ion(E_out_index,layerindex));
    end
    if um==layer1end+1 && thickness1>0 && indexE==1
        E1=E_in;
        indexE=2;
    elseif um==layer2end && thickness2>0 && indexE==2
        E2=E_in;
        indexE=3;
    elseif um==layer3end && thickness3>0 && indexE==3
        E3=E_in;
        indexE=4;
    elseif um==layer4end && thickness4>0 && indexE==4
        E4=E_in;
        indexE=5;
    elseif um==layer5end && thickness5>0 && indexE==5
        E5=E_in;
        indexE=6;
    elseif um==layer6end && thickness6>0 && indexE==6
        E6=E_in;
    end
    if 1==2
        deposition(index_Ein,1)=E_in;
        deposition(index_Ein,2)=um;
        deposition(index_Ein,3:8)=E_remain;
    end
end

if E1~=0
    set(handles.Elayer1,'string',[num2str(round(E1/1e3*100)/100),'MeV'])
else
    set(handles.Elayer1,'string','N/A')
end
if E2~=0
    set(handles.Elayer2,'string',[num2str(round(E2/1e3*100)/100),'MeV'])
else
    set(handles.Elayer2,'string','N/A')
end
if E3~=0
    set(handles.Elayer3,'string',[num2str(round(E3/1e3*100)/100),'MeV'])
else
    set(handles.Elayer3,'string','N/A')
end
if E4~=0
    set(handles.Elayer4,'string',[num2str(round(E4/1e3*100)/100),'MeV'])
else
    set(handles.Elayer4,'string','N/A')
end
if E5~=0
    set(handles.Elayer5,'string',[num2str(round(E5/1e3*100)/100),'MeV'])
else
    set(handles.Elayer5,'string','N/A')
end

if E6~=0
    set(handles.Elayer6,'string',[num2str(round(E6/1e3*100)/100),'MeV'])
else
    set(handles.Elayer6,'string','N/A')
end

set(handles.Elayer2,'Visible','on')
set(handles.Elayer3,'Visible','on')
set(handles.Elayer4,'Visible','on')
set(handles.Elayer5,'Visible','on')
set(handles.Elayer6,'Visible','on')

set(hObject, 'Enable', 'on');

% --- Executes on selection change in species.
function species_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function species_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
