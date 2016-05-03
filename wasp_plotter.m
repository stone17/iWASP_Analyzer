function varargout = wasp_plotter(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wasp_plotter_OpeningFcn, ...
                   'gui_OutputFcn',  @wasp_plotter_OutputFcn, ...
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


% --- Executes just before wasp_plotter is made visible.
function wasp_plotter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wasp_plotter (see VARARGIN)

% Choose default command line output for wasp_plotter
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

pause(0.1)

load_Callback(hObject, eventdata, handles)

% --- Outputs from this function are returned to the command line.
function varargout = wasp_plotter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function load_Callback(hObject, eventdata, handles)
global specmap conversion_dE Energyvec minE maxE
if getappdata(0,'fromgui')==1
    try
        load lastspectrum
    catch
        return
    end
else
	if exist('lastpath.txt','file')
        fid = fopen('lastpath.txt','r');
        pname=(fread(fid,'*char'))';
        fclose(fid);
    else
        pname='c:\';
    end
	[fname,pname]=uigetfile({'*T.mat','Spectrum files'},'Select spectrum file',pname);
	try
        file=[pname,fname];  
        load(file)
        fid = fopen('lastpath.txt', 'wt');
        fprintf(fid, '%s', pname);
        fclose(fid);
    catch
        disp('No valid spectrum file selected')
        return
    end
end
specmap(isnan(specmap))=0;
specmap(~isreal(specmap))=0;


setappdata(handles.main,'fname',fname)
setappdata(handles.main,'pname',pname)
setappdata(handles.main,'specmap',specmap)
setappdata(handles.main,'Energyvec',Energyvec)

set(handles.bottom,'Min',floor(min(angle(:,1))))
set(handles.bottom,'Max',max(angle(:,1)))
set(handles.start,'string',['Spectrum starts at ',num2str(floor(min(angle(:,1))*10)/10),'°'])
set(handles.top,'Min',min(angle(:,1)))
set(handles.top,'Max',max(angle(:,1)))
set(handles.stop,'string',['Spectrum ends at ',num2str(round(max(angle(:,1))*10)/10),'°'])

setappdata(handles.main,'angle',angle(:,:))
setappdata(handles.main,'cut',cut)
setappdata(handles.main,'A',A)
setappdata(handles.main,'conversion',conversion)


set(handles.minE_sl,'MIN',round(min(Energyvec(:)*10))/10)
set(handles.minE_sl,'MAX',round(max(Energyvec(:)*10))/10)
set(handles.minE_sl,'value',round(min(Energyvec(:)*10))/10)
set(handles.minE_t,'string',num2str(round(min(Energyvec(:)*10))/10))

set(handles.maxE_sl,'MIN',round(min(Energyvec(:)*10))/10)
set(handles.maxE_sl,'MAX',round(max(Energyvec(:)*10))/10)
set(handles.maxE_sl,'value',round(max(Energyvec(:)*10))/10)
set(handles.maxE_t,'string',num2str(round(max(Energyvec(:)*10))/10))


plotdata_Callback(hObject, eventdata, handles, 5)


function plotdata_Callback(hObject, eventdata, handles, mode)
specmap=getappdata(handles.main,'specmap');
Energyvec=getappdata(handles.main,'Energyvec');
angle=getappdata(handles.main,'angle');
cut=getappdata(handles.main,'cut');
A=getappdata(handles.main,'A');
conversion=getappdata(handles.main,'conversion');

drawnow expose

if mode==1 || mode==5
    %surface plot
    surf(handles.spectrum,log(Energyvec),angle(:,1),log(specmap(:,:,1)));
    shading(handles.spectrum,'interp')
    %caxis([0.01*mean(mean(specmap)) max(max(specmap))])
    if A==1
        ticks=[1.1,2,3,4,5,10,10.4,11,20:10:fix(cut(2)/10)*10];
    elseif round(A)==2
        ticks=[20,30,40,50,75,100:100:fix(cut(2)/100)*100];
    else
        ticks=[20,25,50,75,100:100:fix(cut(2)/100)*100];
    end
    set(handles.spectrum,'XTick',log(ticks))
    set(handles.spectrum,'XTickLabel',ticks)
    set(handles.spectrum,'ZTick',log([10^1,10^2,10^3,10^4,10^5,10^6,10^7,10^8]))
    set(handles.spectrum,'ZTickLabel',{'1e1','1e2','1e3','1e4','1e5','1e6','1e7','1e8'})

    econt=1;
    col=0;
    if econt==1
        if A==1 %set contour steps depending on species
            steps=[1.1,4.2,5,10,10.4,15,20:10:floor(cut(2)/10)*10];
            %steps=[11,50,100,120];
        elseif round(A)==2
            steps=[20,30,40,50,75,100,150,200,230,300:100:floor(cut(2)/10)*10];
        else
            steps=[20,25,50,75,100,150,200,230,300:100:floor(cut(2)/10)*10];
        end
        for contstep=steps
            if contstep<min(Energyvec) || contstep>max(Energyvec)
            else
            Ediff=sqrt((Energyvec-contstep).^2);
            [value,index]=min(Ediff);
            hold(handles.spectrum,'on')
            energy=plot3(handles.spectrum,log(Energyvec(index))+0*[1:length(angle(:,1))],angle(:,1),log(specmap(:,index,1)),'linewidth',1.5,'color',[0.4 0.4 0.4]);
            hold(handles.spectrum,'off')
            col=col+1;
            contour(col,:)=specmap(:,index,1);
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
            hold(handles.spectrum,'on')
            plot3(handles.spectrum,log(Energyvec),angle(index,1)+0*[1:length(Energyvec)],log(specmap(index,:,1)),'linewidth',1.5,'color',[0.4 0.4 0.4])
            hold(handles.spectrum,'off')
            end
        end           
    else
    end

    xlabel(handles.spectrum,'Energy (MeV)')
    ylabel(handles.spectrum,'Angle(°)')
    zlabel(handles.spectrum,'Counts/MeV/msr')

    set(handles.spectrum,'View',[50 50])
    cch=colorbar('peer',handles.spectrum);
    set(cch,'Ytick',log([10^1,10^2,10^3,10^4,10^5,10^6,10^7,10^8]))
    set(cch,'YTickLabel',{'1e1','1e2','1e3','1e4','1e5','1e6','1e7','1e8'})

    set(handles.spectrum,'view',[50 50])
end

%iso energy plot
if mode==2 || mode ==5
    for a=1:length(contour(:,1))
        if a==1
            c=[0 0 1];
        elseif a==2
            c=[0 1 0];
        elseif a==3
            c=[1 0 0];
        elseif a==4
            c=[0 1 1];
        elseif a==5
            c=[1 1 0];
        elseif a==6
            c=[1 0 1];
        elseif a==7
            c=[.5 0.5 .5];
        elseif a==8
            c=[0.5 1 0.5];
        elseif a==9
            c=[0 .5 .5];
        end
        if a==1
            plot(handles.isoenergy, contourA(a,:),log(contour(a,:)),'color',c,'linewidth',3)
            hold(handles.isoenergy,'on')
            %text(contourA(a,length(contourA(a,:))),log(contour(a,length(contour(a,:)))),num2str(contourE(a)),'color',c,'fontsize',18)
            M(a)=contourE(a);
        else
            hold(handles.isoenergy,'on')
            plot(handles.isoenergy, contourA(a,:),log(contour(a,:)),'color',c,'linewidth',3)
            %text(contourA(a,length(contourA(a,:))),log(contour(a,length(contour(a,:)))),num2str(contourE(a)),'color',c,'fontsize',18)
            M(a)=contourE(a);
        end
        hold(handles.isoenergy,'off') 
    end
    legend(handles.isoenergy,num2str(M'))
    xlabel(handles.isoenergy,'Angle(°)')
    ylabel(handles.isoenergy,'PSL/MeV/msr at constant Energy')

    set(handles.isoenergy,'Ytick',log([10^1,10^2,10^3,10^4,10^5,10^6,10^7,10^8]))
    set(handles.isoenergy,'YTickLabel',{'1e1','1e2','1e3','1e4','1e5','1e6','1e7','1e8'})
    grid(handles.isoenergy,'on')
end

%average particle number per angle
if mode==3 || mode ==5
    dE_conversion=0;
    if get(handles.maxE_sl,'value')<get(handles.maxE_sl,'Max') || get(handles.minE_sl,'value')>get(handles.minE_sl,'Min')
        minE=get(handles.minE_sl,'value');
        maxE=get(handles.maxE_sl,'value');
        indmin=find(min(sqrt((minE-Energyvec).^2))==sqrt((minE-Energyvec).^2));
        indmax=find(min(sqrt((maxE-Energyvec).^2))==sqrt((maxE-Energyvec).^2));
        %conversion_dE=sum(specmap(:,indmax:indmin,2))
        try
        conversion_dE=sum(specmap(:,indmax:indmin,2)')';
        dE_conversion=1;
        catch
            'Please recalculate spectrum and try again!'
        end
    end
    for indexa=2:length(angle(:,1))
        ce(indexa-1,1)=(angle(indexa,1)+angle(indexa-1,1))/2;
        ce(indexa-1,2)=(conversion(indexa,2)+conversion(indexa-1,2))/2/(angle(indexa,1)-angle(indexa-1,1));
        if dE_conversion==1
            ce(indexa-1,3)=(conversion_dE(indexa)+conversion_dE(indexa-1))/2/(angle(indexa,1)-angle(indexa-1,1));
        end
    end
    av(1)=semilogy(handles.average, ce(:,1),ce(:,2),'color','r','linewidth',3);
    if dE_conversion==1
        hold(handles.average,'on')
        av(2)=semilogy(handles.average, ce(:,1),ce(:,3),'color','b','linewidth',3);
        hold(handles.average,'off')
    end
    xlabel(handles.average,'Angle(°)')
    ylabel(handles.average,'Particles(#/°)')
    grid(handles.average,'on')
    setappdata(handles.main,'ce',ce)
end

if mode==4 || mode ==5
    angle_min=get(handles.bottom,'value');
    angle_max=get(handles.top,'value');
    avg=find(angle_min<angle(:,1) & angle(:,1)<angle_max);
    semilogy(handles.lineout, Energyvec,sum(specmap(avg,:,1))./length(avg),'color','b','linewidth',3)
    title(handles.lineout,['Average spectrum from angle ',num2str(angle_min),'° to ',num2str(angle_max),'°'])
    
    lineout(:,1)=Energyvec;
    lineout(:,2)=sum(specmap(avg,:,1))./length(avg);
    
    try
        hold(handles.lineout,'on')
        semilogy(handles.lineout, Energyvec,sum(specmap(avg,:,3))./length(avg),'color','r','linewidth',3)
        if exist('bg_specmap','var')==1
            semilogy(handles.lineout, Energyvec,sum(bg_specmap(avg,:,1))./length(avg),'color','y','linewidth',3) %detection threshold
            semilogy(handles.lineout, Energyvec,sum(bg_specmap(avg,:,2))./length(avg),'color','m','linewidth',3) %calibration #1 of background 
            semilogy(handles.lineout, Energyvec,sum(bg_specmap(avg,:,3))./length(avg),'color','c','linewidth',3) %calibration of raw data
        end
        lineout(:,3)=sum(specmap(avg,:,3))./length(avg);
        lineout(:,4)=sum((specmap(avg,:,1)+specmap(avg,:,3))/2)./length(avg);
        legend(handles.lineout,'Calibration 1','Calibration 2')
    end
    setappdata(handles.main,'lineout',lineout)
    hold(handles.lineout,'off')
    grid(handles.lineout,'on')
end

% --- Executes on button press in save_line.
function line_Callback(hObject, eventdata, handles)
mode=get(hObject,'Tag');
%line=num2str(getappdata(handles.main,'line'),'%10.2f %10.3e\n');
lineout=getappdata(handles.main,'lineout');
ce=getappdata(handles.main,'ce');
A=round(getappdata(handles.main,'A'));
bot=(get(handles.bottom_text,'string'));
top=(get(handles.top_text,'string'));
pname=getappdata(handles.main,'pname');
fname=getappdata(handles.main,'fname');
fname=fname(1:5);

if strcmp(mode,'copy_line')
    %openvar('line')
    clipboard('copy',lineout)
elseif strcmp(mode,'save_line') 
    if A==1
        filestring=strcat(fname,'_H+_trace_',bot,'-',top,'degree','.txt');
    elseif A==2
        filestring=strcat(fname,'_D+_trace_',bot,'-',top,'degree','.txt');
    elseif A==12
        filestring=strcat(fname,'_C6+_trace_',top,'degree','.txt');
    elseif A==16
        filestring=strcat(fname,'_O8+_trace_',top,'degree','.txt');
    end
    
    [file,path] = uiputfile({'*.txt','All ASCII Files';'*.*','All Files' },'Save lineout',[pname,filestring]);
    if file==0
        
    else
        filepath=[path,file];
        save(filepath,'lineout','-ascii');
    end
elseif strcmp(mode,'save_average')
    if A==1
        filestring=strcat(fname,'_H+_average','.txt');
    elseif A==2
        filestring=strcat(fname,'_D+_average','.txt');
    elseif A==12
        filestring=strcat(fname,'_C6+_average','.txt');
    elseif A==16
        filestring=strcat(fname,'_O8+_average','.txt');
    end
    dims=size(ce);
    if dims(2)>2
        filestring=strcat(filestring(1:end-4),'_',num2str(round(get(handles.minE_sl,'value'))),...
            'MeV_to_',num2str(round(get(handles.maxE_sl,'value'))),'MeV','.txt');
    end
    
    [file,path] = uiputfile({'*.txt','All ASCII Files';'*.*','All Files' },'Save lineout',[pname,filestring]);
    
    if file==0
        
    else
        filepath=[path,file];
        save(filepath,'ce','-ascii');
    end
    
end
    
% --- Executes on slider movement.
function angle_Callback(hObject, eventdata, handles)
set(hObject,'enable','off')
pause(0.01)
tag=get(hObject,'tag');
bottom=round(get(handles.bottom,'value')*100)/100;
top=round(get(handles.top,'value')*100)/100;
bottom_text=str2double(get(handles.bottom_text,'string'));
top_text=str2double(get(handles.top_text,'string'));

if strcmp(tag,'bottom')
    if bottom>get(handles.bottom,'Max') || bottom>top-0.5
        set(hObject,'value',bottom_text)
    else
        set(handles.bottom_text,'string',num2str(bottom))
        set(handles.bottom,'value',(bottom))
        plotdata_Callback(hObject, eventdata, handles, 4)
    end
elseif strcmp(tag,'top')
    if top<get(handles.bottom,'Min') || bottom>top-0.5
        set(handles.top,'value',(top))
    else
        set(handles.top_text,'string',num2str(top))
        set(hObject,'value',top)
        plotdata_Callback(hObject, eventdata, handles, 4)
    end
elseif strcmp(tag,'bottom_text')
    if isnan(bottom_text) || bottom_text<get(handles.bottom,'Min') || bottom_text>top-0.5
        set(hObject,'string',num2str(bottom))
    else
        set(handles.bottom,'value',bottom_text)
        plotdata_Callback(hObject, eventdata, handles, 4)
    end
elseif strcmp(tag,'top_text')
    if isnan(top_text) || top_text>get(handles.bottom,'Max') || bottom_text>top-0.5
        set(hObject,'string',num2str(top))
    else
        set(handles.top,'value',top_text)
        plotdata_Callback(hObject, eventdata, handles, 4)
    end
end
set(hObject,'enable','on')

% --- Executes during object creation, after setting all properties.
function angle_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function E_range_Callback(hObject, eventdata, handles)
%set(hObject,'enable','off')
pause(0.01)
tag=get(hObject,'tag');
minE=round(get(handles.minE_sl,'value')*100)/100;
maxE=round(get(handles.maxE_sl,'value')*100)/100;
minE_t=str2double(get(handles.minE_t,'string'));
maxE_t=str2double(get(handles.maxE_t,'string'));

if strcmp(tag,'minE_sl')
    if minE>get(handles.minE_sl,'Max') || (minE>maxE-5 && maxE>get(handles.maxE_sl,'Max')-(maxE-minE)-5)
        set(hObject,'value',minE_t)   
        pause(0.01)
    else
        if minE>maxE-5
            set(handles.maxE_t,'string',num2str(minE+5))
            set(handles.maxE_sl,'value',(minE+5))
            pause(0.01)
        end 
        set(handles.minE_t,'string',num2str(minE))
        set(handles.minE_sl,'value',(minE))
        pause(0.01)
        plotdata_Callback(hObject, eventdata, handles, 3)
    end
elseif strcmp(tag,'maxE_sl')
    if maxE<get(handles.maxE_sl,'Min') || (minE>maxE-5 && minE<get(handles.minE_sl,'Min')-(maxE-minE)+5)
        set(handles.maxE_sl,'value',(maxE_t))
        pause(0.01)
    else
        if minE>maxE-5
            set(handles.minE_t,'string',num2str(minE-5))
            set(handles.minE_sl,'value',(minE-5))
            pause(0.01)
        end 
        set(handles.maxE_t,'string',num2str(maxE))
        set(hObject,'value',maxE)
        pause(0.01)
        plotdata_Callback(hObject, eventdata, handles, 3)
    end
elseif strcmp(tag,'minE_t')
    if isnan(minE_t) || minE_t<get(handles.minE_sl,'Min') || minE_t>maxE_t-5
        set(hObject,'string',num2str(minE))
    else
        set(handles.minE_sl,'value',minE_t)
        plotdata_Callback(hObject, eventdata, handles, 3)
    end
elseif strcmp(tag,'maxE_t')
    if isnan(maxE_t) || maxE_t>get(handles.maxE_sl,'Max') || minE_t>maxE_t-5
        set(hObject,'string',num2str(maxE))
    else
        set(handles.maxE_sl,'value',maxE_t)
        plotdata_Callback(hObject, eventdata, handles, 3)
    end
end
set(hObject,'enable','on')


% --- Executes during object creation, after setting all properties.
function E_range_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
