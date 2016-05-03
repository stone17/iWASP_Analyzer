function varargout = wasp_o_matic(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wasp_o_matic_OpeningFcn, ...
                   'gui_OutputFcn',  @wasp_o_matic_OutputFcn, ...
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

% --- Executes just before wasp_o_matic is made visible.
function wasp_o_matic_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

%clc;
clear all;
global a_i linesub incx linehight cut loading
cut=[10, 100];
linehight=0;
incx=1;
a_i=[1,1];
linesub=1;
relsol=0;
ener=plot(0,0);
loading=0;


function varargout = wasp_o_matic_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function load_Callback(hObject, eventdata, handles)
global incx incy imlength xlength ylength pname fname simu zero back over spl spl_cal loading
axes(handles.main);
datacursormode off
button=num2str(get(hObject,'Tag'));
if strcmp(button,'load')
    if exist('lastpath.txt','file')
        fid = fopen('lastpath.txt','r');
        pname=(fread(fid,'*char'))';
        fclose(fid);
    else
        pname='c:\';
    end
    [Matrix_new,incx_new,incy_new,fname_new,pname_new]=loadasf(pname);
    if Matrix_new==0
        errordlg('No valid image file selected','Error');
        return
    else
        Matrix=Matrix_new;
        clear Matrix_new
        incx=incx_new;
        incy=incy_new;
        fname=fname_new;
        pname=pname_new;
        loading=1;
    end
    fid = fopen('lastpath.txt', 'wt');
    fprintf(fid, '%s', pname);
    fclose(fid);
    mx=5*abs(mean(mean(Matrix)))
    if mx>=1 && mx <65000
        set(handles.cmax,'string',num2str(round(mx)));
        set(handles.cmax,'value',round(mx));
        set(handles.cmax_text,'string',num2str(round(mx)),'foregroundcolor',[0 0 0]);
    elseif mx<1
        set(handles.caxismax1,'string',num2str(round((mx)*1000)/1000));
        set(handles.caxismax1,'value',round((mx)*1000)/1000);
        set(handles.cmax_text,'string',num2str(round((mx)*1000)/1000),'foregroundcolor',[0 0 0]);
    end
elseif strcmp(button,'saveim')
    if isappdata(handles.main,'M')==0
        errordlg('No image loaded','Error');
        return
    else
        Matrix=getappdata(handles.main,'M');
        if incx==incy
            inc=num2str(incx);
        else
            inc=[num2str(incx),'x',num2str(incy),'y'];
        end
        %filename=[pname,fname(1:length(fname)-5),'_ed_',inc,'_um.mat'];
        filename=[pname,fname(1:length(fname)-5),'_',inc,'_um.mat'];
        uisave('Matrix',filename)
        disp('Image saved')
    end
elseif strcmp(button,'merge')
    [Matrix,incx,incy]=asfmerger(pname);
    if Matrix==0
        errordlg('No image merged','Error');
        return
    end
    fname=['merged image_',num2str(incx),'_um pixelwidth'];
elseif strcmp(button,'cleanasf')
    if ischar(fname)
        type=fname(length(fname)-2:length(fname));
        if ~strcmp(type,'asf') && ~strcmp(type,'ASF')
            fname=0;
        end        
    end
    if exist('lastpath.txt','file')
        fid = fopen('lastpath.txt','r');
        pname=(fread(fid,'*char'))';
        fclose(fid);
    else
        pname='c:\';
    end
	h = cleanasf_dialog();
    return
elseif strcmp(button,'reload')
    if isempty(pname) || isappdata(handles.main,'M')==0
        errordlg('Nothing there to reload!','Error');
        return
    else
        rmappdata(handles.main,'M')
        [Matrix,incx,incy,fname,pname]=loadasf(pname,fname);
        %Matrix = medfilt2(Matrix,[5 5]);
        %Matrix = wiener2(Matrix,[7 7]);
    end
elseif strcmp(button,'filter')
    if isempty(pname) || isappdata(handles.main,'M')==0
        errordlg('Nothing there to filter!','Error');
        return
    else
        Matrix=getappdata(handles.main,'M');
        Matrix = medfilt2(Matrix,[5 5]);
        Matrix = wiener2(Matrix,[7 7]);
    end
elseif strcmp(button,'rotate')
    if isappdata(handles.main,'M')==0
        errordlg('No image loaded','Error');
        return
    else
        Matrix=rot90(getappdata(handles.main,'M'));
        incx_old=incx;
        incy_old=incy;
        incx=incy_old;
        incy=incx_old;
    end
elseif strcmp(button,'invert')
    if isappdata(handles.main,'M')==0
        errordlg('No image loaded','Error');
        return
    else
        Matrix=getappdata(handles.main,'M')';
        incx_old=incx;
        incy_old=incy;
        incx=incy_old;
        incy=incx_old;
    end
elseif strcmp(button,'invertmatrix')
    if isappdata(handles.main,'M')==0;
        errordlg('No image loaded','Error');
        return
    else
        Matrix=abs(2^16-getappdata(handles.main,'M'));
        Matrix=Matrix-min(min(Matrix));
    end
elseif strcmp(button,'resim')
     if isappdata(handles.main,'M')==0;
        errordlg('No image loaded','Error');
        return
    else
        Matrix=getappdata(handles.main,'M');
    end    
elseif strcmp(button,'cut')
    if isappdata(handles.main,'M')==0
        errordlg('No image loaded','Error');
        return
    else
        % Construct a questdlg 
        choice = questdlg('Please choose method:','Cutting method', ...
        'Rectangle','Spline','Cancel','Cancel');
        % Handle response
        switch choice
        case 'Rectangle'
            rect=round(getrect(handles.main)/incx*1e3);
            Matrix=getappdata(handles.main,'M');
            if rect(1,2)<1
                ymi=1;
            else
                ymi=rect(1,2);
            end
            if rect(1,2)+rect(1,4)>imlength(1,1)
                yma=imlength(1,1);
            else
                yma=rect(1,2)+rect(1,4);
            end
            if rect(1,1)<1
                xmi=1;
            else
                xmi=rect(1,1);
            end
            if rect(1,1)+rect(1,3)>imlength(1,2)
                xma=imlength(1,2);
            else
                xma=rect(1,1)+rect(1,3);
            end
            Matrix=Matrix(ymi:yma,xmi:xma);
            % correct zero offset
            xoff_old=get(handles.xoffset,'value');
            yoff_old=get(handles.yoffset,'value');
            xoff=xoff_old-xmi*incx*1e-3;
            yoff=yoff_old-ymi*incy*1e-3;
            x =strcat(num2str((round(xoff*100))/100),' mm');
            y =strcat(num2str((round(yoff*100))/100),' mm'); 
            set(handles.xoffset,'String',x)
            set(handles.xoffset,'value',xoff)
            set(handles.yoffset,'String',y)
            set(handles.yoffset,'value',yoff)
        case 'Spline'
            delete(spl(ishandle(spl)))
            xy = [];
            n = 0;
            % Loop, picking up the points.
            disp('Left mouse button picks points.')
            disp('Right mouse button picks last point.')
            but = 1;
            hold on
            while but == 1
                [xi,yi,but] = ginput(1);
                n = n+1;
                spl(n)=plot(xi,yi,'ro');
                xy(:,n) = [xi;yi];
            end
            % Interpolate with a spline curve and finer spacing.
            if n==1
                errordlg('Please set at least 2 points!','Error');
                return
            end
            t = 1:n;
            ts = 1: n/100 : n;
            xys = spline(t,xy,ts);
            % Plot the interpolated curve.
            spl(n+1)=plot(xys(1,:),xys(2,:),'g-','Linewidth',2);
            Matrix=getappdata(handles.main,'M');
            status = waitbar(0,'Please wait...');
            pause(.1)
            m=min(min(Matrix));
            for v=1:imlength(1,2)
                waitbar(v /imlength(1,2),status)
                pause(0.01)
                r=sqrt((xys(1,:)-v*incx*1e-3).^2)';
                [value,index]=min(r);
                for w=1:imlength(1,1)
                    if w*incy*1e-3>xys(2,index)
                        Matrix(w,v)=m;
                    end
                end
            end
            delete(status)
            hold off
        case 'Cancel'
            return
        end
    end
     mx=5*mean(mean(Matrix));
    if mx>=1 && mx <65000
        set(handles.cmax,'string',num2str(round(mx)));
        set(handles.cmax,'value',round(mx));
        set(handles.cmax_text,'string',num2str(round(mx)),'foregroundcolor',[0 0 0]);
    elseif mx<1
        set(handles.caxismax1,'string',num2str(round((mx)*1000)/1000));
        set(handles.caxismax1,'value',round((mx)*1000)/1000);
        set(handles.cmax_text,'string',num2str(round((mx)*1000)/1000),'foregroundcolor',[0 0 0]);
    end
elseif strcmp(button,'correct')
    fac=ip_scanning
    return
end
clear xi
clear Ei
clear yi

mean(mean(Matrix))
imlength=size(Matrix);
ylength=0:incy*1E-3:imlength(1,1)*incy*1E-3;
xlength=0:incx*1E-3:imlength(1,2)*incx*1E-3;
imagesc(xlength,ylength,Matrix);

hold on
simu=plot(0,0);
zero=plot(0,0);
back=plot(0,0);
over=plot(0,0);
spl=plot(0,0);
spl_cal=plot(0,0);
ener=plot(0,0);
hold off

axis xy
xlabel('B-field deflection (mm)')
ylabel('E-field deflection (mm)')
T=title(fname);
set(T,'Interpreter','none')
cmin=get(handles.cmin,'Value');
cmax=str2double(get(handles.cmax_text,'string'));
caxis([cmin cmax]);
if loading==1
    tptype_Callback(hObject, eventdata, handles);
end

%rot90 and invert may swap incx and incy, which will cause problems if they are not equal
set(handles.xpx_text,'string',[num2str(incx),' um']);
set(handles.ypx_text,'string',[num2str(incy),' um']);
width = round(get(handles.width, 'Value'));
set(handles.width_text,'string',[num2str(width), 'um / ',num2str(round(width/incx)),'pixel']);
spotsize=str2double(get(handles.spot,'string'));
set(handles.spotpx,'string',num2str(round(spotsize/incx)));
set(handles.hbin,'value',spotsize);
set(handles.hbin_text,'string',[num2str(spotsize), 'um / ',num2str(round(spotsize/incx)),'pixel']);
setappdata(handles.main,'M',Matrix)


function zeropoint_Callback(hObject, eventdata, handles)
global zero ylength xlength
datacursormode off
button=num2str(get(hObject,'Tag'));
if isappdata(handles.main,'M')==0
    errordlg('No image loaded','Error');
else
    if strcmp(button,'zeropoint')
        [xoff,yoff] = ginput(1);  
    elseif strcmp(button,'find0')
        options.Resize='on';
        options.WindowStyle='normal';
        options.Interpreter='tex';
        prompt = {'Enter Xoffset of marker:','Enter Yoffset of marker:'};
        dlg_title = 'Marker position:';
        num_lines = 1;
        if exist('lastmarker.mat','file') 
            load lastmarker.mat
        else
            markerx=0;
            markery=0;
        end
        def = {num2str(markerx),num2str(markery)};
        marker =inputdlg(prompt,dlg_title,num_lines,def,options);
        if isempty(marker)
            return
        end
        markerx = str2double(cell2mat(marker(1,1)));
        markery = str2double(cell2mat(marker(2,1)));
        save('lastmarker.mat','markerx','markery')
        [xoff_mark,yoff_mark] = ginput(1); 
        xoff=xoff_mark-markerx;
        yoff=yoff_mark-markery;
        else
        xoff=str2double(get(handles.xoffset,'string'));
        if isnan(xoff)
            xoff=get(handles.xoffset,'value');
        end
        yoff=str2double(get(handles.yoffset,'string'));
        if isnan(yoff)
            yoff=get(handles.yoffset,'value');
        end
    end
	x =num2str(round(xoff*100)/100);
	y =num2str(round(yoff*100)/100); 
	set(handles.xoffset,'String',x)
	set(handles.xoffset,'value',xoff)
	set(handles.yoffset,'String',y)
	set(handles.yoffset,'value',yoff)
    xoffset=double(xoff);
    yoffset=double(yoff);
    efield_Callback(hObject, eventdata, handles)
    %{
    hold on
    delete(zero(ishandle(zero)))
    x=1:max(xlength);
    y=1:max(ylength);
    alpha=get(handles.angle,'value')/360*2*pi;
	zero(1)=plot(handles.main,xoffset+0*y,y,'-k','Linewidth',2);
    zero(2)=plot(handles.main,x,sin(alpha)*x+yoffset-sin(alpha)*xoffset,'-k','Linewidth',2);
    hold off
    %}
end

function getenergy_Callback(hObject, eventdata, handles)
global incx simu a_i incy xlength
xoffset=get(handles.xoffset,'value');
yoffset=get(handles.yoffset,'value');
E=0;
B=get(handles.bfield, 'value');
lB=get(handles.bfieldlength, 'value')/1E3;
lE=lB;
D=get(handles.drift, 'value')/1E3;
alpha=get(handles.angle,'value');
spot=get(handles.width,'value')/1e3;

if isappdata(handles.main,'M')==0
    incx=100; %in microns
end

if length(a_i(:,1))>1
        list=['Proton';'C5+   ';'C6+   '];
        str=cellstr(list);
        [selection,ok]=listdlg('PromptString','Select an ion species:','SelectionMode','single','ListString',str);
        if ok==0
            selection=1;
        end
else
    selection=1;
end
alpha=alpha/360*2*pi;  
delete(simu(ishandle(simu)))
hold all

index=0;
for number=1:length(a_i(:,1)) %for multiple traces
	index=index+1;
	a=a_i(number,2);
	A=a_i(number,1);
    relsol=get(handles.relsol,'value');
    if relsol==0
        trace=tracer(E,lE,B,lB,D,a,A); %retrieve trace for current parameters
    else
        trace=tracer_rk(E,lE,B,lB,D,a,A); %retrieve trace for current parameters using relativistic solver
    end
    xtrace=trace(:,2);
    ytrace=trace(:,3);
    Energy=trace(:,1);
    
    nans=find(isnan(xtrace));

    if isempty(nans)==0
        xtrace=xtrace(length(nans)+1:length(xtrace));
        ytrace=ytrace(length(nans)+1:length(ytrace));
        Energy=Energy(length(nans)+1:length(Energy));
    end
    if xlength<max(xtrace)
        xi_max=floor(max(xlength));
    else
        xi_max=floor(max(xtrace));
    end
    %xi=round(min(xtrace)):incx*1E-3:xi_max;
    xi=xtrace;
    Ei = interp1(xtrace,Energy,xi);
    yi = interp1(xtrace,ytrace,xi);
    xi=xi+xoffset;
    yi=yi+yoffset;
    %rotate calculated trace
    beta=atan((yi-yoffset)./(xi-xoffset));
    z=sqrt((xi-xoffset).^2+(yi-yoffset).^2);
    xi=(cos(alpha+beta).*z)+xoffset;
    yi=(sin(alpha+beta).*z)+yoffset;
    simu(index*3-2)=plot(handles.main,xi,yi,'k','Linewidth',2);
    simu(index*3-1)=plot(handles.main,xi,yi+spot/2,'k','Linewidth',2);
    simu(index*3)=plot(handles.main,xi,yi-spot/2,'k','Linewidth',2);
    if selection==number
    	save ('data_','Ei','xi','xoffset','incx','incy')
    end        
end
hold off
dcm_obj = datacursormode(gcf);
set(dcm_obj,'UpdateFcn',@data)
datacursormode on

function efield_Callback(hObject, eventdata, handles)
global incx incy a_i simu check Ei xi yi over zero xlength ylength zerovals
set(hObject, 'Enable', 'off');
pause(0.1)
datacursormode off
slider=num2str(get(hObject,'Tag'));
xoffset=get(handles.xoffset,'value');
yoffset=get(handles.yoffset,'value');
if strcmp(slider,'bfield') || strcmp(slider,'bfield_text')
    if strcmp(slider,'bfield')
        Bfield = round(get(hObject, 'Value')*100)/100;
    else
        Bfield = round(str2double(get(hObject, 'string'))*100)/100;
        if isnan(Bfield)
            Bfield=0.55;
        elseif Bfield >double(get(handles.bfield,'Max'))
            Bfield=double(get(handles.bfield,'Max'));
        elseif Bfield <double(get(handles.bfield,'Min'))
            Bfield=double(get(handles.bfield,'Min'));
        end
    end
    set(handles.bfield_text,'Value',Bfield)
    set(handles.bfield_text,'String',num2str(Bfield))
    set(handles.bfield,'value',Bfield)
elseif strcmp(slider,'bfieldlength') || strcmp(slider,'bfieldlength_text')
    if strcmp(slider,'bfieldlength')
        bfieldlength = round(get(hObject, 'Value'));
    else
        bfieldlength = round(str2double(get(hObject, 'string')));
        if isnan(bfieldlength)
            bfieldlength=100;
        elseif bfieldlength >double(get(handles.bfieldlength,'Max'))
            bfieldlength=double(get(handles.bfieldlength,'Max'));
        elseif bfieldlength <double(get(handles.bfieldlength,'Min'))
            bfieldlength=double(get(handles.bfieldlength,'Min'));
        end
    end
    set(handles.bfieldlength_text,'Value',bfieldlength)
    set(handles.bfieldlength_text,'String',num2str(bfieldlength))
    set(handles.bfieldlength,'value',bfieldlength)
elseif strcmp(slider,'drift') || strcmp(slider,'drift_text')
    if strcmp(slider,'drift')
        drift = round(get(hObject, 'Value'));
    else
        drift = round(str2double(get(hObject, 'string')));
        if isnan(drift)
            drift=460;
        elseif drift >double(get(handles.drift,'Max'))
            drift=double(get(handles.drift,'Max'));
        elseif drift <double(get(handles.drift,'Min'))
            drift=double(get(handles.drift,'Min'));
        end
    end
    set(handles.drift_text,'Value',drift)
    set(handles.drift_text,'String',num2str(drift))
    set(handles.drift,'value',drift)
    ph_d = drift+round(get(handles.bfieldlength, 'Value')*10)/10+10;
    ph_detector =strcat(num2str(ph_d),' mm');
    set(handles.ph_detector_text,'String',ph_detector)
    set(handles.ph_detector,'value',ph_d)
elseif strcmp(slider,'angle') || strcmp(slider,'angle_text')
    if strcmp(slider,'angle')
        angle = round(get(hObject, 'Value')*100)/100;
    else
        angle = round(str2double(get(hObject, 'string'))*100)/100;
        if isnan(angle)
            angle=0;
        elseif angle >double(get(handles.angle,'Max'))
            angle=double(get(handles.angle,'Max'));
        elseif angle <double(get(handles.angle,'Min'))
            angle=double(get(handles.angle,'Min'));
        end
    end
    set(handles.angle_text,'Value',angle)
    set(handles.angle_text,'String',num2str(angle))
    set(handles.angle,'value',angle)
end

if check==1 % starts plotting
    E=0;
    B=get(handles.bfield, 'value');
    lB=get(handles.bfieldlength, 'value')/1E3;
    lE=lB;
    D=get(handles.drift, 'value')/1E3;
    alpha=get(handles.angle,'value');
    spot=get(handles.width,'value')/1e3;
    alpha=alpha/360*2*pi;

    delete(simu(ishandle(simu)))
    if ishandle(over)
        delete(over)
        hold on
        over=plot(0,0);
        hold off
    end
    
    hold all
    if isappdata(handles.main,'M')==0;
        incx=25; %in microns
    end 
    
    index=0;
    for number=1:length(a_i(:,1)) %for multiple traces
        index=index+1;
        a=a_i(number,2);
        A=a_i(number,1);
        relsol=get(handles.relsol,'value');
        if relsol==0
            trace=tracer(E,lE,B,lB,D,a,A); %retrieve trace for current parameters
        else
            trace=tracer_rk(E,lE,B,lB,D,a,A); %retrieve trace for current parameters using relativistic solver
        end
        xtrace=trace(:,2);
        ytrace=trace(:,3);
        Energy=trace(:,1);
   
        nans=find(isnan(xtrace)); %remove nan-entries
        if isempty(nans)==0
            xtrace=xtrace(length(nans)+1:length(xtrace));
            ytrace=ytrace(length(nans)+1:length(ytrace));
            Energy=Energy(length(nans)+1:length(Energy));
        end

        xi=round(min(xtrace)):incx*1E-3:round(max(xtrace)); %convert to figure dimensions
        Ei = interp1(xtrace,Energy,xi);
        yi = interp1(xtrace,ytrace,xi);
        xi=xi+xoffset;
        yi=yi+yoffset;
        beta=atan((yi-yoffset)./(xi-xoffset)); %rotate calculated trace
        z=sqrt((xi-xoffset).^2+(yi-yoffset).^2);
        xi=(cos(alpha+beta).*z)+xoffset;
        yi=(sin(alpha+beta).*z)+yoffset;
        simu(index*3-2)=plot(handles.main,xi,yi,'k','Linewidth',2); %plot main trace
        simu(index*3-1)=plot(handles.main,xi,yi+spot/2,'k','Linewidth',2); %plot upper trace
        simu(index*3)=plot(handles.main,xi,yi-spot/2,'k','Linewidth',2); %plot lower trace

        delete(zero(ishandle(zero)))
        lims=axis;
        x=xoffset-3:1:lims(1,2)*0.99; %plot origin
        zero(1)=plot(x,tan(alpha)*x+yoffset-tan(alpha)*xoffset,'-k','Linewidth',2);
        dy_u=2.5*lims(1,4)-yoffset;
        dy_b=yoffset-2.05*lims(1,3);
        ylimit_u=300*tan(alpha)*dy_u;
        ylimit_b=300*tan(alpha)*dy_b;
        if alpha>0
            y=xoffset-ylimit_u:(ylimit_b+ylimit_u)/100:1.5*xoffset+ylimit_b;
        elseif alpha<0
            y=xoffset+ylimit_u:(ylimit_b+ylimit_u)/-100:2.5*xoffset-ylimit_b;
        else
            y=xoffset;
        end
        zero(2)=plot(y,-tan(0.5*pi-alpha)*y+yoffset+tan(0.5*pi-alpha)*xoffset,'-k','Linewidth',2);
        %clear zerovals
        zerovals=[];
        zerovals(:,1)=y;
        zerovals(:,2)=-tan(0.5*pi-alpha)*y+yoffset+tan(0.5*pi-alpha)*xoffset;
        zero(3)=plot(xoffset,yoffset,'o','Linewidth',3);
        %90° only visible if axis equal!
        if length(a_i(:,1))==1
            [value,index10]=min(sqrt((Ei-10e6).^2));
            if a_i(1,1)==1
                [value,index25]=min(sqrt((Ei-25e6).^2));
            end
            [value,index50]=min(sqrt((Ei-50e6).^2));
            [value,index100]=min(sqrt((Ei-100e6).^2));
            [value,index150]=min(sqrt((Ei-150e6).^2));
            [value,index200]=min(sqrt((Ei-200e6).^2));
            if a_i(1,1)>1
                [value,index250]=min(sqrt((Ei-250e6).^2));
                [value,index500]=min(sqrt((Ei-500e6).^2));
                [value,index1000]=min(sqrt((Ei-1000e6).^2));
            end
            ind=3+1;
            zero(ind)=text(xi(index10),yoffset-.5,'10','color','w','fontsize',18);
            ind=ind+1;
            zero(ind)=plot(xi(index10),yoffset,'o','linewidth',3,'color','w');
            if a_i(1,1)==1
                ind=ind+1;
                zero(ind)=text(xi(index25),yoffset-.5,'25','color','w','fontsize',18);
                ind=ind+1;
                zero(ind)=plot(xi(index25),yoffset,'o','linewidth',3,'color','w');
            end
            ind=ind+1;
            zero(ind)=text(xi(index50),yoffset-.5,'50','color','w','fontsize',18);
            ind=ind+1;
            zero(ind)=plot(xi(index50),yoffset,'o','linewidth',3,'color','w');
            ind=ind+1;
            zero(ind)=text(xi(index100),yoffset-.5,'100','color','w','fontsize',18);
            ind=ind+1;
            zero(ind)=plot(xi(index100),yoffset,'o','linewidth',3,'color','w');
            ind=ind+1;
            zero(ind)=text(xi(index150),yoffset-.5,'150','color','w','fontsize',18);
            ind=ind+1;
            zero(ind)=plot(xi(index150),yoffset,'o','linewidth',3,'color','w');
            ind=ind+1;
            zero(ind)=text(xi(index200),yoffset-.5,'200','color','w','fontsize',18);
            ind=ind+1;
            zero(ind)=plot(xi(index200),yoffset,'o','linewidth',3,'color','w');
            if a_i(1,1)>1
                zero(ind+1)=text(xi(index250),yoffset-.5,'250','color','w','fontsize',18);
                zero(ind+2)=plot(xi(index250),yoffset,'o','linewidth',3,'color','w');
                zero(ind+3)=text(xi(index500),yoffset-.5,'500','color','w','fontsize',18);
                zero(ind+4)=plot(xi(index500),yoffset,'o','linewidth',3,'color','w');
                zero(ind+5)=text(xi(index1000),yoffset-.5,'1e3','color','w','fontsize',18);
                zero(ind+6)=plot(xi(index1000),yoffset,'o','linewidth',3,'color','w');
            end
        end
    end
end
hold off

set(hObject, 'Enable', 'on');

function efield_CreateFcn(hObject, eventdata, handles)

function ph_detector_Callback(hObject, eventdata, handles)
global incx
set(hObject, 'Enable', 'off'); 
pause(0.001)
slider=num2str(get(hObject,'Tag'));
if strcmp(slider,'ph_detector')
    ph_d = round(get(hObject, 'Value'));
    ph_detector =strcat(num2str(ph_d),' mm');
    set(handles.ph_detector_text,'String',ph_detector)
    set(handles.ph_detector,'value',ph_d)
elseif strcmp(slider,'phdiameter')
    diam = round(get(hObject, 'Value'));
    diameter =strcat(num2str(diam),' um');
    set(handles.phdiameter_text,'String',diameter)
    set(handles.phdiameter,'value',diam)
elseif strcmp(slider,'targetPH')
    t_ph = round(get(hObject, 'Value'));
    target_ph =strcat(num2str(t_ph),' mm');
    set(handles.targetph_text,'String',target_ph)
    set(handles.targetPH,'value',t_ph)
end

ph_d = round(get(handles.ph_detector, 'Value'));
diam=get(handles.phdiameter,'value');
t_ph=get(handles.targetPH,'value');

spotsize=round((ph_d+t_ph)/t_ph*diam); %spotsize in um
set(handles.spot,'string',spotsize);
set(handles.width,'value',spotsize);
spot =strcat(num2str(spotsize));
set(handles.width_text,'string',[spot,'um /',num2str(round(spotsize/incx)),'pixel']);
bin=round(spotsize/(incx));
set(handles.spotpx,'string',num2str(bin));
msr=(diam*1e-3/2)^2*pi/t_ph^2*1E3; %steradians in msr
set(handles.solid_angle,'string',[num2str(msr, '%10.2e\n'),' msr']);
set(handles.hbin,'value',spotsize);
set(handles.hbin_text,'string',[num2str(spotsize), 'um / ',num2str(round(spotsize/incx)),'pixel']);
set(hObject, 'Enable', 'on'); 

function ph_detector_CreateFcn(hObject, eventdata, handles)

function width_Callback(hObject, eventdata, handles)
global incx
width = round(get(hObject, 'Value'));
linewidth=strcat(num2str(width));
angle=atan(width/1e3/(get(handles.targetPH,'value')+get(handles.ph_detector,'value')))/pi*180;
set(handles.width,'value',width);
set(handles.width_text,'string',[num2str(linewidth), 'um / ',num2str(round(width/incx)),'pixel / ~',num2str(round(angle*100)/100),'°']);
function width_CreateFcn(hObject, eventdata, handles)

function hbin_Callback(hObject, eventdata, handles)
global incx
hbin=round(get(hObject,'value'));
set(handles.hbin,'value',hbin);
set(handles.hbin_text,'string',[num2str(hbin), 'um / ',num2str(round(hbin/incx)),'pixel']);

function hbin_CreateFcn(hObject, eventdata, handles)

function ion_Callback(hObject, eventdata, handles)
str = get(hObject, 'String');
val = get(hObject,'Value');
datacursormode off
global a_i %[ion mass in mp, ion charge in e-]
switch str{val};
    case 'Proton + C6C5'
         a_i=[1,1;12,5;12,6];
        set(handles.charge,'Value',1)
        set(handles.charge,'String','mixed');
        set(handles.charge, 'Enable', 'off');
    case 'Proton + C6C5C4'
        a_i=[1,1;12,4;12,5;12,6];
        %a_i=[1,1;12,1;12,2;12,3;12,4;12,5;12,6];
        set(handles.charge,'Value',1)
        set(handles.charge,'String','mixed');
        set(handles.charge, 'Enable', 'off');
    otherwise
        p=load('periodic.mat','-mat','periodic');
        ion=val-2; %mass number
        mass=p.periodic(ion,2);
        charge=p.periodic(ion,1);
        a_i=[mass,charge];
        for cs=1:charge
            chargestates{cs}=[num2str(cs),'+'];
        end
        set(handles.charge,'Value',charge)
        set(handles.charge,'String',chargestates);
        set(handles.charge, 'Enable', 'on');
end
efield_Callback(hObject,eventdata, handles)


function ion_CreateFcn(hObject, eventdata, handles)

% --- Executes on selection change in charge.
function charge_Callback(hObject, eventdata, handles)
str = get(hObject, 'String');
val = get(hObject,'Value');
datacursormode off
global a_i
a_i(1,2)=val;
efield_Callback(hObject,eventdata, handles)

function charge_CreateFcn(hObject, eventdata, handles)

% --- Executes on selection change in isotope.
function isotope_Callback(hObject, eventdata, handles)
% hObject    handle to isotope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns isotope contents as cell array
%        contents{get(hObject,'Value')} returns selected item from isotope

function isotope_CreateFcn(hObject, eventdata, handles)


function spectr_Callback(hObject, eventdata, handles)
global imlength incx incy a_i Ei xi yi pname fname spectrum checktr linesub linehight yupper ylower zerovals
set(hObject, 'Enable', 'off');
set(handles.Maingui,'Pointer','watch')
pause(0.1)
A=a_i(1,1);
a=a_i(1,2);
cut(1)=str2double(get(handles.cut_low,'string'));
cut(2)=str2double(get(handles.cut_high,'string'));
xoffset=get(handles.xoffset,'value');
yoffset=get(handles.yoffset,'value');
spot=str2double(get(handles.spot,'string'))*1E-3; %x-binning in mm
width_mm=double(get(handles.width,'value'))*1E-3;    %linewitdh in mm
bin=round(get(handles.hbin,'value')/incx);
diam=get(handles.phdiameter,'value')*1E-6;
t_ph=get(handles.targetPH,'value')*1E-3;
cmin=get(handles.cmin,'Value');
cmax=get(handles.cmax,'value');

if get(handles.cr39,'value')==1
    load('cr_calibration.txt','-ascii');
    disp('Using CR39 Calibration file')
    pause(.001)
end

if isappdata(handles.main,'M')==0
    errordlg('Load image first','Error');    
    set(hObject, 'Enable', 'on');
    set(handles.Maingui,'Pointer','arrow')
    return
elseif isempty(xi)==1
    errordlg('Find appropriate iWasp values first','Error');    
    set(hObject, 'Enable', 'on');
    set(handles.Maingui,'Pointer','arrow')
    return
end

Matrix=getappdata(handles.main,'M');

if linesub==1
    raw=Matrix;
    Matrix(Matrix<=linehight)=0;
    Matrix=Matrix-linehight;
    Matrix(Matrix<0)=0;
end

%Convert spot size to pixel
if bin <2;
	bin=2;
end
%Convert line width to pixel
width=round(width_mm/(incy*1E-3));
if width<2
	width=2;
end

if isempty(ylower) || isempty(yupper)
    ylowerspec=2;
    yupperspec=imlength(1)-2;
    ylower=ylowerspec*incy*1E-3;
    yupper=yupperspec*incy*1E-3;
else
    ylowerspec=round(ylower/(incy*1E-3));
    yupperspec=round(yupper/(incy*1E-3));
end
global yzerovals xzerovals
yzerovals=ylower:0.025/2:yupper;
xzerovals=interp1(zerovals(:,2),zerovals(:,1),yzerovals);

%xspec=xspec+round((xoffset/(incx*1e-3)));
stepnum=0;

specmap=[];
angle=[];
Energyvec=[];
spectrum=[];
spec=[];
conversion=[];
l=length(ylowerspec:width:yupperspec);

if get(handles.calibrationlist,'value')<2
     % Construct a questdlg 
    choice = questdlg('Use calibration file?','B-Field Model', ...
            'Yes','No','No');
    % Handle response
else
    load calibrationlist
    calibrationfile=cell2mat(calibrationlist(get(handles.calibrationlist,'value')-2));
    % Construct a questdlg 
    choice = questdlg(['Use calibration ', calibrationfile,'?'],'B-Field Model', ...
            'Yes','Other','No','No');
    % Handle response
end
switch choice
	case 'Yes'
        calibration=1;
        if get(handles.calibrationlist,'value')<2     
            [filename,pathname]=uigetfile('iWASP_*.txt','Select calibration file');
            file=[pathname,filename];
        else
            file=calibrationfile;
        end
        try
            calibration_table=load(file,'-ascii');
        catch exception
            exception
            disp('No calibration file loaded. Aborting.')
            set(hObject, 'Enable', 'on');
            set(handles.Maingui,'Pointer','arrow')
            return
        end
        
    	case 'Other'
        calibration=1;
        [filename,pathname]=uigetfile('iWASP_*.txt','Select calibration file');
        file=[pathname,filename];
        try
            calibration_table=load(file,'-ascii');
        catch exception
            exception
            disp('No calibration file loaded. Aborting.')
            set(hObject, 'Enable', 'on');
            set(handles.Maingui,'Pointer','arrow')
            return
        end
        
    case 'No'
        calibration=0;
        
    case ''
        set(hObject, 'Enable', 'on');
        set(handles.Maingui,'Pointer','arrow')
        disp('No calibration file loaded. Aborting.')
        return
end
calibration_index=0;
hw = waitbar(0,'Please wait...');
pause(0.001)
get(handles.ip,'value')
if (A==1 || round(A)==2) && get(handles.ip,'value')==1
    load in_out
end

for steps=ylowerspec:width:yupperspec; 
        
    if calibration_index==0
        if calibration==0 %turns of calculation of trace if not using a calibration file
            calibration_index=1;
            B=get(handles.bfield, 'value');
        else
            x_current=steps*incy/1e3-yoffset;
            lms=sqrt((calibration_table(:,1)-x_current).^2);
            B=calibration_table(find(lms==min(lms)),2)*1e-3;
            B=sum(B)/length(B);
        end
        E=0;
        lB=get(handles.bfieldlength, 'value')/1E3;
        lE=lB;
        D=get(handles.drift, 'value')/1E3;
        alpha=get(handles.angle,'value');
        %spot=get(handles.width,'value')/1e3;
        alpha=alpha/360*2*pi;
        a=a_i(1,2);
        A=a_i(1,1);
        relsol=get(handles.relsol,'value');
        clear trace
        if relsol==0
            trace=tracer(E,lE,B,lB,D,a,A); %retrieve trace for current parameters
        else
            trace=tracer_rk(E,lE,B,lB,D,a,A); %retrieve trace for current parameters using relativistic solver
        end
        xtrace=trace(:,2);
        ytrace=trace(:,3);
        Energy=trace(:,1);   
        nans=find(isnan(xtrace)); %remove nan-entries
        if isempty(nans)==0
            xtrace=xtrace(length(nans)+1:length(xtrace));
            ytrace=ytrace(length(nans)+1:length(ytrace));
            Energy=Energy(length(nans)+1:length(Energy));
        end
        xi=round(min(xtrace)):incx*1E-3:round(max(xtrace)); %convert to figure dimensions
        Ei = interp1(xtrace,Energy,xi);
        yi = interp1(xtrace,ytrace,xi);
        xi=xi+xoffset;
        yi=yi+yoffset;
        beta=atan((yi-yoffset)./(xi-xoffset)); %rotate calculated trace
        z=sqrt((xi-xoffset).^2+(yi-yoffset).^2);
        xi=(cos(alpha+beta).*z)+xoffset;
        yi=(sin(alpha+beta).*z)+yoffset;

        %get number of NAN entries
        nansx=find(isnan(xi));   
        nansy=find(isnan(yi));
        nansE=find(isnan(Ei));
        nans(1,1)=length(nansx);
        nans(1,2)=length(nansy);
        nans(1,3)=length(nansE);
        nan=max(nans);
        %remove NAN entries
        xtrace=xi((nan)+1:length(xi));
        ytrace=yi((nan)+1:length(yi));
        Energy=Ei((nan)+1:length(Ei));
        %cut simulated spectrum
        Diff=sqrt((Energy-cut(2)*1.10e6).^2);
        [value,index1]=min(Diff);
        Diff=sqrt((Energy-cut(1)*0.9e6).^2);
        [value,index2]=min(Diff);       
        if index1>2
            index1=index1-1;
        end
        xtrace=xtrace(index1:index2);
        ytrace=ytrace(index1:index2);
        Energy=Energy(index1:index2);
        xspec=round((xtrace-xoffset)/(incx*1E-3));
        yspec=round((ytrace-yoffset)/(incy*1E-3));
        if stepnum==0
            xspec0=xspec;
            yspec0=yspec;
        end
    end
    %length(Energy);
    %E_min=sqrt((Energy-1.09*1e6).^2);
    %indaa=find(E_min==min(E_min));
    %xtrace(indaa);
    
    stepnum=stepnum+1;
    waitbar(round(stepnum/l*100)/100,hw,sprintf('%s',[num2str(round(stepnum/l*1000)/10),'% (',num2str(stepnum),' of ',num2str(l),' lineouts)']));
    pause(0.001)
    
    ydiff=sqrt((yzerovals-steps*(incy*1e-3)).^2);
    [value,index0]=min(ydiff);
    xspec=xspec0+round(xzerovals(index0(1))/(incx*1e-3));
    yspec=yspec0+steps;
    %calulate limit of binning
    xlimimage=imlength(1,2); %limit of image in x-dimension
    xlimplot=max(xspec);  %x-limit of simulated plot

    ylimimage=imlength(1,1); %limit of image in y-dimension
    ylimplot=max(yspec); %y-limit of simulated plot

    if xlimimage<xlimplot %x image is shorter than x-plot
        if ylimimage<ylimplot
            lim=xlimimage;
        end
        lim=xlimimage;
    else
        lim=xlimplot;
    end

    if checktr==1
        figure(1);
        imagesc(Matrix)
        caxis([cmin cmax])
        axis xy
    end

    indey=0;
    index=0;
    total=0;
    for a=xspec(1,1):bin:lim-bin
    index=index+1;
    value=0;
    bgvalue=0;
    rawvalue=0;
    for b=a:1:a+bin-1;
        count=0;
        indey=indey+1;
        if indey<=length(yspec) 
        for c=yspec(1,indey)-round(width/2):1:yspec(1,indey)-round(width/2)+width-1
            if c>0 && c<imlength(1,1)
                if checktr==1
                    hold on
                    plot (b,c,'o','color','g')
                    pause(0.0001)
                    hold off
                end
                count=count+1;
                value=value+(Matrix(c,b));
                total=total+(Matrix(c,b));
                %bg=mean(mean(Matrix(steps-bin:steps+bin,round(xzerovals(index0(1))/(incx*1e-3)+5*bin):round(xzerovals(index0(1))/(incx*1e-3)+10*bin))));
                if linesub==1
                    rawvalue=rawvalue+raw(c,b);
                    bgvalue=bgvalue+linehight;
                
                end
            end
        end
        end
    end
    if checktr==1
        hold on
        plot (b,c,'o','color','r')
        pause(0.0001)
        hold off
    end
    if indey+bin<=length(Energy) && indey-round(bin/2)>0        
        MEV=(Energy(indey)-Energy(indey+bin))/1E6;  %add 1 to have correct energy window! now its invariant to changes of binning size.
        E_center=(Energy(indey)+Energy(indey+bin))/2/1e6;
        if ~isnan(MEV)
            spectrum(index,1)=Energy(indey)/1E6-MEV/2; %Energy in MeV
        if get(handles.cr39,'value')==1 %use energy dependent intensity calibration
            %load('icali')
            %calib_index=find(sqrt((cr_calibration(:,1)-MEV).^2)==min(sqrt(
            %(cr_calibration(:,1)-250).^2)));
            if E_center<28
                value=value*cr_calibration(1,2); 
            elseif E_center>650
                value=value*cr_calibration(650,2); 
            else
                value=value*cr_calibration(round(E_center)-27,2);
            end
        end
            spectrum(index,2)=value/MEV; %counts per MeV
            spectrum(index,3)=value; %counts per bin
            spectrum(index,4)=MEV;   %delta E of bin
            spectrum(index,5)=1/MEV;
            if (A==1 || round(A)==2) && get(handles.ip,'value')==1 %IP calibration for protons
                %global in_out E_center
                realE0=in_out(round(E_center*1000));
                if realE0<=2.11
                    V1=value/(0.22039*exp(-(realE0-1.5049).^2/1.1842^2)); % calibrated counts #1
                    cal1=(0.22039*exp(-(realE0-1.5049).^2/1.1842^2));
                    V2=value/(0.14718*exp(-(realE0-1.3492).^2/1.4613^2)); % calibrated counts #2
                    cal2=(0.14718*exp(-(realE0-1.3492).^2/1.4613^2));
                else
                    V1=value/(0.33357*realE0.^(-0.91377)); % calibrated counts #1
                    cal1=(0.33357*realE0.^(-0.91377));
                    V2=value/(0.16217*realE0.^(-0.38893)); % calibrated counts #2
                    cal2=(0.16217*realE0.^(-0.38893));
                end
                spectrum(index,6)=V1/MEV; %calibrated counts per MeV
                spectrum(index,7)=V1; %calibrated counts per bin
                spectrum(index,8)=V2/MEV; %calibrated counts per MeV
                spectrum(index,9)=V2; %calibrated counts per bin
            end
            if linesub==1 %background consideration
                if (A==1 || round(A)==2) && get(handles.ip,'value')==1
                else
                    cal1=1;
                    cal2=1;
                end
                bg_spectrum(index,1)=Energy(indey)/1E6-MEV/2; %Energy in MeV
                bg_spectrum(index,2)=1/MEV; %threshold counts per MeV
                bg_spectrum(index,3)=MEV;   %delta E of bin
                if (A==1 || round(A)==2) && get(handles.ip,'value')==1
                    bg_spectrum(index,4)=bgvalue/cal1/MEV; %counts per MeV calibration #1
                    bg_spectrum(index,5)=bgvalue/cal1; %counts per bin
                    bg_spectrum(index,6)=bgvalue/cal2/MEV; %counts per MeV calibration #2
                    bg_spectrum(index,7)=bgvalue/cal2; %counts per bin
                    bg_spectrum(index,8)=rawvalue/cal1/MEV; %counts per MeV raw data & calibration #1
                    bg_spectrum(index,9)=bgvalue/cal1; %counts per bin
                    bg_spectrum(index,10)=rawvalue/cal1/MEV; %counts per MeV raw data & calibration #2
                    bg_spectrum(index,11)=bgvalue/cal1; %counts per bin
                end
            end
        end
    end
    end
                %hold(handles.main,'on')
                %plot(handles.main,round(xzerovals(index0(1))+7.5*bin*(incx*1e-3)),steps*(incx*1e-3),'x','linewidth',4,'color','g')
                %pause(0.1)
                %hold(handles.main,'off')

    %msr_=(diam/2)^2*pi/t_ph^2*1E3; %steradians in msr
    msr=(width_mm/spot*diam*diam)/t_ph^2*1E3;
    %msr_old=msr_*4/pi; %slit is not round, so area is 4/pi larger
    if (A==1 || round(A)==2) && get(handles.ip,'value')==1 %IP calibration for protons
        spectrum(:,6)=spectrum(:,6)./msr;
        spectrum(:,8)=spectrum(:,8)./msr;
    else
        spectrum(:,2)=spectrum(:,2)./msr;
    end
    if stepnum==1
        %global Energyvec in_out
        %E_specmap=[20:cut(2)]';
        E_specmap=spectrum(:,1);
        global error
        clear error
        error(:,1)=spectrum(:,1);
        error(:,2)=0;
        error(:,3)=0;
        Energyvec=E_specmap;
        if (A==1 || round(A)==2) && get(handles.ip,'value')==1
            for a=1:length(Energyvec)
                realE(a,1)=in_out(round(Energyvec(a)*1000));
            end
        end
    end
    if (A==1 || round(A)==2) && get(handles.ip,'value')==1
        spec_i = interp1(spectrum(:,1),spectrum(:,6),E_specmap);
        specmap(stepnum,:,1)=spec_i;
        error(:,2)=error(:,2)+ interp1(spectrum(:,1),spectrum(:,7),E_specmap);   
        spec_i = interp1(spectrum(:,1),spectrum(:,8),E_specmap);
        specmap(stepnum,:,3)=spec_i;
        error(:,3)=error(:,3)+ interp1(spectrum(:,1),spectrum(:,9),E_specmap);
        spec_i = interp1(spectrum(:,1),spectrum(:,7),E_specmap);
        specmap(stepnum,:,2)=spec_i;
        spec_i = interp1(spectrum(:,1),spectrum(:,9),E_specmap);
        specmap(stepnum,:,4)=spec_i;
    else
        spec_i = interp1(spectrum(:,1),spectrum(:,2),E_specmap);
        specmap(stepnum,:,1)=spec_i;
        error(:,2)=error(:,2)+ interp1(spectrum(:,1),spectrum(:,3),E_specmap);
        spec_i = interp1(spectrum(:,1),spectrum(:,3),E_specmap);
        specmap(stepnum,:,2)=spec_i;
    end
    range=(steps+width/2)*incy/1e3-yoffset; 
    angle(stepnum,1)=atan(range/(get(handles.ph_detector,'value')+t_ph*1e3))/2/pi*360; %angle [rad]
    angle(stepnum,2)=tan(angle(stepnum,1)/180*pi)*t_ph*1e3; %radius in polar coordinates [mm]
    angle(stepnum,3)=t_ph*1e3*width*incy/1e3/(t_ph*1e3+get(handles.ph_detector,'value'))*diam*1e3; %area of slit element [mm]
    angle(stepnum,4)=pi*angle(stepnum,2)^2-pi*(abs(angle(stepnum,2))-t_ph*1e3*width*incy/1e3/(t_ph*1e3+get(handles.ph_detector,'value')))^2; %area of radial disc [mm^2]
    angle(stepnum,5)=angle(stepnum,3)/angle(stepnum,4); %fraction of radial disc
    angle(stepnum,6)=t_ph*1e3*width*incy/1e3/(t_ph*1e3+get(handles.ph_detector,'value')); %slit element length in [mm]
    angle(stepnum,7)=diam*1e3; %slit hight in [mm]
    
    if linesub==1 %background consideration
        bg_spectrum(:,2)=bg_spectrum(:,2)./msr; %detection threshold
        bg_spec_i = interp1(bg_spectrum(:,1),bg_spectrum(:,2),E_specmap);
        bg_specmap(stepnum,:,1)=bg_spec_i;
        if (A==1 || round(A)==2) && get(handles.ip,'value')==1
            bg_spec_i_bg = interp1(bg_spectrum(:,1),bg_spectrum(:,4),E_specmap); %calibration #1
            bg_specmap(stepnum,:,2)=bg_spec_i_bg;
            bg_spec_i_raw = interp1(bg_spectrum(:,1),bg_spectrum(:,8),E_specmap); %calibration #1 of raw data
            bg_specmap(stepnum,:,3)=bg_spec_i_raw;
        end
    end
    
    [value,index]=max(specmap(stepnum,:,1));
    line(stepnum,1)=steps*0.025;
    line(stepnum,2)=Energyvec(index);
    spectrum(spectrum(:,2)<get(handles.CE_cutoff,'value'),3)=0;
    range=yupper-ylower;
    conversion(stepnum,1)=sum(spectrum(:,3).*spectrum(:,1)*1e6*1.60217648740e-19); %energy
   	conversion(stepnum,2)=sum(spectrum(:,3)); %counts
    conversion(stepnum,3)=0;
    conversion(stepnum,4)=0;
    conversion(stepnum,5)=0;
    conversion(stepnum,6)=0;
    if (A==1 || round(A)==2) && get(handles.ip,'value')==1 %apply IP calibration for protons
        if length(Energyvec)<length(spectrum(:,3))
            limit1=length(Energyvec);
        else
            limit1=length(spectrum(:,3));
        end
        for a=1:limit1
            if realE(a)<=2.11
                p1=spectrum(a,3)./(0.22039*exp(-(realE(a)-1.5049).^2/1.1842^2)); % calibrated counts #1
                p2=spectrum(a,3)./(0.14718*exp(-(realE(a)-1.3492).^2/1.4613^2)); % calibrated counts #2
            else
                p1=spectrum(a,3)./(0.33357*realE(a).^(-0.91377)); % calibrated counts #1
                p2=spectrum(a,3)./(0.16217*realE(a).^(-0.38893)); % calibrated counts #2
            end
            conversion(stepnum,4)=conversion(stepnum,4)+p1;
            conversion(stepnum,3)=conversion(stepnum,3)+p1.*spectrum(a,1)*1e6*1.60217648740e-19; % calibrated energy #1
            conversion(stepnum,6)=conversion(stepnum,6)+p2;
            conversion(stepnum,5)=conversion(stepnum,5)+p2.*spectrum(a,1)*1e6*1.60217648740e-19; % calibrated energy #2
        end
    end
    clear spec spectrum
end
if A==1
    clear in_out
end
%fullangle=atan(range/2/(get(handles.ph_detector,'value')+t_ph*1e3))/2/pi*360*2;
%ylow_zeroangle=atan((yoffset-ylower)/2/(get(handles.ph_detector,'value')+t_ph*1e3))/2/pi*360*2;
%angle_old=(1:stepnum)/stepnum*fullangle-ylow_zeroangle;
try
delete(hw)
end
%calulate CE
screen=yupper-ylower; %length of detector containing data [mm]
slitlength=screen*t_ph*1e3/(get(handles.ph_detector,'value')+t_ph*1e3); %real slit length [mm]
%openangle=atan(slitlength/(2*t_ph*1e3))*360/2/pi*2; %acceptance angle of iWasp [mm]
%solidangle=2*pi*t_ph*1e3*openangle/360*diam*1e3/(t_ph*1e3)^2*1e3; %solid angle of slit [msr]
%length(angle)*msr %solid angle from readout (number of spectra times msr)
if angle(1)<0
    openangle=angle(end,1)+abs(angle(1,1)); %acceptance angle of iWasp [mm]
else
    openangle=angle(end,1)-angle(1,1); %acceptance angle of iWasp [mm]
end
solidangle=2*pi*t_ph*1e3*openangle/360*diam*1e3/(t_ph*1e3)^2*1e3; %solid angle of slit [msr]
solidangle_rotated=4*pi*sin(2*openangle*2*pi/360/4)^2*1e3 %solid angle if slit is rotated by 360° [msr]
CE=sum(conversion(:,1))*solidangle_rotated/solidangle/80*100
CE_polar=sum(conversion(:,1)./abs(angle(:,5)))/80*100
particles=sum(conversion(:,2));
particles_total=sum(conversion(:,2))*solidangle_rotated/solidangle;
ph_detector=get(handles.ph_detector,'value'); %[mm]
try
save('lastspectrum','specmap','error','Energyvec','angle','A','cut','conversion','msr','t_ph','ph_detector','screen','slitlength','openangle','solidangle','diam','bg_specmap','fname','pname')
catch
save('lastspectrum','specmap','error','Energyvec','angle','A','cut','conversion','msr','t_ph','ph_detector','screen','slitlength','openangle','solidangle','diam','fname','pname')
end
setappdata(0,'fromgui',1)
wasp_plotter
setappdata(0,'fromgui',0)
%wasp_plot(pname,fname,specmap,Energyvec,angle,A,cut,conversion,error,msr,diam,t_ph,bg_specmap);


clear specmap angle Energyvec
set(hObject, 'Enable', 'on');
set(handles.Maingui,'Pointer','arrow')
%figure
%plot (line(:,1),line(:,2))
Message(1,1)={'Particles iWASP/Full:'};
Message(2,1)={[num2str(particles,'%10.2e'),' / ',num2str(particles_total,'%10.2e')]};
Message(1,2)={'CE:'};
Message(2,2)={[num2str(CE,'%2.2f'),'%']};                                                                                       
Message(1,3)={'Angle:'};
Message(2,3)={[num2str(openangle,'%2.2f'),'°']};
Message(1,4)={'Solid angle iWASP/Full:'};
Message(2,4)={[num2str(solidangle,'%2.2f'),' / ', num2str(solidangle_rotated,'%2.2f')]};
Message


function save_Callback(hObject, eventdata, handles)
global Ei xi yi a_i
set(hObject, 'Enable', 'off'); 
pause(0.1)
if isempty(Ei)
    set(hObject, 'Enable', 'on'); 
    errordlg('There is no simulated trace','Error');
    return
end
E=0;
B=num2str(round((get(handles.bfield, 'value'))*100)/100);
D=num2str(round(get(handles.drift, 'value')));
xoffset=get(handles.xoffset,'value');
yoffset=get(handles.yoffset,'value');

line(:,1)=Ei';
line(:,2)=xi-xoffset';
line(:,3)=yi-yoffset';

A=a_i(1,1);
a=a_i(1,2);
A
if round(A)==1
	filestring=strcat('H+_trace_',B,'T_',E,'kV_',D,'mm_drift','.txt');
elseif round(A)==12
	filestring=strcat('C',num2str(a),'+_trace_',B,'T_',E,'kV_',D,'mm_drift','.txt');
elseif round(A)==16
	filestring=strcat('O',num2str(a),'+_trace_',B,'T_',E,'kV_',D,'mm_drift','.txt');
end
try
[file,path] = uiputfile(filestring,'Save simulated spectrum to file');
if file==0
else
    filepath=[path,file];
    save(filepath,'line','-ascii');
    
end
catch exception
end
set(hObject, 'Enable', 'on'); 

function cmax_Callback(hObject, eventdata, handles)
cmax=round(get(hObject, 'Value'));
cmin=get(handles.cmin,'value');
if cmax<cmin
    set(handles.cmax,'string',num2str(cmax));
    set(handles.cmax_text,'string',num2str(cmax),'foregroundcolor','r');
else
    set(handles.cmax,'string',num2str(cmax));
    set(handles.cmax_text,'string',num2str(cmax),'foregroundcolor',[0 0 0]);
    caxis([cmin cmax]);
end

function cmax_CreateFcn(hObject, eventdata, handles)

function caxismax1_Callback(hObject, eventdata, handles)
cmax=round(get(hObject, 'Value')*1000)/1000;
cmin=get(handles.cmin,'value');
if cmax<cmin
    set(handles.cmax,'string',num2str(cmax));
    set(handles.cmax_text,'string',num2str(cmax),'foregroundcolor','r');
else
    set(handles.cmax,'string',num2str(cmax));
    set(handles.cmax_text,'string',num2str(cmax),'foregroundcolor',[0 0 0]);
    caxis([cmin cmax]);
end

function caxismax1_CreateFcn(hObject, eventdata, handles)

function cmin_Callback(hObject, eventdata, handles)
cmin = round(get(hObject, 'Value')*1000)/1000;
cmax=str2double(get(handles.cmax_text,'string'));
if cmax<cmin
    set(handles.cmin,'string',num2str(cmin));
    set(handles.cmin_text,'string',num2str(cmin),'foregroundcolor','r');
else   
    set(handles.cmin,'string',num2str(cmin));
    set(handles.cmin_text,'string',num2str(cmin),'foregroundcolor',[0 0 0]);
    caxis([cmin cmax]);
end

function cmin_CreateFcn(hObject, eventdata, handles)

function plotcheck_Callback(hObject, eventdata, handles)
global check
check=get(hObject,'Value');

function reso_Callback(hObject, eventdata, handles)
global a_i
set(hObject, 'Enable', 'off'); 
pause(0.001)
A=a_i(1,1);
a=a_i(1,2);
E=0;
B=get(handles.bfield, 'value');
lB=get(handles.bfieldlength, 'value')/1E3;
lE=lB;
D=get(handles.drift, 'value')/1E3;
spot=str2double(get(handles.spot,'string'))*1E-3;
if isnan(spot)
else
    relsol=get(handles.relsol,'Value');
    if relsol==0
        Res1=resolution(E,lE,B,lB,D,a,A,spot,'classic');
        %Res2=resolution(E,lE,B,lB,D,a,A,spot,'relativistic');
    else
        Res1=resolution(E,lE,B,lB,D,a,A,spot,'relativistic');
    end

%e=1.60E-19;     %[C] electron charge
%mp=1.67E-27;     %[kg] nucleon mass (proton mass)
%q=a*e;
%m=A*mp;
%iE=1e6:1e6:900e6;
%Ek=iE*1e-6;
%s=spot*1e-3;
%x=(q*B*lB*D)./sqrt(2*m.*Ek.*e.*1e6);
%y=2.*x.^3.*s./(x.^2-(s./2).^2).^2;
%y1=2.*s./(x.*(1-(s./2./x).^2).^2);
ion=get(handles.ion,'string');
ion=cell2mat(ion(get(handles.ion,'value')));
charge=get(handles.charge,'string')
charge=cell2mat(charge(get(handles.charge,'value')))

dE(:,1)=1:1:round(max(Res1(:,1)));
dE(:,2)=interp1(Res1(:,1),Res1(:,2),dE(:,1));
dE(:,3)=-1*interp1(Res1(:,1),Res1(:,3),dE(:,1));
dE(:,4)=interp1(Res1(:,1),Res1(:,4),dE(:,1));


figure
if round(A)>1
    c=3;
else
    c=2;
end
subplot(c,1,1)
plot(dE(:,1),dE(:,2),'color','r')
hold on
plot(dE(:,1),dE(:,3),'color','b')
plot(dE(:,1),dE(:,4),'color','g')
hold off
grid on
ylabel('\Delta E/E')
xlabel('Energy (MeV)')
legend('Combined Resolution','Positive Error','Negative Error','location','NorthWest')
title(['\Delta E/E for ', ion(1), charge,' over MeV'])
subplot(c,1,2)
plot(dE(:,1),dE(:,2).*dE(:,1),'color','r')
hold on
plot(dE(:,1),dE(:,3).*dE(:,1),'color','b')
plot(dE(:,1),dE(:,4).*dE(:,1),'color','g')
hold off
grid on
ylabel('\Delta E (MeV)')
xlabel('Energy (MeV)')
%legend('Combined Resolution','Positive Error','Negative Error','location','NorthWest')
title(['\Delta E for ', ion(1), charge,' over MeV'])

if round(A)>1
    subplot(c,1,3)
    plot(dE(:,1)/A,dE(:,2),'color','r')
    hold on
    plot(dE(:,1)/A,dE(:,3),'color','b')
    plot(dE(:,1)/A,dE(:,4),'color','g')
    hold off
    %legend('Combined Resolution','Positive Error','Negative Error','location','NorthWest')
    title(strcat('\Delta E/E for:', ion(1), charge,' over MeV/amu'))
    ylabel('\Delta E/E')
    xlabel('Energy (MeV/u)')
    grid on
end
%hold on
%plot(Ek,y,'color','b')
%plot(Ek,y1,'x','color','g')
%hold off

prompt = {'Enter file name'};
dlg_title = 'Save resolition to txt-file?';
num_lines = 1;
species=['iWASP_Resolution_for_',ion(1),charge]
def = {species};
answer = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(answer)
else
    %save([char(answer),'.txt'],'Res1','-ascii')
    save([char(answer),'.txt'],'dE','-ascii')
end
end
set(hObject, 'Enable', 'on'); 

function savespec_Callback(hObject, eventdata, handles)
global pname fname a_i ylower yupper
set(hObject, 'Enable', 'off'); 
pause(0.1)

op=get(hObject,'Tag');

if strcmp(op,'savespec')
    if isappdata(handles.main,'M')==0
        errordlg('Load image first','Error');
    else
        species=get(handles.ion,'string');
        value=get(handles.ion,'value');
        species=cell2mat(species(value));
        species=species(1:1);
        load lastspectrum
        A=a_i(1,1);
        a=a_i(1,2);
        xoffset=get(handles.xoffset,'value');
        yoffset=get(handles.yoffset,'value');
        B=num2str(round((get(handles.bfield, 'value'))*100)/100);

        file=strcat(pname,fname, '_',species , num2str(a),'+_',B,'T','.mat');
        par =strcat(pname,fname, '_',species , num2str(a),'+_',B,'T','_par.txt');
        if exist('bg_specmap','var')==1
            save(file,'specmap','Energyvec','angle','A','cut','conversion','msr','t_ph','ph_detector','screen','slitlength','openangle','solidangle','diam','bg_specmap')
        else
            save(file,'specmap','Energyvec','angle','A','cut','conversion','msr','t_ph','ph_detector','screen','slitlength','openangle','solidangle','diam')
        end
        
        datei{1}=num2str(get(handles.bfield,'value'));
        datei{2}=num2str(get(handles.bfieldlength,'value'));
        datei{3}=num2str(0);
        datei{4}=num2str(0);
        datei{5}=num2str(0);
        datei{6}=num2str(get(handles.drift,'value'));
        datei{7}=num2str(get(handles.phdiameter,'value'));
        datei{8}=num2str(get(handles.ph_detector,'value'));
        datei{9}=num2str(get(handles.angle,'value'));
        datei{10}=num2str(xoffset);
        datei{11}=num2str(yoffset);
        datei{12}=num2str(get(handles.targetPH,'value'));
        datei{13}=num2str(ylower);
        datei{14}=num2str(yupper);
        datei{15}=num2str(get(handles.linehight,'value'));
        try
            load calibrationlist
            datei{16}=cell2mat(calibrationlist(get(handles.calibrationlist,'value')-2));
        catch exception
            exception
            datai{16}='Unkown Calibration used';
        end
        %datei=datei';    
        %save(par,'datei','-ascii');
        fid = fopen(par, 'w');
        for i=1:size(datei,2), % for each row
        fprintf(fid,'%s\n',datei{1,i});
        end
        fclose(fid)
        
    end
elseif strcmp(op,'loadspec')
    %wasp_plot;
    wasp_plotter;
end
set(hObject, 'Enable', 'on'); 

function checktr_Callback(hObject, eventdata, handles)
global checktr
checktr=get(hObject,'Value');

function cutoff_Callback(hObject, eventdata, handles)
type=get(hObject,'Tag');
if strcmp(type,'cut_high')
    if ~isnan(str2double(get(hObject,'string')))
        cut(2)=abs(str2double(get(hObject,'string')));
        set(hObject,'String',num2str(abs(str2double(get(hObject,'string')))))
    else
        cut(2)=100;
        set(hObject,'String','100')
    end
else
    if ~isnan(str2double(get(hObject,'string')))
        cut(1)=abs(str2double(get(hObject,'string')));
        set(hObject,'String',num2str(abs(str2double(get(hObject,'string')))))
    else
        cut(1)=10;
        set(hObject,'String','10')
    end
end

function cutoff_CreateFcn(hObject, eventdata, handles)


function tptype_Callback(hObject, eventdata, handles)
datacursormode off
global zero xlength ylength TP pname simu incx ylower yupper limits imlength incx incy loading fname
str = get(hObject, 'String');
val = get(hObject,'Value');
if loading==0
switch str{val};
    case 'Update List'
        if exist('TP_settings','dir')
            settings=dir('TP_settings/*_par.txt');
            settings=struct2cell(settings);
            [ycell,xcell]=size(settings);
            if xcell==0
                ncll=0;
                TP='List not updated';
                errordlg('No TP-Setting files found!','Ooops');
            else
                for ncll=1:xcell
                    entry=cell2mat(settings(1,ncll));
                    strnew{ncll}=entry(1:length(entry)-8);
                end
                TP='List updated';
            end
        else
            ncll=0;
            TP='List not updated';
            errordlg('No TP-Setting files found!','Ooops');
        end
        strnew{ncll+1}='Custom';
        strnew{ncll+2}='Update List';
        set(hObject,'Value',ncll+2)
        set(hObject,'String',strnew);
        
    case 'Custom'
        if exist('pname','var')
                [file,path]=uigetfile({'*_par.txt','TP Parameter File (*_par.txt)'},'Load reference',pname);
        else
                [file,path]=uigetfile({'*_par.txt','TP Parameter File (*_par.txt)'},'Load reference');
        end
        
        if file==0
            return
        end
  
        par=strcat(path,file);
        TP=num2str(file(1:length(file)-8));
        
    otherwise
        TP=str{val};
        file=[TP,'_par.txt'];
        par=strcat('TP_settings/',file);

end
if strcmp(str{val},'Update List')
    return
end
else
    loading=0;
    try
        par=[pname,fname,'_H1+_0.44T_par.txt'];
        TP=num2str(fname(1:length(fname)-4));
        datei=load(par);
    catch 
        disp([par,' not found.'])
    	try
        par=[pname,fname,'_C6+_0.48T_par.txt'];
        TP=num2str(fname(1:length(fname)-4));
        datei=load(par);
        catch exception
            disp([par,' not found. Skipping parameter file.'])
            return
        end
    end
end
set(handles.type,'string',num2str(TP),'Foregroundcolor','r')
try
    fid = fopen(par);
    datei = fscanf(fid, '%g');
    cal=cell2mat(cellstr(fscanf(fid, '%c')));
    load calibrationlist
    for c=1:length(calibrationlist)
        if strcmp(cell2mat(calibrationlist(c)),cal)==1
        set(handles.calibrationlist,'Value',c+2)
        else
        end
    end
catch exception
end
fclose(fid);

%datei=load(par);

set(handles.bfield_text,'String',strcat(num2str(datei(1))))
set(handles.bfield,'value',datei(1))
set(handles.bfieldlength_text,'String',strcat(num2str(datei(2))))
set(handles.bfieldlength,'value',datei(2))
set(handles.drift_text,'String',strcat(num2str(round(datei(6)))))
set(handles.drift,'value',datei(6))
set(handles.phdiameter_text,'String',strcat(num2str(datei(7))))
set(handles.phdiameter,'value',datei(7))
set(handles.ph_detector_text,'String',strcat(num2str(datei(8))))
set(handles.ph_detector,'value',datei(8))
set(handles.angle_text,'String',strcat(num2str(datei(9))))
set(handles.angle,'value',datei(9)) 
try
    ylower=datei(13);
    yupper=datei(14);
    delete(limits(ishandle(limits)))
    hold on
    xlimplot=1:imlength(2)*incx*1e-3/10:imlength(2)*incx*1e-3;
    limits(1)=plot(xlimplot,xlimplot.*0+yupper,'--','Linewidth',2,'color','black'); 
    limits(2)=plot(xlimplot,xlimplot.*0+ylower,'--','Linewidth',2,'color','black'); 
    hold off  
    set(handles.linehight,'SliderStep',[0 datei(15)+1]);
    set(handles.linehight,'value',datei(15));
    set(handles.linesubval,'string',strcat(num2str(datei(15))))    
catch exception
end
% Construct a questdlg for adding offsets
choice = questdlg('Replace offset:', ...
'Load offset from file?','Yes','No','No');
% Handle response
switch choice
	case 'Yes'
        xoffset=round(datei(10)*100)/100;
        xtp =strcat(num2str(xoffset));
        yoffset=round(datei(11)*100)/100;
        ytp =strcat(num2str(yoffset));
        set(handles.xoffset,'String',xtp)
        set(handles.yoffset,'String',ytp)
        set(handles.xoffset,'value',xoffset);
        set(handles.yoffset,'value',yoffset);
    case 'No'
        xoffset=get(handles.xoffset,'value');
        yoffset=get(handles.yoffset,'value');
end

if length(datei)<12
	datei(12)=1250;
end

set(handles.targetPH,'value',datei(12))
set(handles.targetph_text,'String',strcat(num2str(datei(12)),' mm'))
        
spotsize=round((datei(8)+datei(12))/datei(12)*datei(7)); %spotsize in um
set(handles.hbin,'value',spotsize);
if incx<1
	incx=1;
end
set(handles.hbin_text,'string',[num2str(spotsize), 'um / ',num2str(round(spotsize/incx)),'pixel']);
set(handles.spotpx,'string',num2str(round(spotsize/incx)));
set(handles.spot,'string',spotsize);
spotsize=988

set(handles.width,'value',spotsize);
set(handles.width_text,'string',[num2str(spotsize), 'um / ',num2str(round(spotsize/incx)),'pixel']);

msr=(datei(7)*1e-6/2)^2*pi/(datei(12)*1e-3)^2*1E3; %steradians in msr
set(handles.solid_angle,'string',[num2str(msr, '%10.2e\n'),' msr']);
        
delete(zero(ishandle(zero)))
delete(simu(ishandle(simu)))
        
if isempty(xlength)
	xlength=100;
    ylength=100;
end
xtp=1:max(xlength);
ytp=1:max(ylength);
hold on
alpha=datei(9)/360*2*pi;
zero(1)=plot (xoffset+0*ytp,ytp,'-k','Linewidth',2);
zero(2)=plot (xtp,sin(alpha)*xtp+yoffset-sin(alpha)*xoffset,'-k','Linewidth',2);
hold off

function tptype_CreateFcn(hObject, eventdata, handles)

function linesub_Callback(hObject, eventdata, handles)
global linesub pname
linesub=get(hObject,'Value');

if linesub==1
    % Construct a questdlg for adding offsets
    choice = questdlg('Background subtraction', ...
    'Extract background from file?','Yes','No','No');
    % Handle response
    switch choice
        case 'Yes'
                [bg]=loadasf(pname);
                if bg==0
                    return
                end
                figure
                imagesc(bg)
                axis xy
                caxis([min(min(bg)) max(max(bg))]);
                rect=round(getrect);
                figure
                imagesc(bg(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3)))
                axis xy
                bglineout=mean(bg(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3)));
                figure
                plot(bglineout)
                bgval=mean(bglineout);
                text(20,max(bglineout),['min/avg/max=',num2str(bgval),'/',num2str(1.15*bgval),'/',num2str(1.3*bgval)],'color','r')
                set(handles.linesubval,'string',num2str(1.15*bgval))
        case 'No'
    end
