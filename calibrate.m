function varargout = calibrate(varargin)
% CALIBRATE MATLAB code for calibrate.fig
%      CALIBRATE, by itself, creates a new CALIBRATE or raises the existing
%      singleton*.
%
%      H = CALIBRATE returns the handle to a new CALIBRATE or the handle to
%      the existing singleton*.
%
%      CALIBRATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALIBRATE.M with the given input arguments.
%
%      CALIBRATE('Property','Value',...) creates a new CALIBRATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before calibrate_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to calibrate_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help calibrate

% Last Modified by GUIDE v2.5 31-Oct-2012 12:29:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @calibrate_OpeningFcn, ...
                   'gui_OutputFcn',  @calibrate_OutputFcn, ...
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


% --- Executes just before calibrate is made visible.
function calibrate_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for calibrate
handles.output = hObject;
setappdata(handles.main,'firstrun',1)
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = calibrate_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on button press in load.
function buttonpress_Callback(hObject, eventdata, handles)
mode=get(hObject,'Tag');
clc
if exist('lastpath.txt','file')
	fid = fopen('lastpath.txt','r');
	pname=(fread(fid,'*char'))';
	fclose(fid);
else
	pname='c:\';
end
    
if strcmp(mode,'load')==1
    [fname,pname]=uigetfile({'*T.mat','Spectrum files'},'Select spectrum file',pname);
    try
        file=[pname,fname];  
        load(file)
    catch
        return
    end
    set(handles.title1,'string',fname)
    setappdata(handles.main,'Energyvec',Energyvec)
    setappdata(handles.main,'specmap',specmap(:,:,1))
    setappdata(handles.main,'angle',angle(:,:))
    setappdata(handles.main,'cut',cut)
    setappdata(handles.main,'A',A)
    
    for a=1:length(angle(:,1))
         [value,index]=max(specmap(a,:,1));
         line(a,1)=angle(a,1);
         line(a,2)=Energyvec(index);
    end
    line(:,1)=line(:,1).*10;
    plot(handles.lineout,line(:,1),line(:,2))
    
    setappdata(handles.main,'line',line(:,:))
    
    plotdata_Callback(hObject, eventdata, handles)
    set(handles.brushdata,'Enable','on')
    set(handles.sli_min,'Min',min(line(:,1)))
    set(handles.sli_min,'Max',max(line(:,1)))
    set(handles.sli_max,'Min',min(line(:,1)))
    set(handles.sli_max,'Max',max(line(:,1)))
    set(handles.t_min,'string',num2str(min(line(:,1))))
    set(handles.t_max,'string',num2str(max(line(:,1))))
    set(handles.sli_max,'value',max(line(:,1)))
    
elseif strcmp(mode,'loadfitfile')
        [fname,pname]=uigetfile({'*.txt','Calibration files'},'Load calibration file');
    try
        file=[pname,fname];  
        bfit=load(file);
    catch
        return
    end
    setappdata(handles.main,'fitfile',file)
    setappdata(handles.main,'bfit',bfit)
    set(handles.fitfile_text,'string',fname)
    set(handles.fitlineout,'Enable','on')
elseif strcmp(mode,'brushdata')
    if get(hObject,'Foregroundcolor')==[0 0 0]
        line=getappdata(handles.main,'line');
        plot(handles.lineout,line(:,1),line(:,2))
        brush('on')
        set(hObject,'Foregroundcolor','r')
        set(handles.fitlineout,'Enable','off')
    else
        brush('off')
        set(hObject,'Foregroundcolor','black')
        
        ch=get(handles.lineout,'Children');
        line(:,1)=get(ch,'Xdata');
        line(:,2)=get(ch,'Ydata');
        line(any(isnan(line),2),:)=[];
        setappdata(handles.main,'line',line(:,:))
        plot(handles.lineout,line(:,1),line(:,2))
        strcmp(get(handles.fitfile_text,'string'),'No file loaded')
        get(handles.fitfile_text,'string')
        if strcmp(get(handles.fitfile_text,'string'),'No file loaded')==0
            set(handles.fitlineout,'Enable','on')
        end
    end
elseif strcmp(mode,'savecalib')
    oldfit=getappdata(handles.main,'fitfile')
    bfit=getappdata(handles.main,'bfit_new');
    [f, p] = uiputfile({'*.txt'},'Save as',[oldfit(1:end-4),'_new.txt']);
    if f~=0
        save([p,f],'bfit','-ascii')
    end
end

function plotdata_Callback(hObject, eventdata, handles)
Energyvec=getappdata(handles.main,'Energyvec');
specmap=getappdata(handles.main,'specmap');
angle=getappdata(handles.main,'angle');
cut=getappdata(handles.main,'cut');
A=getappdata(handles.main,'A');
fitenergy=str2double(get(handles.fitenergy,'string'));
if getappdata(handles.main,'firstrun')==1
    setappdata(handles.main,'firstrun',0);
else
    vw=get(handles.spectrum,'View');
end

