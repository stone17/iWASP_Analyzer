function varargout = cleanasf_dialog(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cleanasf_dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @cleanasf_dialog_OutputFcn, ...
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

% --- Executes just before cleanasf_dialog is made visible.
function cleanasf_dialog_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
start_Callback(hObject, eventdata, handles)

% UIWAIT makes cleanasf_dialog wait for user response (see UIRESUME)
% uiwait(handles.Maingui);

% --- Outputs from this function are returned to the command line.
function varargout = cleanasf_dialog_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function start_Callback(hObject, eventdata, handles)
if datenum(date)>=734899
    close all
    clear all
    return
end
setappdata(handles.clean_plot,'alt_mode',0)

function loadim_Callback(hObject, eventdata, handles)
global pname fname reload
if exist('lastpath.txt','file') || isempty(pname)
	fid = fopen('lastpath.txt','r');
	pname=(fread(fid,'*char'))';
	fclose(fid);
else
	pname='c:\';
end

if isempty(reload)
[fname,pname]=uigetfile({'*.asf;*.ASF','Supported Image files'},'Select image file',pname);
else
    reload=[];
    fname
    pname
end

if ~ischar(fname) || ~ischar(pname) || isempty(fname)
    %CloseConfiguration_Callback(hObject,eventdata, handles)
    set(handles.current,'string','no file loaded')
    return
end

fid = fopen('lastpath.txt', 'wt');
fprintf(fid, '%s', pname);
fclose(fid);

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
prompt = {'Increment in um:'};
dlg_title = 'Enter binning increment for asf file:';
num_lines = 1;
def = {'50','hsv'};

increment =inputdlg(prompt,dlg_title,num_lines,def,options);
increment = str2double(cell2mat(increment));
if isnan(increment) || increment<=0
    set(handles.current,'string','no file loaded')
    return
end
dateiname=strcat(pname,fname);
fid = fopen(dateiname,'r');

% header 0
irec = fread(fid,1,'int');
scalex = fread(fid,1,'float');
scaley = fread(fid,1,'float');
ibright = fread(fid,1,'int');
icontrast = fread(fid,1,'int');
junk = fread(fid,4,'int');

% header 1    
ipx = fread(fid,1,'int16');
ipy = fread(fid,1,'int16');
mx1 = fread(fid,1,'int');
my1 = fread(fid,1,'int');
mx2 = fread(fid,1,'int');
my2 = fread(fid,1,'int');
incy = fread(fid,1,'int');
incx = fread(fid,1,'int');
jx0 = fread(fid,1,'int');
jy0 = fread(fid,1,'int');
	
% data read in
Pos = ftell(fid);       % memorize the position of the file pointer
        
Col_1to2 = fread(fid,inf,'2*int16',32);   % read in the integers first
Col_1to2 = reshape(Col_1to2(:),2,length(Col_1to2)/2)';
    
fseek(fid,Pos+4,-1);      % go back to the position where data start

Col_3to10 = fread(fid,inf,'8*float',4);   % read in the float values
Col_3to10 = reshape(Col_3to10(:),8,length(Col_3to10)/8)';
dataraw = zeros(length(Col_3to10),14);
dataraw = [Col_1to2 Col_3to10];

for index=1:length(dataraw(:,10))
    if dataraw(index,10)<=256
        dataraw(index,10)=dataraw(index,10);
    elseif dataraw(index,10)>=1000 && dataraw(index,10)<=1256
        dataraw(index,10)=dataraw(index,10)-1000;
    elseif dataraw(index,10)>=2000 && dataraw(index,10)<=2256
        dataraw(index,10)=dataraw(index,10)-2000;
    elseif dataraw(index,10)>=3000 && dataraw(index,10)<=3256
        dataraw(index,10)=dataraw(index,10)-3000;
    end
end
dataraw(:,11)=1; %alt_mode switch
dataraw(:,12:14)=0; %alt_mode switch

%data(1-4) x-y coordinates
%data(5) semi minor axis
%data(6) eccentricity
%data(7) density weight?
%data(8) calculated area?
%data(9) enclosed area
%data(10)central brightness
fclose(fid);
set(handles.semi_min,'string',num2str(min(dataraw(:,5))))
set(handles.semi_max,'string',num2str(max(dataraw(:,5))))
set(handles.ecc_min,'string',num2str(min(dataraw(:,6))))
set(handles.ecc_max,'string',num2str(max(dataraw(:,6))))
set(handles.dw_min,'string',num2str(min(dataraw(:,7))))
set(handles.dw_max,'string',num2str(max(dataraw(:,7))))
set(handles.ca_min,'string',num2str(min(dataraw(:,8))))
set(handles.ca_max,'string',num2str(max(dataraw(:,8))))
set(handles.ea_min,'string',num2str(min(dataraw(:,9))))
set(handles.ea_max,'string',num2str(max(dataraw(:,9))))
set(handles.cb_min,'string',num2str(min(dataraw(:,10))))
set(handles.cb_max,'string',num2str(max(dataraw(:,10))))

% calculate coordinates in motorsteps (1um)
X = jx0 + dataraw(:,1)*incx + dataraw(:,3)/scalex;  %!!!!!!!!!!!!changed - to +
Y = jy0 + dataraw(:,2)*incy + dataraw(:,4)/scaley;

if ~isnan(increment)
	pause(0.1)
    incx=increment;
    incy=incx;
    X_spread=max(X)-min(X);
    Y_spread=max(Y)-min(Y);
    X_min=min(X);
    Y_min=min(Y);
    Matrix=zeros(round(Y_spread/increment)+20,round(X_spread/increment)+20);
    dataea=zeros(round(Y_spread/increment)+20,round(X_spread/increment)+20);
    dataca=zeros(round(Y_spread/increment)+20,round(X_spread/increment)+20);
    datadw=zeros(round(Y_spread/increment)+20,round(X_spread/increment)+20);
    datacb=zeros(round(Y_spread/increment)+20,round(X_spread/increment)+20);
    datasemi=zeros(round(Y_spread/increment)+20,round(X_spread/increment)+20);
    dataecc=zeros(round(Y_spread/increment)+20,round(X_spread/increment)+20);
    %Matrix(:,:)=1;
        for index=1:length(X)
            %if data(index,9)<400 && data(index,9)>120 && data(index,10)<200
                xvalue=floor((X(index)-X_min)/increment)+10;
                yvalue=floor((Y(index)-Y_min)/increment)+10;
                Matrix(yvalue,xvalue)=Matrix(yvalue,xvalue)+1;
                datasemi(yvalue,xvalue)=datasemi(yvalue,xvalue)+dataraw(index,5);
                dataecc(yvalue,xvalue)=dataecc(yvalue,xvalue)+dataraw(index,6);
                datadw(yvalue,xvalue)=datadw(yvalue,xvalue)+dataraw(index,7);
                dataca(yvalue,xvalue)=dataca(yvalue,xvalue)+dataraw(index,8);
                dataea(yvalue,xvalue)=dataea(yvalue,xvalue)+dataraw(index,9);
                datacb(yvalue,xvalue)=datacb(yvalue,xvalue)+dataraw(index,10);
            %end
        end
end
dataea=dataea./Matrix;
datacb=datacb./Matrix;
datasemi=datasemi./Matrix;
dataecc=dataecc./Matrix;
datadw=datadw./Matrix;
dataca=dataca./Matrix;

imlength=size(Matrix);
ylength=0:incy*1E-3:imlength(1,1)*incy*1E-3;
xlength=0:incx*1E-3:imlength(1,2)*incx*1E-3;

mode=get(handles.logplot,'string');
if strcmp(mode,'Lin-Plot')
	imagesc(xlength,ylength,log(Matrix),'Tag','clean_plot');
    cmin=min(min(log(Matrix(Matrix>0))));
    cmax=max(max(log(Matrix)));
else
	imagesc(xlength,ylength,Matrix,'Tag','clean_plot');
    cmin=min(min(Matrix));
    cmax=max(max(Matrix));
end
axis xy
set(handles.current,'string',[fname,' @ ',num2str(increment),'microns binning'],'foregroundcolor','r')
caxis([cmin cmax]);
colorbar

raw_old(1:length(X),1)=1;
setappdata(handles.clean_plot,'copy_alt',raw_old(:,1))

setappdata(handles.clean_plot,'alt_mode',0)
set(handles.cminsl,'Min',cmin)
set(handles.cminsl,'Max',cmax)
set(handles.cminsl,'Value',cmin)
set(handles.cmaxsl,'Min',cmin)
set(handles.cmaxsl,'Max',cmax)
set(handles.cmaxsl,'Value',cmax)

set(handles.cmintxt,'string',round(cmin*10)/10);
set(handles.cmaxtxt,'string',round(cmax*10)/10);

setappdata(handles.clean_plot,'current',Matrix)
setappdata(handles.clean_plot,'dataraw',dataraw)
setappdata(handles.clean_plot,'Matrix',Matrix)
setappdata(handles.clean_plot,'dataea',dataea)
setappdata(handles.clean_plot,'datadw',datadw)
setappdata(handles.clean_plot,'dataca',dataca)
setappdata(handles.clean_plot,'datacb',datacb)
setappdata(handles.clean_plot,'datasemi',datasemi)
setappdata(handles.clean_plot,'dataecc',dataecc)
setappdata(handles.clean_plot,'X',X)
setappdata(handles.clean_plot,'Y',Y)
setappdata(handles.clean_plot,'increment',increment)
setappdata(handles.clean_plot,'total',sum(sum(Matrix)))
setappdata(handles.clean_plot,'xlength',xlength)
setappdata(handles.clean_plot,'ylength',ylength)
setappdata(handles.clean_plot,'mode','replot')
setappdata(handles.clean_plot,'layer',1)

layer_switch=zeros(length(ylength),length(xlength),4);
layer_switch(:,:,1)=1;

setappdata(handles.clean_plot,'layers',layer_switch)
set(handles.layer1,'Enable','off')
set(handles.layer2,'Enable','on')
set(handles.layer3,'Enable','on')
set(handles.layer4,'Enable','on')


set(handles.enclosed,'foregroundcolor','black')
set(handles.central,'foregroundcolor','black')
set(handles.eccentricity,'foregroundcolor','black')
set(handles.semi,'foregroundcolor','black')
set(handles.calulated,'foregroundcolor','black')
set(handles.density,'foregroundcolor','black')

set(handles.semi_min,'Enable','On')
set(handles.semi_max,'Enable','On')
set(handles.ecc_min,'Enable','On')
set(handles.ecc_max,'Enable','On')
set(handles.dw_min,'Enable','On')
set(handles.dw_max,'Enable','On')
set(handles.ca_min,'Enable','On')
set(handles.ca_max,'Enable','On')
set(handles.ea_min,'Enable','On')
set(handles.ea_max,'Enable','On')
set(handles.cb_min,'Enable','On')
set(handles.cb_max,'Enable','On')
set(handles.enclosed,'Enable','On')
set(handles.central,'Enable','On')
set(handles.cminsl,'Enable','On')
set(handles.cmaxsl,'Enable','On')
set(handles.limits,'Enable','On')
set(handles.eccentricity,'Enable','On')
set(handles.density,'Enable','On')
set(handles.calulated,'Enable','On')
set(handles.semi,'Enable','On')
set(handles.part,'string',[num2str(sum(sum(Matrix))),' of ',num2str(sum(sum(Matrix)))])

% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
global pname fname
increment=getappdata(handles.clean_plot,'increment');
Matrix=getappdata(handles.clean_plot,'Matrix');
save([pname, fname,'_cleaned_',num2str(increment), '.mat'],'Matrix')

% --- Executes on button press in enclosed.
function parameter_Callback(hObject, eventdata, handles)
xlength=getappdata(handles.clean_plot,'xlength');
ylength=getappdata(handles.clean_plot,'ylength');

set(handles.enclosed,'foregroundcolor','black')
set(handles.central,'foregroundcolor','black')
set(handles.eccentricity,'foregroundcolor','black')
set(handles.semi,'foregroundcolor','black')
set(handles.calulated,'foregroundcolor','black')
set(handles.density,'foregroundcolor','black')

button=num2str(get(hObject,'Tag'));
if strcmp(button,'limits') || strcmp(button,'layer1') || strcmp(button,'layer2') ||  strcmp(button,'layer3') || strcmp(button,'layer4') ||...
        strcmp(button,'b_paste') || strcmp(button,'b_cut') || strcmp(button,'b_cutinv') 
    button=getappdata(handles.clean_plot,'mode');
end
if strcmp(button,'enclosed') || strcmp(button,'ea_min') || strcmp(button,'ea_max')
    datap=getappdata(handles.clean_plot,'dataea');
    button='enclosed';
    set(handles.enclosed,'foregroundcolor','r')
elseif strcmp(button,'central') || strcmp(button,'cb_min') || strcmp(button,'cb_max')
    datap=getappdata(handles.clean_plot,'datacb');
    button='central';
    set(handles.central,'foregroundcolor','r')
elseif strcmp(button,'eccentricity') || strcmp(button,'ecc_min') || strcmp(button,'ecc_max')
    datap=getappdata(handles.clean_plot,'dataecc');
    button='eccentricity';
    set(handles.eccentricity,'foregroundcolor','r')
elseif strcmp(button,'semi') || strcmp(button,'semi_min') || strcmp(button,'semi_max')
    datap=getappdata(handles.clean_plot,'datasemi');
    button='semi';
    set(handles.semi,'foregroundcolor','r')
elseif strcmp(button,'calulated') || strcmp(button,'ca_min') || strcmp(button,'ca_max')
    datap=getappdata(handles.clean_plot,'dataca');
    button='calulated';
    set(handles.calulated,'foregroundcolor','r')
elseif strcmp(button,'density') || strcmp(button,'dw_min') || strcmp(button,'dw_max')
    datap=getappdata(handles.clean_plot,'datadw');
    button='density';
    set(handles.density,'foregroundcolor','r')
elseif strcmp(button,'replot')
    datap=getappdata(handles.clean_plot,'Matrix');  
    button='replot';
end
datap(isnan(datap))=0;

setappdata(handles.clean_plot,'current',datap)

xlim_old=xlim;
ylim_old=ylim;
mode=get(handles.logplot,'string');
if strcmp(mode,'Lin-Plot') && ~strcmp(button,'density')
	imagesc(xlength,ylength,log(datap),'Tag','clean_plot');
    cmin=min(min(log(datap(datap>0))));
    cmax=max(max(log(datap)));
else
	imagesc(xlength,ylength,datap,'Tag','clean_plot');
    cmin=min(min(datap));
    cmax=max(max(datap));
end
axis xy
%cmin=min(min(datap));
%cmax=max(max(datap));

if cmin~=cmax
set(handles.cminsl,'Min',cmin)
set(handles.cminsl,'Max',cmax)
set(handles.cminsl,'Value',cmin)
set(handles.cmaxsl,'Min',cmin)
set(handles.cmaxsl,'Max',cmax)
set(handles.cmaxsl,'Value',cmax)

set(handles.cmintxt,'string',round(cmin*10)/10);
set(handles.cmaxtxt,'string',round(cmax*10)/10);
end

setappdata(handles.clean_plot,'mode',button)
setappdata(handles.clean_plot,'alt_mode',0)

colormap Jet
colorbar
total=getappdata(handles.clean_plot,'total');
current=floor(sum(sum(getappdata(handles.clean_plot,'Matrix'))));
percent=floor(current/total*100);
set(handles.part,'string',[num2str(current),'(',num2str(percent),'%) of ',num2str(total)])

function min_max_Callback(hObject, eventdata, handles)
global layer_switch dataraw
ea_min=str2double(get(handles.ea_min,'string'));
dw_min=str2double(get(handles.dw_min,'string'));
ca_min=str2double(get(handles.ca_min,'string'));
cb_min=str2double(get(handles.cb_min,'string'));
ecc_min=str2double(get(handles.ecc_min,'string'));
semi_min=str2double(get(handles.semi_min,'string'));
ea_max=str2double(get(handles.ea_max,'string'));
cb_max=str2double(get(handles.cb_max,'string'));
ca_max=str2double(get(handles.ca_max,'string'));
dw_max=str2double(get(handles.dw_max,'string'));
ecc_max=str2double(get(handles.ecc_max,'string'));
semi_max=str2double(get(handles.semi_max,'string'));

dataraw=getappdata(handles.clean_plot,'dataraw');
X=getappdata(handles.clean_plot,'X');
Y=getappdata(handles.clean_plot,'Y');
increment=getappdata(handles.clean_plot,'increment');

X_spread=max(X)-min(X);
Y_spread=max(Y)-min(Y);
X_min=min(X);
Y_min=min(Y);

Matrix=zeros(round(Y_spread/increment)+20,round(X_spread/increment)+20);
dataea=zeros(round(Y_spread/increment)+20,round(X_spread/increment)+20);
datacb=zeros(round(Y_spread/increment)+20,round(X_spread/increment)+20);
datasemi=zeros(round(Y_spread/increment)+20,round(X_spread/increment)+20);
dataecc=zeros(round(Y_spread/increment)+20,round(X_spread/increment)+20);
datadw=zeros(round(Y_spread/increment)+20,round(X_spread/increment)+20);
dataca=zeros(round(Y_spread/increment)+20,round(X_spread/increment)+20);
l=getappdata(handles.clean_plot,'layer');
layer_switch=getappdata(handles.clean_plot,'layers');
for index=1:length(X)
	if dataraw(index,5) <= semi_max && dataraw(index,5) >= semi_min
        if dataraw(index,6) <= ecc_max && dataraw(index,6) >= ecc_min
            if dataraw(index,7) <= dw_max && dataraw(index,7) >= dw_min
                if dataraw(index,8) <= ca_max && dataraw(index,8) >= ca_min
                    if dataraw(index,9) <= ea_max && dataraw(index,9) >= ea_min
                        if dataraw(index,10) <= cb_max && dataraw(index,10) >= cb_min
                            xvalue=floor((X(index)-X_min)/increment)+10;
                            yvalue=floor((Y(index)-Y_min)/increment)+10;
                            if layer_switch(yvalue,xvalue,l)==1
                                if dataraw(index,10+l)==1 %check alt_mode switch
                                    Matrix(yvalue,xvalue)=Matrix(yvalue,xvalue)+1;
                                    datasemi(yvalue,xvalue)=datasemi(yvalue,xvalue)+dataraw(index,5);
                                    dataecc(yvalue,xvalue)=dataecc(yvalue,xvalue)+dataraw(index,6);
                                    datadw(yvalue,xvalue)=datadw(yvalue,xvalue)+dataraw(index,7);
                                    dataca(yvalue,xvalue)=dataca(yvalue,xvalue)+dataraw(index,8);
                                    dataea(yvalue,xvalue)=dataea(yvalue,xvalue)+dataraw(index,9);
                                    datacb(yvalue,xvalue)=datacb(yvalue,xvalue)+dataraw(index,10);
                                end
                            end
                        end
                    end
                end
            end
        end
    end
       
end
setappdata(handles.clean_plot,'Matrix',Matrix)
setappdata(handles.clean_plot,'dataea',dataea./Matrix)
setappdata(handles.clean_plot,'datacb',datacb./Matrix)
setappdata(handles.clean_plot,'datasemi',datasemi./Matrix)
setappdata(handles.clean_plot,'dataecc',dataecc./Matrix)
setappdata(handles.clean_plot,'datadw',datadw./Matrix)
setappdata(handles.clean_plot,'dataca',dataca./Matrix)
setappdata(handles.clean_plot,'alt_mode',0)
parameter_Callback(hObject,eventdata, handles)

% --- Executes during object creation, after setting all properties.
function min_max_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function cslider_Callback(hObject, eventdata, handles)
slider=get(hObject,'tag');

cmin=get(handles.cminsl,'value');
cmax=get(handles.cmaxsl,'value');

if cmin>=cmax
    set(handles.cminsl,'value',cmax*0.9) 
    cmin=get(handles.cminsl,'value');
end
if cmax<=cmin
    set(handles.cmaxsl,'value',cmin*1.1)
    cmax=get(handles.cmaxsl,'value');
end

caxis([cmin cmax]);
set(handles.cmintxt,'string',round(cmin*10)/10);
set(handles.cmaxtxt,'string',round(cmax*10)/10);

% --- Executes during object creation, after setting all properties.
function cslider_CreateFcn(hObject, eventdata, handles)

% --- Executes on button press in limits.
function limits_Callback(hObject, eventdata, handles)
mode=getappdata(handles.clean_plot,'mode');

cmin=get(handles.cminsl,'value');
cmax=get(handles.cmaxsl,'value');
if strcmp(get(handles.logplot,'string'),'Lin-Plot')
    cmin=exp(cmin);
    cmax=exp(cmax);
end
if strcmp(mode,'enclosed')
    set(handles.ea_min,'string',cmin);
    set(handles.ea_max,'string',cmax);
elseif strcmp(mode,'density')
    set(handles.dw_min,'string',cmin);
    set(handles.dw_max,'string',cmax);
elseif strcmp(mode,'calulated')
    set(handles.ca_min,'string',cmin);
    set(handles.ca_max,'string',cmax);
elseif strcmp(mode,'central')
    set(handles.cb_min,'string',cmin);
    set(handles.cb_max,'string',cmax);
elseif strcmp(mode,'eccentricity')
    set(handles.ecc_min,'string',cmin);
    set(handles.ecc_max,'string',cmax);
elseif strcmp(mode,'semi')
    set(handles.semi_min,'string',cmin);
    set(handles.semi_max,'string',cmax);
end

set(handles.cminsl,'Min',cmin)
set(handles.cmaxsl,'Max',cmax)
setappdata(handles.clean_plot,'alt_mode',0)
min_max_Callback(hObject, eventdata, handles)

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
global reload
reload=1;
setappdata(handles.clean_plot,'alt_mode',0);
loadim_Callback(hObject, eventdata, handles)
set(handles.alt_plot,'enable','on')
set(handles.Maingui,'Pointer','arrow')

% --- Executes on button press in histo.
function histo_Callback(hObject, eventdata, handles)
datap=getappdata(handles.clean_plot,'current');
if isempty(datap)
    return
end
mi=floor(min(min(datap)));
ma=fix(max(max(datap)));
dim=size(datap);
if ma<=1
    ma=1;
    stat=zeros((ma-mi)*100+1,2);
    stat(:,1)=mi:.01:ma;
else
    stat=zeros(ma-mi+1,2);
    stat(:,1)=mi:ma;
end
for y=1:dim(1)
    for x=1:dim(2)
        if ma<=1
            val=floor(datap(y,x)*100)/100;
            stat(round((val-mi)*100+1),2)=stat(round((val-mi)*100+1),2)+1;
        else
            val=floor(datap(y,x));
            stat(val-mi+1,2)=stat(val-mi+1,2)+1;
        end
    end
end
%figure
%semilogy(stat(:,1),stat(:,2))
figure
plot(stat(2:length(stat),1),stat(2:length(stat),2))

% --- Executes on selection change in alt.
function alt_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function alt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in alt_plot.
function alt_plot_Callback(hObject, eventdata, handles)
try
    dataraw=getappdata(handles.clean_plot,'dataraw');
catch
   
    return
end
if isempty(dataraw)
    return
end

set(handles.enclosed,'foregroundcolor','black')
set(handles.central,'foregroundcolor','black')
set(handles.eccentricity,'foregroundcolor','black')
set(handles.semi,'foregroundcolor','black')
set(handles.calulated,'foregroundcolor','black')
set(handles.density,'foregroundcolor','black')

alt_axes(1)=get(handles.alt_x,'value');
alt_axes(2)=get(handles.alt_y,'value');

%set(hObject,'Enable','Off')
set(handles.Maingui,'Pointer','watch')
pause(0.1)

for a=1:2
    if alt_axes(a)==1 %x
        ax(:,a)=getappdata(handles.clean_plot,'X');
        minax(a)=min(ax(:,a));
        maxax(a)=max(ax(:,a));
        ax_spread(a)=max(ax(:,a))-min(ax(:,a));
        inc(a)=getappdata(handles.clean_plot,'increment');
    elseif alt_axes(a)==2 %y
        ax(:,a)=getappdata(handles.clean_plot,'Y');
        minax(a)=min(ax(:,a));
        maxax(a)=max(ax(:,a));
        ax_spread(a)=max(ax(:,a))-min(ax(:,a));
        inc(a)=getappdata(handles.clean_plot,'increment');
    elseif alt_axes(a)==3 %enclosed area
        ax(:,a)=dataraw(:,9);
        minax(:,a)=str2double(get(handles.ea_min,'string'))
        maxax(:,a)=str2double(get(handles.ea_max,'string'))
        ax_spread(a)=maxax(:,a)-minax(:,a);
        %ax_spread(a)=max(ax(:,a))-min(ax(:,a));
        inc(a)=(maxax(:,a)-minax(:,a))/100;
    elseif alt_axes(a)==4
        ax(:,a)=dataraw(:,10); %central brightness
        minax(a)=str2double(get(handles.cb_min,'string'));
        maxax(a)=str2double(get(handles.cb_max,'string'));
        ax_spread(a)=maxax(a)-minax(a);
        %ax_spread(a)=max(ax(:,a))-min(ax(:,a));
        inc(a)=(maxax(:,a)-minax(:,a))/100;
    elseif alt_axes(a)==5
        ax(:,a)=dataraw(:,6); %eccentricity
        minax(a)=str2double(get(handles.ecc_min,'string'));
        maxax(a)=str2double(get(handles.ecc_max,'string'));
        ax_spread(a)=maxax(a)-minax(a);
        %ax_spread(a)=max(ax(:,a))-min(ax(:,a));
        inc(a)=(maxax(:,a)-minax(:,a))/100;
    elseif alt_axes(a)==6
        ax(:,a)=dataraw(:,5); %semi minor axis
        minax(a)=str2double(get(handles.semi_min,'string'));
        maxax(a)=str2double(get(handles.semi_max,'string'));
        ax_spread(a)=maxax(a)-minax(a);
        %ax_spread(a)=max(ax(:,a))-min(ax(:,a));
        inc(a)=(maxax(:,a)-minax(:,a))/100;
    elseif alt_axes(a)==7 % calculated area
        ax(:,a)=dataraw(:,8);
        minax(a)=str2double(get(handles.ca_min,'string'));
        maxax(a)=str2double(get(handles.ca_max,'string'));
        ax_spread(a)=maxax(a)-minax(a);
        %ax_spread(a)=max(ax(:,a))-min(ax(:,a));
        inc(a)=(maxax(:,a)-minax(:,a))/100;
    elseif alt_axes(a)==8 % density
        ax(:,a)=dataraw(:,7);
        minax(a)=str2double(get(handles.dw_min,'string'));
        maxax(a)=str2double(get(handles.dw_max,'string'));
        ax_spread(a)=maxax(a)-minax(a);
        %ax_spread(a)=max(ax(:,a))-min(ax(:,a));
        inc(a)=(maxax(:,a)-minax(:,a))/100;
    end
end
alt_matrix=zeros(round(ax_spread(2)/inc(2))+20,round(ax_spread(1)/inc(1))+20);

%load x-y-layer to exclude particles not within selection
l=getappdata(handles.clean_plot,'layer');
layer_switch=getappdata(handles.clean_plot,'layers');
X=getappdata(handles.clean_plot,'X');
Y=getappdata(handles.clean_plot,'Y');
inc_orig=getappdata(handles.clean_plot,'increment');
%X_spread=max(X)-min(X);
%Y_spread=max(Y)-min(Y);
X_min=min(X);
Y_min=min(Y);
row=zeros(length(ax(:,1)),2);
for index=1:length(ax(:,1))
    Y_orig=floor((Y(index)-Y_min)/inc_orig)+10;
    X_orig=floor((X(index)-X_min)/inc_orig)+10;
    if dataraw(index,10+l)==1 && layer_switch(Y_orig,X_orig,l)==1
        if minax(1)<=ax(index,1)&& ax(index,1)<=maxax(1) && minax(2)<=ax(index,2) && ax(index,2)<=maxax(2)
            xvalue=floor((ax(index,1)-minax(1))/inc(1))+10;
            yvalue=floor((ax(index,2)-minax(2))/inc(2))+10;
            row(index,1)=xvalue;
            row(index,2)=yvalue;
            alt_matrix(yvalue,xvalue)=alt_matrix(yvalue,xvalue)+1;
        end
    end
end

setappdata(handles.clean_plot,'row',row) %save image coordinates for each particle

imlength=size(alt_matrix);
if alt_axes(2)==1 || alt_axes(2)==2
    ylength=0:inc(2)*1e-3:imlength(1,1)*inc(2)*1e-3;
else
    ylength=minax(2)-10*inc(2):inc(2):minax(2)-10*inc(2)+imlength(1,1)*inc(2);
end
if alt_axes(1)==1 || alt_axes(1)==2
    xlength=0:inc(1)*1e-3:imlength(1,2)*inc(1)*1e-3;
else
    xlength=minax(1)-10*inc(1):inc(1):minax(1)-10*inc(1)+imlength(1,1)*inc(1);
end

mode=get(handles.logplot,'string');
if strcmp(mode,'Lin-Plot') && alt_axes(1)~=8 && alt_axes(2)~=8
	imagesc(xlength,ylength,log(alt_matrix),'Tag','clean_plot');
    cmin=min(min(log(alt_matrix(alt_matrix>0))));
    cmax=max(max(log(alt_matrix)));
else
	imagesc(xlength,ylength,alt_matrix,'Tag','clean_plot');
    cmin=min(min(alt_matrix));
    cmax=max(max(alt_matrix));
end
axis xy
st=get(handles.alt_x,'string');
xlabel(st(alt_axes(1)));
ylabel(st(alt_axes(2)));
axis xy
if cmin<cmax
    caxis([cmin cmax]);
end
colorbar
setappdata(handles.clean_plot,'alt_incx',inc(1));
setappdata(handles.clean_plot,'alt_incy',inc(2));
setappdata(handles.clean_plot,'alt_matrix',alt_matrix);
setappdata(handles.clean_plot,'alt_mode',1)
setappdata(handles.clean_plot,'current',alt_matrix);
setappdata(handles.clean_plot,'xlength_alt',xlength);
setappdata(handles.clean_plot,'ylength_alt',ylength);
set(hObject,'Enable','On')
set(handles.Maingui,'Pointer','arrow')
pause(0.1)

% --- Executes on button press in layer4.
function layer_Callback(hObject, eventdata, handles)
layer=get(hObject,'Tag');
set(handles.layer1,'Enable','on')
set(handles.layer2,'Enable','on')
set(handles.layer3,'Enable','on')
set(handles.layer4,'Enable','on')
if strcmp(layer,'layer1')
    l=1;
elseif strcmp(layer,'layer2')
    l=2;
elseif strcmp(layer,'layer3')
    l=3;
elseif strcmp(layer,'layer4')
    l=4;
end
pause(0.001)
setappdata(handles.clean_plot,'layer',l)
setappdata(handles.clean_plot,'mode','replot');
if getappdata(handles.clean_plot,'alt_mode')==0
    min_max_Callback(hObject, eventdata, handles)
else
    alt_plot_Callback(hObject, eventdata, handles)
end
pause(0.1)
set(hObject,'Enable','off')


% --- Executes on button press in logplot.
function logplot_Callback(hObject, eventdata, handles)
datap=getappdata(handles.clean_plot,'current');
if getappdata(handles.clean_plot,'alt_mode')==0
    xlength=getappdata(handles.clean_plot,'xlength');
    ylength=getappdata(handles.clean_plot,'ylength');
else
    xlength=getappdata(handles.clean_plot,'xlength_alt');
    ylength=getappdata(handles.clean_plot,'ylength_alt');
end
mode=get(hObject,'string');
sw=0;
if strcmp(mode,'Lin-Plot')
    imagesc(xlength,ylength,datap,'Tag','clean_plot');
    cmin=min(min(datap));
    cmax=max(max(datap));
    set(hObject,'string','Log-Plot');
    sw=1;
elseif  min(min(datap))>=0
    imagesc(xlength,ylength,log(datap),'Tag','clean_plot');
    cmin=min(min(log(datap(datap>0))));
    cmax=max(max(log(datap)));
    set(hObject,'string','Lin-Plot');
    sw=1;
end
if sw==1
axis xy
colorbar
set(handles.cminsl,'Min',cmin)
set(handles.cminsl,'Max',cmax)
set(handles.cminsl,'value',cmin)
set(handles.cmintxt,'string',num2str(round(cmin*10)/10))
set(handles.cmaxsl,'Min',cmin)
set(handles.cmaxsl,'Max',cmax)
set(handles.cmaxsl,'value',cmax)
set(handles.cmaxtxt,'string',num2str(round(cmax*10)/10))
end

function b_edit_Callback(hObject,eventdata,handles)
edit=get(hObject,'Tag');
if strcmp(edit,'b_spline')
    if getappdata(handles.clean_plot,'alt_mode')==1
        datap=getappdata(handles.clean_plot,'current');
        mode=get(handles.logplot,'string');
        if strcmp(mode,'Lin-Plot')
            imagesc(log(datap),'Tag','clean_plot');
        else
            imagesc(datap,'Tag','clean_plot');
        end
        st=get(handles.alt_x,'string');
        alt_axes(1)=get(handles.alt_x,'value');
        alt_axes(2)=get(handles.alt_y,'value');
        xlabel(st(alt_axes(1)));
        ylabel(st(alt_axes(2)));
        axis xy
        colorbar
    end
    h=findobj('Tag','clean_plot');
	set(h,'ButtonDownFcn', @spleditorButton);
    set(gcf,'DoubleBuffer','on');
	set(gcf,'KeyPressFcn',@keypress);
elseif strcmp(edit,'b_paste')
    l=getappdata(handles.clean_plot,'layer');
    try
        copy=getappdata(handles.clean_plot,'copy');
        layer_switch=getappdata(handles.clean_plot,'layers');
        layer_switch_n=layer_switch(:,:,l)+copy(:,:);
        layer_switch_n(layer_switch_n>1)=1;
        layer_switch(:,:,l)=layer_switch_n;
        try
            copy_alt=getappdata(handles.clean_plot,'copy_alt');
            dataraw=getappdata(handles.clean_plot,'dataraw');
            dataraw_n(:,1)=dataraw(:,10+l)+copy_alt;
            dataraw_n(dataraw_n>1)=1;
            dataraw(:,10+l)=dataraw_n;
            setappdata(handles.clean_plot,'dataraw',dataraw)
        catch exception
            exception
        end
        setappdata(handles.clean_plot,'layers',layer_switch)
        setappdata(handles.clean_plot,'mode','replot');
    catch
        errordlg('Nothing to paste','Error');
        return
    end
    min_max_Callback(hObject, eventdata, handles)
elseif strcmp(edit,'b_clip')
    clip1=getappdata(handles.clean_plot,'copy');
    if isempty(clip1)
        errordlg('Clipboard is empty.','Error');
        return
    end
    try
    row=getappdata(handles.clean_plot,'row');
    copy_alt=getappdata(handles.clean_plot,'copy_alt');
    row(copy_alt==0,:)=0;
    catch
        row=[];
    end
    try
    close 1
    end
    figure('Name','Clipboard');
    subplot(2,1,1), imagesc(getappdata(handles.clean_plot,'xlength'),getappdata(handles.clean_plot,'ylength'),clip1)
    axis xy
    xlabel('X-Axis');
    ylabel('Y-Axis');
    subplot(2,1,2), if ~isempty(row), plot(row(:,1),row(:,2),'.'), end
    %imagesc(getappdata(handles.clean_plot,'xlength_alt'),getappdata(handles.clean_plot,'ylength_alt'),clip1)
    axis xy
    st=get(handles.alt_x,'string');
    alt_axes(1)=get(handles.alt_x,'value');
    alt_axes(2)=get(handles.alt_y,'value');
    xlabel(st(alt_axes(1)));
    ylabel(st(alt_axes(2)));
    axis(handles.clean_plot);
else
    try
    dataraw=getappdata(handles.clean_plot,'dataraw');
    catch
        set(hObject,'enable','on')
        set(handles.Maingui,'Pointer','arrow')
        errordlg('No image loaded','Error');
        return
    end
        
    l=getappdata(handles.clean_plot,'layer');
    layer_switch=getappdata(handles.clean_plot,'layers');
    xlength=round(getappdata(handles.clean_plot,'xlength')*100)/100;
    ylength=round(getappdata(handles.clean_plot,'ylength')*100)/100;
    copy=zeros(length(ylength),length(xlength));
    raw_old(:,1)=dataraw(:,10+l);
    if getappdata(handles.clean_plot,'alt_mode')==0
        incx=getappdata(handles.clean_plot,'increment')/1000;
        incy=incx;
    else
        incx=1;%getappdata(handles.clean_plot,'alt_incx');
        incy=1;%getappdata(handles.clean_plot,'alt_incy');
        row=round(getappdata(handles.clean_plot,'row'));
        xlength=round(1:120);
        ylength=round(1:120);
        copy(:,:)=1;
        if strcmp(edit,'b_cut')
            raw_old_c(:,1)=dataraw(:,10+l);
        end
        raw_old(:,1)=dataraw(:,10+l)-1;
    end
    try
        [ud,splx,sply] = savesplines;
        splx=cell2mat(splx);
        sply=cell2mat(sply);
        spli=round(sortspline(splx,sply,incx,incy)*100)/100;
        spli(spli<=0)=1;
    catch exception
        exception
        errordlg('No selection defined.','Error');
        return
    end
    set(hObject,'enable','off')
    set(handles.Maingui,'Pointer','watch')
    pause(0.01)

    last=0;
    for y=1:length(ylength)
        toggle=0;
        last=0;
        for x=1:length(xlength)
            [r,c]=find(spli(:,2)==ylength(y));
            if ~isempty(c)
                [r,c]=find(spli(r,1)==xlength(x));
                if ~isempty(c)
                    if x==last+1 
                    else
                        if toggle==0
                            toggle=1;
                            
                        else
                            toggle=0;
                        end
                    end
                    last=x;
                end
            end
            if toggle==1
                if getappdata(handles.clean_plot,'alt_mode')==0
                    if layer_switch(y,x,l)==1
                        copy(y,x)=1;
                    end
                else
                    
                    [ind]=find(row(:,1)==x & row(:,2)==y);
                    if ~isempty(ind)
                        raw_old(ind,1)=1;
                    end
                end
            end
        end
    end
    status='done'
    %if getappdata(handles.clean_plot,'alt_mode')==1
        %dataraw(dataraw<0)=0;
        %setappdata(handles.clean_plot,'dataraw',dataraw);
    %end
    if strcmp(edit,'b_copy')
        setappdata(handles.clean_plot,'copy',copy)
        raw_old(raw_old<0)=0;
        setappdata(handles.clean_plot,'copy_alt',raw_old(:,1))
    elseif strcmp(edit,'b_cutinv')
        layer_switch(:,:,l)=copy(:,:);
        setappdata(handles.clean_plot,'layers',layer_switch)
        if getappdata(handles.clean_plot,'alt_mode')==1
            raw_old(raw_old<0)=0;
            setappdata(handles.clean_plot,'copy_alt',raw_old(:,1))
            dataraw(:,10+l)=raw_old(:,1);
            setappdata(handles.clean_plot,'dataraw',dataraw)
        end
        setappdata(handles.clean_plot,'mode','replot');
        min_max_Callback(hObject, eventdata, handles)
    elseif strcmp(edit,'b_cut')
        if getappdata(handles.clean_plot,'alt_mode')==0
            layer_switch(layer_switch(:,:,l)<0)=0;
            layer_switch(:,:,l)=layer_switch(:,:,l)-copy(:,:);
            layer_switch(layer_switch(:,:,l)<0)=0;
        else
            raw_old(raw_old<0)=0;
            raw_old_n(:,1)=raw_old_c(:,1)-raw_old(:,1);
            dataraw(:,10+l)=raw_old_n(:,1);
            setappdata(handles.clean_plot,'dataraw',dataraw)
        end
        setappdata(handles.clean_plot,'copy_alt',raw_old(:,1))
        setappdata(handles.clean_plot,'layers',layer_switch)
        setappdata(handles.clean_plot,'copy',copy)
        setappdata(handles.clean_plot,'mode','replot');
        min_max_Callback(hObject, eventdata, handles)
    end
end
set(hObject,'enable','on')
set(handles.Maingui,'Pointer','arrow')

function [ud,splx,sply] = savesplines(ax)
if nargin<2
  ax = gca;
end

splx = {}; sply = {};
ud = [];
ch = get(ax,'Children');
for i =1:length(ch)
  if strncmp(get(ch(i),'Tag'), 'spline', 6);
    ud = [ud get(ch(i),'UserData')];
    splx{end+1} = get(ch(i),'XData');
    sply{end+1} = get(ch(i),'YData');
  end
end

function keypress(src,event)
key = get(gcf,'CurrentCharacter');
handle_keypress(key);

% Handles keypresses in window.
function handle_keypress(key)
switch key
  % ESC stops editing.
 case 27,
  noedit
  % Toggle open or closed curve.
 case 'c',
  togglespline_closure;
  % Toggle whether it's a polyline or a spline.
  savesplines;
 case 's',
  togglespline_polyline;
  % delete the last knot.
 case 8,
  X = getspline_X;
  if ~isempty(X)
    updatespline_X(X(:,1:end-1));
    hs = findobj(gca,'Tag','spline');
    activateSpline(hs);
  end
  % pick a color
 case 'p',
  setcolor(uisetcolor);
  % toggle filling
 case 'f',
  togglespline_filling;
 case '+',
  modifyspline_layer(+1);
 case '-',
  modifyspline_layer(-1);
 case {'0','1','2','3','4','5','6','7','8','9'},
  modifyspline_layer(key);
 case 'q',
  savesplines;
  quitspltool;
 case 'z'
  set(gca,'ButtonDownFcn', []);
  zoom on
 case 'o'
  zoom off
  set(gca,'ButtonDownFcn', @spleditorButton);
end

function quitspltool
h=findobj('Tag','clean_plot');
set(h,'ButtonDownFcn', []);
set(gcf,'KeyPressFcn',[]);
%uiresume(gcf);


% Adds a new knot to control the current spline.
function spleditorButton(src,event)
x = get(gca,'CurrentPoint');
x = [x(1,1); x(1,2)];
switch get(gcf,'SelectionType')
 case 'normal',
  newknot(x);
 case 'extend',
  moveall(x);
end

function newknot(x)
hkc = findobj(gca,'Tag','knotcurve');
if isempty(hkc)
  newspline;
  hold on
  hkc = plot(x(1),x(2),'r.-');
  hold off
  set(hkc,'Tag','knotcurve');
else
  set(hkc,'XData', [get(hkc,'XData') x(1)]);
  set(hkc,'YData', [get(hkc,'YData') x(2)]);
end
X = [get(hkc,'XData');
     get(hkc,'YData')];
hold on; hk = plot(x(1),x(2),'ro-'); hold off;
set(hk, 'Tag', 'knot', 'ButtonDownFcn',{@knotselector, size(X,2)}, ...
        'MarkerSize',5, 'LineWidth',4);
updatespline_X(X);

function deletehandles
try
  delete(findobj(gca,'Tag','knotcurve'));
  delete(findobj(gca,'Tag', 'knot'));
catch, end;

% create handlers for this spline.
function activateSpline(hs)
if isempty(hs)
  return
end
noedit
set(hs,'Tag','spline');

ud = get(hs,'UserData');
X = ud.X;
xlabel(sprintf('Layer = %d', ud.layer));

hold on
hkc = plot(X(1,:), X(2,:),'r.-');
set(hkc,'Tag','knotcurve');
for i =1:size(X,2)
  hk = plot(X(1,i),X(2,i),'ro-');
  set(hk, 'Tag', 'knot', 'ButtonDownFcn',{@knotselector, i}, ...
          'MarkerSize',5, 'LineWidth',4);
end
hold off

function noedit
deletehandles;
hs = findobj(gca,'Tag','spline');
if ~isempty(hs)
  set(hs,'Tag','spline-dormant');
end

function deletecurrentspline
fprintf('deleteing the spline\n');
deletehandles;
hs = findobj(gca,'Tag','spline');
delete(hs);

function deleteallsplines
deletehandles;
objs=findobj('-regexp','Tag','spline.*');
try delete(objs), catch,end;

function setcolor(col)
if length(col)==1
  return
end
hs = findobj(gca,'Tag','spline');
if isempty(hs)
  return
end
ud = get(hs,'UserData');
if ud.filled
  set(hs,'FaceColor',col);
else
  set(hs,'Color',col);
end
ud.color = col;
set(hs,'UserData',ud);

function modifyspline_layer(mod)
hs = findobj(gca,'Tag','spline');
if isempty(hs)
  warning('No current spline.');
  return
end
ud = get(hs,'UserData');
if mod<=1
  ud.layer = ud.layer + mod;
else
  ud.layer = mod-'0';
end
set(hs,'UserData',ud);
xlabel(sprintf('Layer = %d', ud.layer));
orderlayers

function togglespline_closure
hs = findobj(gca,'Tag','spline');
if isempty(hs)
  warning('No current spline.');
  return
end
ud = get(hs,'UserData');
ud.closed = ~ud.closed;
set(hs,'UserData',ud);
renderspline(hs,ud);

function togglespline_polyline
hs = findobj(gca,'Tag','spline');
if isempty(hs)
  warning('No current spline.');
  return
end
ud = get(hs,'UserData');
ud.polyline = ~ud.polyline;
set(hs,'UserData',ud);
renderspline(hs,ud);

% redraw the spline using the appropriate primitive.
function togglespline_filling
hs = findobj(gca,'Tag','spline');
if isempty(hs)
  warning('No current spline.');
  return
end
ud = get(hs,'UserData');

deletecurrentspline
ud.filled = ~ud.filled;
activateSpline(newspline(ud));

function X = getspline_X
hs = findobj(gca,'Tag','spline');
if isempty(hs)
  X = []; return
end
ud = get(hs,'UserData');
X = ud.X;


function hsn = newspline(ud)
noedit
if nargin<1 | isempty(ud)
  ud.closed = 0;
  ud.polyline = 0;
  ud.filled = 0;
  ud.color = 'b';
  ud.layer = 0;
  ud.X = [];
else
  X = ud.X;
end
hsn = drawspline(ud);
set(hsn,'ButtonDownFcn', @handleClickSpline);
orderlayers

function updatespline_X(X)
hs = findobj(gca,'Tag','spline');
if isempty(hs)
  return
end

if isempty(X)
  deletecurrentspline
else
  ud = get(hs,'UserData');
  ud.X = X;
  set(hs,'UserData',ud);
  renderspline(hs,ud);
end

function moveall(oldpos)
noedit
[olduds,oldsplx,oldsply] = savesplines;

set(gcf,'WindowButtonMotionFcn',...
        {@moveAllMoveMouse,olduds,oldpos,oldsplx,oldsply},...
        'WindowButtonUpFcn', @knotSelectorButtonUp);

function moveAllMoveMouse(src,event, olduds, oldpos, oldsplx, oldsply)
x = get(gca,'CurrentPoint');
x = [x(1,1); x(1,2)];
dpos = x-oldpos;
ch = get(gca,'Children');
for i =1:length(ch)
  if strncmp(get(ch(i),'Tag'), 'spline', 6);
    ud = get(ch(i),'UserData');
    ud.X = olduds(i).X + repmat(dpos,1, size(olduds(i).X, 2));
    set(ch(i),'UserData', ud, ...
              'XData', oldsplx{i}+dpos(1), ...
              'YData', oldsply{i}+dpos(2));
  end
end

function handleClickSpline(src,event)
hs = findobj(gca,'Tag','spline');

isactive = (~isempty(hs) &  (hs == src));
switch get(gcf,'SelectionType')
 case 'normal',
  if ~isactive
    activateSpline(src);
  end
 case 'alt',
  noedit;
  movespline(src);
end

function movespline(hs)
x = get(gca,'CurrentPoint');
x = [x(1,1); x(1,2)];
ud = get(hs,'UserData');
splx = get(hs,'XData');
sply = get(hs,'YData');
set(gcf,'WindowButtonMotionFcn', ...
        {@moveSplineMoveMouse,hs,x,ud,splx,sply},...
        'WindowButtonUpFcn', @knotSelectorButtonUp);

function moveSplineMoveMouse(src,event,hs,oldpos,oldud,oldsplx,oldsply)
x = get(gca,'CurrentPoint');
x = [x(1,1); x(1,2)];
dpos = x-oldpos;

ud = oldud;
ud.X = oldud.X + repmat(dpos,1, size(oldud.X, 2));
set(hs,'UserData', ud, ...
       'XData', oldsplx+dpos(1), ...
       'YData', oldsply+dpos(2));

% Sets up handlers for dragging a knot.
function knotselector(src,event,i)
hknots = findobj(gca,'Tag','knotcurve');
if isempty(hknots)
  warning('Got an event on a knot, but there is no control curve.');
  return
end
set(gcf,'WindowButtonMotionFcn', {@knotSelectorMoveMouse, i,src,hknots}, ...
		'WindowButtonUpFcn', @knotSelectorButtonUp);

% Drags a knot.
function knotSelectorMoveMouse(src,event,i,knot,hknotcurve)
x = get(gca,'CurrentPoint');
x = [x(1,1); x(1,2)];

set(knot,'XData', x(1), 'YData', x(2));
xk = get(hknotcurve,'XData');
xk(i) = x(1);
set(hknotcurve, 'XData', xk);
yk = get(hknotcurve,'YData');
yk(i) = x(2);
set(hknotcurve, 'YData', yk);
updatespline_X([xk; yk]);

% Stops dragging a knot.
function knotSelectorButtonUp(src,event)
set(gcf,'WindowButtonMotionFcn', [],...
		'WindowButtonUpFcn', []);

% --- Executes when user attempts to close Maingui.
function Maingui_CloseRequestFcn(hObject, eventdata, handles)
%{
rmappdata(handles.clean_plot,'Matrix')
rmappdata(handles.clean_plot,'dataea')
rmappdata(handles.clean_plot,'data')
rmappdata(handles.clean_plot,'datacb')
rmappdata(handles.clean_plot,'datasemi')
rmappdata(handles.clean_plot,'dataecc')
rmappdata(handles.clean_plot,'X')
rmappdata(handles.clean_plot,'Y')
rmappdata(handles.clean_plot,'increment')
rmappdata(handles.clean_plot,'xlength')
rmappdata(handles.clean_plot,'ylength')
h=gcf;
guidata(hObject,handles)
hgsave(h,'cleanasf_dialog.fig')
%}
delete(handles.Maingui);

function CloseConfiguration_Callback(hObject, eventdata, handles)
rmappdata(handles.clean_plot,'Matrix',Matrix)
rmappdata(handles.clean_plot,'dataea',dataea./Matrix)
rmappdata(handles.clean_plot,'datacb',datacb./Matrix)
rmappdata(handles.clean_plot,'datasemi',datasemi./Matrix)
rmappdata(handles.clean_plot,'dataecc',dataecc./Matrix)
rmappdata(handles.clean_plot,'X',X)
rmappdata(handles.clean_plot,'Y',Y)
rmappdata(handles.clean_plot,'increment',increment)
rmappdata(handles.clean_plot,'xlength',xlength)
rmappdata(handles.clean_plot,'ylength',ylength)
guidata(hObject, handles);
close all
clear all
clc