end


function linehight_Callback(hObject, eventdata, handles)
global linehight
linehight = get(hObject, 'Value')
cmax=str2double(get(handles.cmax_text,'string'));
slidermax=cmax*.9;
if cmax<linehight
    set(handles.linehight,'value',0);
end
set(handles.linehight,'Max',slidermax);
if cmax<100
    step=0.01;
elseif cmax<10
    step=0.001;
elseif cmax<1
    step=0.0001;
else
    step=1;
end
set(handles.linehight,'SliderStep',[step/cmax step*10/cmax]);

linehight = get(hObject, 'Value');
set(handles.linesubval,'string',num2str(linehight))
caxis([linehight cmax]);

function linesubval_Callback(hObject, eventdata, handles)
global linehight
bg=str2double(get(hObject,'string'));
if isnan(bg)||bg<0
    bg=linehight;
    set(handles.linesubval,'string',num2str(linehight));
    return
end
if bg>get(handles.linehight,'Max')
    set(handles.linehight,'Max',ceil(bg));
elseif bg<get(handles.linehight,'Min')
    set(handles.linehight,'Min',floor(bg));
end
linehight=bg;   
set(handles.linehight,'value',bg);

function linesubval_CreateFcn(hObject, eventdata, handles)

function linehight_CreateFcn(hObject, eventdata, handles)