axes(handles.spectrum)
surf(log(Energyvec),angle(:,1),log(specmap));
shading(gca,'interp')
%caxis([0.01*mean(mean(specmap)) max(max(specmap))])
if A==1
    ticks=[1.1,2,3,4,5,10,20:10:fix(cut(2)/10)*10];
else
    ticks=[20,25,50,100:100:fix(cut(2)/100)*100];
end
set(gca,'XTick',log(ticks))
set(gca,'XTickLabel',ticks)
set(gca,'ZTick',log([10^1,10^2,10^3,10^4,10^5,10^6,10^7,10^8]))
set(gca,'ZTickLabel',{'1e1','1e2','1e3','1e4','1e5','1e6','1e7','1e8'})

cch=colorbar;
set(cch,'Ytick',log([10^1,10^2,10^3,10^4,10^5,10^6,10^7,10^8]))
set(cch,'YTickLabel',{'1e1','1e2','1e3','1e4','1e5','1e6','1e7','1e8'})

econt=1;
col=0;
if econt==1
    if A==1 %set contour steps depending on species
        steps=[fitenergy,1.1,2,3,4,5,10,20:10:floor(cut(2)/10)*10];
    else
        steps=[fitenergy,20,50,100,150,200,250,300:100:floor(cut(2)/10)*10];
    end
	for contstep=steps
        if contstep<min(Energyvec) || contstep>max(Energyvec)
        else
        Ediff=sqrt((Energyvec-contstep).^2);
        [value,index]=min(Ediff);
        hold on
        if contstep==fitenergy
            energy=plot3(log(Energyvec(index))+0*[1:length(angle(:,1))],angle(:,1),log(specmap(:,index)),'linewidth',1.5,'color',[0 0 0]);
        else
            energy=plot3(log(Energyvec(index))+0*[1:length(angle(:,1))],angle(:,1),log(specmap(:,index)),'linewidth',1.5,'color',[0.4 0.4 0.4]);
        end
        hold off
        col=col+1;
        contour(col,:)=specmap(:,index);
        contourE(col,1)=contstep;
        contourA(col,:)=angle(:,1);
        end
	end           
else
end
acont=1;
if acont==1
    steps=round(min(angle(:,1)/10))*10:5:round(max(angle(:,1)/10))*10; 
	for contstep=steps
        if contstep<min(angle(:,1)) || contstep>max(angle(:,1))
        else
        adiff=sqrt((angle(:,1)-contstep).^2);
        [value,index]=min(adiff);
        hold on
        plot3(log(Energyvec),angle(index,1)+0*[1:length(Energyvec)],log(specmap(index,:)),'linewidth',1.5,'color',[0.4 0.4 0.4])
        hold off
        end
	end           
else
end

xlabel('Energy (MeV)');
ylabel('Angle(°)')
zlabel('Counts/MeV/msr');
colorbar off
if exist('vw','var')==1
    set(handles.spectrum,'View',vw);
end


function calibratedata_Callback(hObject, eventdata, handles)
global limits
line=getappdata(handles.main,'line');
bfit=getappdata(handles.main,'bfit');
fitenergy=str2double(get(handles.fitenergy,'string'));
fitorder=get(handles.fitorder,'Value');

if fitorder==1
    f = fittype('a*x+b');
    [c,gof] = fit(line(:,1),line(:,2),f,'Startpoint',[1,1]);
    correct=c.a.*bfit(:,1)+c.b;
elseif fitorder==2
    f = fittype('a*x^2+b*x+c');
    [c,gof] = fit(line(:,1),line(:,2),f,'Startpoint',[1,1,1]);
    correct=c.a.*bfit(:,1).^2+c.b.*bfit(:,1)+c.c;
elseif fitorder==3
    f = fittype('a*x^3+b*x^2+c*x+d');
    [c,gof] = fit(line(:,1),line(:,2),f,'Startpoint',[1,1,1,1]);
    correct=c.a.*bfit(:,1).^3+c.b.*bfit(:,1).^2+c.c*bfit(:,1)+c.d;
elseif fitorder==4
    f = fittype('a*x^4+b*x^3+c*x^2+d*x+e');
    [c,gof] = fit(line(:,1),line(:,2),f,'Startpoint',[1,1,1,1,1]);
    correct=c.a.*bfit(:,1).^4+c.b.*bfit(:,1).^3+c.c*bfit(:,1).^2+c.d*bfit(:,1)+c.e;
elseif fitorder==5
    f = fittype('a*x^5+b*x^4+c*x^3+d*x^2+e*x+f');
    [c,gof] = fit(line(:,1),line(:,2),f,'Startpoint',[1,1,1,1,1,1]);
    correct=c.a.*bfit(:,1).^5+c.b.*bfit(:,1).^4+c.c*bfit(:,1).^3+c.d*bfit(:,1).^2+c.e*bfit(:,1)+c.f;    
elseif fitorder==6
    f = fittype('a*x^6+b*x^5+c*x^4+d*x^3+e*x^2+f*x+g');
    [c,gof] = fit(line(:,1),line(:,2),f,'Startpoint',[1,1,1,1,1,1,1]);
    correct=c.a.*bfit(:,1).^6+c.b.*bfit(:,1).^5+c.c*bfit(:,1).^4+c.d*bfit(:,1).^3+c.e*bfit(:,1).^2+c.f*bfit(:,1)+c.g;   