function reset_Callback(hObject, eventdata, handles)
global xlength ylength fname simu zero back over Ei xi yi
datacursormode off
set(handles.Maingui,'Pointer','arrow')

if isappdata(handles.main,'M')
    Matrix=getappdata(handles.main,'M');    
    imagesc(xlength,ylength,Matrix)
    axis xy
    xlabel('B-field deflection (mm)')
    ylabel('E-field deflection (mm)')
    T=title(fname);
    set(T,'Interpreter','none')
    cmin=get(handles.cmin,'Value');
    cmax=str2double(get(handles.cmax_text,'string'));
    caxis([cmin cmax]);
    hold on
end
simu=plot(0,0);
zero=plot(0,0);
back=plot(0,0);
over=plot(0,0);
xi=0;
Ei=0;
yi=0;
hold off
set(handles.savespec, 'Enable', 'on');
set(handles.spectr, 'Enable', 'on');
set(handles.bfieldlength, 'Enable', 'on');
set(handles.bfield, 'Enable', 'on');
set(handles.angle, 'Enable', 'on');
set(handles.angle_text, 'Enable', 'on');
set(handles.targetPH, 'Enable', 'on');
set(handles.phdiameter, 'Enable', 'on');
set(handles.reso, 'Enable', 'on');
set(handles.save, 'Enable', 'on');
set(handles.cvsr, 'Enable', 'on');
set(handles.savespec, 'Enable', 'on'); 
set(handles.find0, 'Enable', 'on'); 
set(handles.loadspec, 'Enable', 'on'); 
guidata(hObject, handles);
clc;

function relsol_Callback(hObject, eventdata, handles)
relsol=get(hObject,'Value');
if relsol==1
    set(hObject,'foregroundcolor','r')
elseif relsol==0
    set(hObject,'foregroundcolor',[0 0 0])
end

function CRb_Callback(hObject, eventdata, handles)
h=srimcalc;
%[E_CR39_Alu, E_alu_end]=CR39srim;
%Message=['Ion has ', num2str(E_alu_end),'MeV after passing Alu and ' ,num2str(E_CR39_Alu),'MeV after passing CR39'];
%h = msgbox(Message,'Ion breakthrough');

function cvsr_Callback(hObject, eventdata, handles)
global a_i
set(hObject, 'Enable', 'off');
pause(0.1)
A=a_i(1,1);
a=a_i(1,2);
edistance=get(handles.edistance,'value')/1E3;
E=get(handles.efield,'value')*1E3/edistance;
B=get(handles.bfield, 'value');
lB=get(handles.bfieldlength, 'value')/1E3;
lE=lB;
D=get(handles.drift, 'value')/1E3;

diff=compare_tracer(E,lE,B,lB,D,a,A);
figure
plot(diff(:,3)/1e6,diff(:,2)/1e6)
t='Comparison of classical and relativistic solver';
ylabel('Relativistic E - Classic E (MeV)');
xlabel('Energy (MeV)');
title(t)
if A==1
    ion='Proton';