end
plot(handles.lineout,line(:,1),line(:,2))
hold(handles.lineout,'on')
axes(handles.lineout)
plot(c)
hold(handles.lineout,'off')

%{
correct=fit.coeff(1).*bfit(:,1)+fit.coeff(2);
correct=fit.coeff(1).*bfit(:,1).^2+fit.coeff(2).*bfit(:,1)+fit.coeff(3);
correct=fit.coeff(1).*bfit(:,1).^3+fit.coeff(2).*bfit(:,1).^2+fit.coeff(3).*bfit(:,1)+fit.coeff(4);
correct=fit.coeff(1).*bfit(:,1).^4+fit.coeff(2).*bfit(:,1).^3+fit.coeff(3).*bfit(:,1).^2+fit.coeff(4).*bfit(:,1)+fit.coeff(5);
correct=fit.coeff(1).*bfit(:,1).^5+fit.coeff(2).*bfit(:,1).^4+fit.coeff(3).*bfit(:,1).^3+fit.coeff(4).*bfit(:,1).^2+fit.coeff(5).*bfit(:,1)+fit.coeff(6);
correct=fit.coeff(1).*bfit(:,1).^6+fit.coeff(2).*bfit(:,1).^5+fit.coeff(3).*bfit(:,1).^4+fit.coeff(4).*bfit(:,1).^3+fit.coeff(5).*bfit(:,1).^2+fit.coeff(6).*bfit(:,1)+fit.coeff(7);
%}

bfit(:,3)=bfit(:,2).*sqrt(fitenergy./correct(:));

plot(handles.fieldcalibration,bfit(:,1),bfit(:,2),'color','r')
hold(handles.fieldcalibration,'on')
plot(handles.fieldcalibration,bfit(:,1),bfit(:,3),'color','b')
hold(handles.fieldcalibration,'off')

bfit_new(:,1)=bfit(:,1);
bfit_new(:,2)=bfit(:,3);
    
setappdata(handles.main,'bfit_new',bfit_new)
set(handles.savecalib,'Enable','on')
legend(handles.fieldcalibration,'Old calibration','New calibration')

Ylimit=get(handles.fieldcalibration,'Ylim');
y=Ylimit(1):Ylimit(2);
hold(handles.fieldcalibration,'on')
limits(1)=plot(handles.fieldcalibration,get(handles.sli_min,'value')+0*y,y,'color','black');
limits(2)=plot(handles.fieldcalibration,get(handles.sli_max,'value')+0*y,y,'color','black');
hold(handles.fieldcalibration,'off')

% --- Executes on selection change in fitorder.
function fitorder_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function fitorder_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fitenergy_Callback(hObject, eventdata, handles)
new_E=str2double(get(hObject,'string'));

if isnan(new_E) || new_E<0
    fitenergy=10.5;
end

plotdata_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function fitenergy_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in srim.
function srim_Callback(hObject, eventdata, handles)
srimcalc


% --- Executes on slider movement.
function limits_Callback(hObject, eventdata, handles)
global limits
mode=get(hObject,'Tag');
sli_mini=get(handles.sli_min,'Min');
sli_maxi=get(handles.sli_min,'Max');
smin=get(handles.sli_min,'value');
smax=get(handles.sli_max,'value');
tmin=str2double(get(handles.t_min,'string'));
tmax=str2double(get(handles.t_max,'string'));
if strcmp(mode,'sli_min')
    if smin>smax
        set(handles.sli_min,'value',smax)
        set(handles.t_min,'string',num2str(smax))
    else
        set(handles.t_min,'string',num2str(smin))
    end
elseif strcmp(mode,'sli_max')
    if smax<smin
        set(handles.sli_max,'value',smin)
        set(handles.t_max,'string',num2str(smin))
    else
        set(handles.t_max,'string',num2str(smax))
    end

elseif strcmp(mode,'t_min')
    if tmin>smax || tmin<sli_mini || isnan(tmin)
        set(handles.t_min,'string',num2str(smin))
    else
        set(handles.sli_min,'value',tmin)
    end
elseif strcmp(mode,'t_max')
    if tmax>sli_maxi || tmax<smin || isnan(tmax)
        set(handles.t_max,'string',num2str(smax))
    else
        set(handles.sli_max,'value',tmax)
    end
end

if ishandle(limits)
    delete(limits)
    Ylimit=get(handles.fieldcalibration,'Ylim');
    y=Ylimit(1):Ylimit(2);
    hold(handles.fieldcalibration,'on')
    limits(1)=plot(handles.fieldcalibration,get(handles.sli_min,'value')+0*y,y,'color','black');
    limits(2)=plot(handles.fieldcalibration,get(handles.sli_max,'value')+0*y,y,'color','black');
    hold(handles.fieldcalibration,'off')
    pause(0.01)
end





% --- Executes during object creation, after setting all properties.
function limits_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