elseif A==12
    ion=['Carbon C',num2str(a),'+'];
elseif A==16
    ion=['Oxygen O',num2str(a),'+'];
else
    ion='unknown ion';
end
legend(ion)
set(hObject, 'Enable', 'on');

% --- Executes on button press in calibrate.
function calibrate_Callback(hObject, eventdata, handles)
global spl_cal zerovals yupper ylower limits imlength xlimplot incx incy center B xys a_i
datacursormode off
A=a_i(1,1);
a=a_i(1,2);
if isappdata(handles.main,'M')==0
    errordlg('Load image first','Error');
    return
else
    selection=get(hObject,'Tag')
end

if strcmp(selection,'calibrate')
    choice = questdlg('Please choose method:',...
        'Calibration file', 'Create new calibration', 'Iterate existing calibration', 'Cancel','Cancel');
    % Handle response
    switch choice
    case 'Create new calibration'
    %Matrix=getappdata(handles.main,'M');
    delete(spl_cal(ishandle(spl_cal)))
    % Loop, picking up the points.
    %disp('Left mouse button picks points.')
    %disp('Right mouse button picks last point.')
    but = 1;
    xy = [];
    n = 0;
    hold on
    while but == 1
        [xi,yi,but] = ginput(1);
        n = n+1;
        spl_cal(n)=plot(xi,yi,'ro');
        xy(:,n) = [xi;yi];
    end
    % Interpolate with a spline curve and finer spacing.
    if n==1
        errordlg('Please set at least 2 points!','Error');
    return
    end
    t = 1:n;
    range=abs(xy(2,1)-xy(2,length(xy)));
    ts = 1: (n-1)/100 : n;
    xys = spline(t,xy,ts);
    % Plot the interpolated curve.
    spl_cal(n+1)=plot(xys(1,:),xys(2,:),'g-','Linewidth',2);
    hold off
    yzerovals=xys(2,:);
    xzerovals=interp1(zerovals(:,2),zerovals(:,1),yzerovals);
    diff=abs(xzerovals-xys(1,:));
    e=1.60E-19;      %[C] electron charge
    q=a*e;
    mp=1.67E-27;     %[kg] nucleon mass (proton mass)
    m=A*mp;
    
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='tex';
	prompt = {'Low energy cutoff in MeV:'};
	dlg_title = 'Calibration line:';
	num_lines = 1;
	def = {'11','hsv'};
	E_through =inputdlg(prompt,dlg_title,num_lines,def,options);
    E_through = str2double(cell2mat(E_through));
    
    lB=get(handles.bfieldlength, 'value')/1E3;
    DB=get(handles.drift, 'value')/1E3;
    B=diff.*(sqrt(2.*m.*E_through*1e6.*e))./(q.*lB.*(DB+0.5.*lB));
    figure
    plot(xys(2,:),B)
    
    yoff=get(handles.yoffset,'value');
    xys(2,:)=xys(2,:)-yoff;
    
    hold on 
    plot(xys(2,:),B)
    hold off
    
    prompt = {'Enter file name'};
    dlg_title = 'Save calibration to txt-file?';
    num_lines = 1;
    def = {'iWASP_Calibration_'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    if isempty(answer)
    else
        if xys(2,length(xys))<xys(2,1)
            B_calib(:,1)=round((xys(2,length(xys)):.1:xys(2,1))*10)/10;
        else
            B_calib(:,1)=round((xys(2,1):.1:xys(2,length(xys)))*10)/10;
        end
        B_calib(:,2)=interp1(xys(2,:),B,B_calib(:,1))';
        save([char(answer),'.txt'],'B_calib','-ascii')
    end
    case 'Iterate existing calibration'
        calibrate;
    case 'Cancel'
    end
elseif strcmp(selection,'setlimits')
    delete(limits(ishandle(limits)))
    [x,y] = ginput(2);
    try
        if length(y)<2 || ...
             y(1) > imlength(1)*incy*1e-3 || y(1) < 0 || ...
             y(2) > imlength(1)*incy*1e-3 || y(2) < 0
            return
        end
    catch
        return
    end
    if y(1)>y(2)
        yupper=y(1);
        ylower=y(2);
    else
        yupper=y(2);
        ylower=y(1);
    end
    hold on
    xlimplot=1:imlength(2)*incx*1e-3/10:imlength(2)*incx*1e-3;
    limits(1)=plot(xlimplot,xlimplot.*0+yupper,'--','Linewidth',2,'color','black'); 
    limits(2)=plot(xlimplot,xlimplot.*0+ylower,'--','Linewidth',2,'color','black'); 
    hold off
elseif strcmp(selection,'center')
    [xoff,yoff] = ginput(1)
    center=yoff;
end
function cr39_Callback(hObject, eventdata, handles)

% --- Executes when Maingui is resized.
function Maingui_ResizeFcn(hObject, eventdata, handles)



function CE_cutoff_Callback(hObject, eventdata, handles)
% hObject    handle to CE_cutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CE_cutoff as text
%        str2double(get(hObject,'String')) returns contents of CE_cutoff as a double


% --- Executes during object creation, after setting all properties.
function CE_cutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CE_cutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ip.
function ip_Callback(hObject, eventdata, handles)
% hObject    handle to ip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ip


% --- Executes on selection change in calibrationlist.
function calibrationlist_Callback(hObject, eventdata, handles)
datacursormode off

str = get(hObject, 'String');
val = get(hObject,'Value');

switch str{val};
    case 'Update List'      
        settings=dir('iWASP_Calibration_*.txt');
        settings=struct2cell(settings);
        [ycell,xcell]=size(settings);
        if xcell==0
            ncll=0;
            % Construct a questdlg for adding offsets
            choice = questdlg('No calibration files found:', ...
            'Load calibration from different folder?','Yes','No','No');
            % Handle response
            switch choice
                case 'Yes'
                    
                case 'No'
                    errordlg('No Calibration files loaded!','Ooops');
            end
        else
            strnew{1}='No calibration';
            strnew{2}='Update List';
            for ncll=1:xcell
                    entry=cell2mat(settings(1,ncll));
                    entry_short=entry(19:length(entry)-4);
                    if isempty(entry_short)
                        strnew{ncll+2}=entry(1:end-4);
                    else
                        strnew{ncll+2}=entry_short;
                    end
                    calibrationlist{ncll}=entry;
            end
            save('calibrationlist','calibrationlist')
            TP='List updated';
        end
        set(hObject,'Value',3)
        set(hObject,'String',strnew); 
    otherwise
    return
end

% --- Executes during object creation, after setting all properties.
function calibrationlist_CreateFcn(hObject, eventdata, handles)
settings=dir('iWASP_Calibration_*.txt');
settings=struct2cell(settings);
[ycell,xcell]=size(settings);
if xcell==0
    calibrationlist{1}=[];
else
	strnew{1}='No calibration';
    strnew{2}='Update List';
    for ncll=1:xcell
        entry=cell2mat(settings(1,ncll));
        entry_short=entry(19:length(entry)-4);
        if isempty(entry_short)
            strnew{ncll+2}=entry(1:end-4);
        else
            strnew{ncll+2}=entry_short;
        end
        calibrationlist{ncll}=entry;
    end
    TP='List updated';
    set(hObject,'Value',3)
    set(hObject,'String',strnew); 
end
save('calibrationlist','calibrationlist')       

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
