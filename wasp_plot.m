function [ce,CE,specmap,angle,Energyvec,solidangle,bfit,conversion]=wasp_plot(pname,fname,specmap,Energyvec,angle,A,cut,conversion,error,msr,diam,t_ph,bg_specmap);
%clc
%clear all
%close all
%global angle
if nargin~=2
    if exist('lastpath.txt','file')
        fid = fopen('lastpath.txt','r');
        pname=(fread(fid,'*char'))';
        fclose(fid);
    else
        pname='c:\';
    end
end

if nargin==0 || nargin>13
    [fname,pname]=uigetfile({'*T.mat','Spectrum files'},'Select spectrum file',pname);
    try
        file=[pname,fname];  
    load(file)
    catch
        disp('No valid spectrum file selected')
        return
    end
elseif nargin==2
    file=[pname,fname];  
    load(file)
end

try
    specmap_cal=specmap(:,:,2);
    spec_backup=specmap;
    %specmap=specmap(:,:,1);
catch exception
    exception
    a(:,1)=angle(:,1);
    %angle=a(:,1);
    [y,x]=size(angle);
    if x>y
        angle_(:,1)=angle(1,:);
        angle=angle_;
    end
end

%specmap(specmap<9e5)=0; %CR39 jpg
specmap(isnan(specmap))=0;
specmap(~isreal(specmap))=0;
h1=figure;
surf(log(Energyvec),angle(:,1),log(specmap(:,:,1)));
%surf(log(Energyvec),angle,log(specmap));
shading(gca,'interp')
%specmap(specmap<9e4)=0; %proton with calibration
%specmap(specmap<1e4)=0; %IP for H+
%specmap(specmap<1.1e4)=0; %IP for H+ with Ta in front
%specmap(specmap<2e3)=0; %IP for H+ with Ta in front
%specmap(specmap<1e4)=0; %IP for C6+
%specmap(specmap<2e4)=0; %CR39 for C6+

if 1==2
angle_i(:,1)=floor(min(angle(:,1))):0.25:ceil(max(angle(:,1))); %angle in 0.5° steps
angle_i(:,2)=interp1(angle(:,1),angle(:,2),angle_i(:,1)); %range [mm]

for a0=1:length(angle_i) % length of slit element
    if ~isnan(angle_i(a0,2))
        angle_i(a0,3)=abs(angle_i(a0,2)-angle_i(a0+1,2));
        if isnan(angle_i(a0,3))
            angle_i(a0,3)=angle_i(a0-1,3)+(angle_i(a0-1,3)-angle_i(a0-2,3));
        end
    end
end
angle_i(:,4)=angle_i(:,3)*angle(1,7); % area of slit element
angle_i(:,5)=abs(pi*(angle_i(:,2)+angle_i(:,3)).^2-pi*(angle_i(:,2)).^2); % area of disc
angle_i(:,6)=angle_i(:,4)./(angle_i(:,5)); % area of disc

fraction_i=interp1(angle_i(:,1),angle_i(:,6),angle(:,1));
fraction_i(:,2)=angle(:,5);
end

for a=1:length(specmap(:,1))
    %specmap(a,:)=specmap(a,:)./abs(fraction_i(a,1));
end
specmap(isnan(specmap))=0;
specmap(specmap<0)=0;

fid = fopen('lastpath.txt', 'wt');
fprintf(fid, '%s', pname);
fclose(fid);

if length(cut)==1
    cut(2)=cut;
end
%cut(1)=230;
%Energyvec=Energyvec(Energyvec>250);
%specmap=specmap(:,1:length(Energyvec));
%cut(2)=59;
ch=get(h1,'Children');
set(ch,'View',[50 50])
%create 3d surf plot
h2=figure;
%angle=abs(angle-16);
%specmap=specmap*1e2;
%angle=-(angle-16.6+1.7378);
surf(log(Energyvec),angle(:,1),log(specmap(:,:,1)));
shading(gca,'interp')
%caxis([0.01*mean(mean(specmap)) max(max(specmap))])
if A==1
    ticks=[1.1,2,3,4,5,10,10.4,11,20:10:fix(cut(2)/10)*10];
elseif round(A)==2
    ticks=[20,30,40,50,75,100:100:fix(cut(2)/100)*100];
else
    ticks=[20,25,50,75,100:100:fix(cut(2)/100)*100];
end
set(gca,'XTick',log(ticks))
set(gca,'XTickLabel',ticks)
set(gca,'ZTick',log([10^1,10^2,10^3,10^4,10^5,10^6,10^7,10^8]))
set(gca,'ZTickLabel',{'1e1','1e2','1e3','1e4','1e5','1e6','1e7','1e8'})

econt=1;
col=0;
if econt==1
    if A==1 %set contour steps depending on species
        steps=[1.1,2,3,4,5,10,10.4,11,20:10:floor(cut(2)/10)*10];
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
        hold on
        energy=plot3(log(Energyvec(index))+0*[1:length(angle(:,1))],angle(:,1),log(specmap(:,index,1)),'linewidth',1.5,'color',[0.4 0.4 0.4]);
        hold off
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
        hold on
        plot3(log(Energyvec),angle(index,1)+0*[1:length(Energyvec)],log(specmap(index,:,1)),'linewidth',1.5,'color',[0.4 0.4 0.4])
        hold off
        end
	end           
else
end


xlabel('Energy (MeV)')
ylabel('Angle(°)')
zlabel('Counts/MeV/msr')

t=strcat(fname,' iWasp Signal')
T=title(t);
set(T,'interpreter','none')
ch=get(h2,'Children');
set(ch,'View',[50 50])
cch=colorbar;
set(cch,'Ytick',log([10^1,10^2,10^3,10^4,10^5,10^6,10^7,10^8]))
set(cch,'YTickLabel',{'1e1','1e2','1e3','1e4','1e5','1e6','1e7','1e8'})

h3=figure;
surf(log(Energyvec),angle(:,1),specmap(:,:,1));
shading(gca,'interp')
set(gca,'XTick',log(ticks))
set(gca,'XTickLabel',ticks)

econt=1;
col=0;
if econt==1
    if A==1 %set contour steps depending on species
        steps=[1.1,2,3,4,5,11,20:10:floor(cut(2)/10)*10];
    else
        steps=[30,50,100,150,200,230,300:100:floor(cut(2)/10)*10];
    end
	for contstep=steps
        if contstep<min(Energyvec) || contstep>max(Energyvec)
        else
        Ediff=sqrt((Energyvec-contstep).^2);
        [value,index]=min(Ediff);
        hold on
        energy=plot3(log(Energyvec(index))+0*[1:length(angle(:,1))],angle(:,1),(specmap(:,index,1)),'linewidth',1.5,'color',[0.4 0.4 0.4]);
        hold off
        col=col+1;
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
        plot3(log(Energyvec),angle(index,1)+0*[1:length(Energyvec)],(specmap(index,:,1)),'linewidth',1.5,'color',[0.4 0.4 0.4])
        hold off
        end
	end           
else
end

xlabel('Energy (MeV)');
ylabel('Angle(°)')
zlabel('Counts/MeV/msr');

ch=get(h3,'Children');
set(ch,'View',[50 50])
cch=colorbar;

%create 2d plot angle vs partcile numbers
figure
%semilogy(angle,conversion(:,2)'./(angle(2)-angle(1)))
xlabel('Angle(°)')
ylabel('Particles(#/°)')
%ce(:,1)=angle;
%ce(:,2)=sum(specmap')*msr;
for indexa=2:length(angle(:,1))
%ce(:,2)=conversion(:,2)'./(angle(2)-angle(1));
ce(indexa-1,1)=(angle(indexa,1)+angle(indexa-1,1))/2;
ce(indexa-1,2)=(conversion(indexa,2)+conversion(indexa-1,2))/2/(angle(indexa,1)-angle(indexa-1,1));
end
semilogy(ce(:,1),ce(:,2),'color','r','linewidth',3)
grid on
try
%semilogy(angle_old,conversion(:,2)'./(angle_old(2)-angle_old(1)),'color','g')
catch exception
    exception
end

t=strcat(fname,' iWasp Signal');
T=title(t);
set(T,'interpreter','none')
%create 2d plot angle vs average energy
figure
size(specmap(:,:,1))
size(Energyvec)
for a=1:length(specmap(:,1,1))
    pslE(a)=sum(specmap(a,:,1)*Energyvec)/sum(specmap(a,:,1));
end
plot(angle(:,1),pslE,'linewidth',3)
xlabel('Angle(°)')
ylabel('MeV');

grid on

t=strcat(fname,' iWasp Signal');
T=title(t);
set(T,'interpreter','none')
%figure
%semilogy (angle,pslE.*sum(specmap'))
%xlabel('Angle(°)')
%ylabel('MeV*particles');
figure
t=strcat(fname,' ');
T=title(t);
set(T,'interpreter','none')
for a=1:length(contour(:,1))
    hold on
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
    end
        
    plot(contourA(a,:),log(contour(a,:)),'color',c)
    text(contourA(a,length(contourA(a,:))),log(contour(a,length(contour(a,:)))),num2str(contourE(a)),'color',c,'fontsize',18)
    hold off
end
xlabel('Angle(°)')
ylabel('PSL/MeV/msr at constant Energy')

set(gca,'Ytick',log([10^1,10^2,10^3,10^4,10^5,10^6,10^7,10^8]))
set(gca,'YTickLabel',{'1e1','1e2','1e3','1e4','1e5','1e6','1e7','1e8'})

%try
    mina=find(angle(:,1)>=-0);
    mina=mina(1);
    maxa=find(angle(:,1)<=20);
    maxa=maxa(length(maxa));
    openangle=20;
    length(angle(:,1));
    length(conversion);

    solidangle=2*pi*t_ph*1e3*openangle/360*diam*1e3/(t_ph*1e3)^2*1e3; %solid angle of slit [msr]
    solidangle_rotated=4*pi*sin(2*openangle*2*pi/360/4)^2*1e3; %solid angle if slit is rotated by 360° [msr]
    
    CE=sum(conversion(mina:maxa,1))*solidangle_rotated/solidangle/80*100
    try
    CE_polar=sum(conversion(mina:maxa,1)./abs(angle(mina:maxa,5)))/80*100
    end
    particles=sum(conversion(mina:maxa,2));
    particles_total=sum(conversion(mina:maxa,2))*solidangle_rotated/solidangle;
    %CE=sum(conversion(:,1))*solidangle_rotated/solidangle/80*100;
    %particles=sum(conversion(:,2))*solidangle_rotated/solidangle;
    for a=mina:maxa
        pslE(a)=sum(specmap(a,:,1)*Energyvec)/sum(specmap(a,:,1));
    end    
    %pslE(isnan(pslE))=50;
    avgE=mean(pslE(~isnan(pslE)));
    
%catch exception
%    exception
%    CE=0;
%end

Message(1,1)={'Particles iWASP/Full:'};
Message(2,1)={[num2str(particles,'%10.2e'),' / ',num2str(particles_total,'%10.2e')]};
Message(1,2)={'CE:'};
Message(2,2)={[num2str(CE,'%2.2f'),'%']};                                                                                       
Message(1,3)={'Angle:'};
Message(2,3)={[num2str(openangle,'%2.2f'),'°']};
Message(1,4)={'Solid angle iWASP/Full:'};
Message(2,4)={[num2str(solidangle,'%2.2f'),' / ', num2str(solidangle_rotated,'%2.2f')]};
Message(3,1)={'Average Energy:'};
Message(4,1)={num2str(avgE,'%2.2f')};
Message
global copy

try
copy(1,1)=round(avgE*10)/10;
copy(1,2)=particles; %in iWASP in PSL
copy(1,3)=particles_total; %Particles total areal
copy(1,4)=sum(conversion(mina:maxa,2)./abs(angle(mina:maxa,5))); %Particles total polar
copy(1,5)=sum(conversion(mina:maxa,4)./abs(angle(mina:maxa,5))); %Particles total polar calibtration #1
copy(1,6)=sum(conversion(mina:maxa,6)./abs(angle(mina:maxa,5))); %Particles total polar calibtration #2
copy(1,7)=(copy(1,5)+copy(1,6))/2;
copy(1,8)=copy(1,7)-copy(1,6);
copy(1,9)=round(CE*1000)/1000; % CE areal in PSL
copy(1,10)=sum(conversion(mina:maxa,1)./abs(angle(mina:maxa,5)))/80*100; %CE Polar in PSL
copy(1,11)=sum(conversion(mina:maxa,3)./abs(angle(mina:maxa,5)))/80*100; %CE Polar calibration #1
copy(1,12)=sum(conversion(mina:maxa,5)./abs(angle(mina:maxa,5)))/80*100; %CE Polar calibration #2
copy(1,13)=(copy(1,11)+copy(1,12))/2;
copy(1,14)=copy(1,13)-copy(1,12);
end

for a=1:length(angle(:,1))
     [value,index]=max(specmap(a,:,1));
     line(a,1)=angle(a,1);
     line(a,2)=Energyvec(index);
end

if 1==1
%close  3 4 5 5 6
%figure
%plot(line(:,1),line(:,2))
bfit=load('iWASP_Calibration_ho_c6+.txt');
end
figure
angle_min=0.0;
angle_max=21.0;
avg=find(angle_min<angle(:,1) & angle(:,1)<angle_max);
semilogy(Energyvec,sum(specmap(avg,:,1))./length(avg),'color','b')
title(['Average spectrum from angle ',num2str(angle_min),'° to ',num2str(angle_max),'°'])
try
hold on
semilogy(Energyvec,sum(specmap(avg,:,2))./length(avg),'color','r')
if exist('bg_specmap','var')==1
    semilogy(Energyvec,sum(bg_specmap(avg,:,1))./length(avg),'color','y') %detection threshold
    semilogy(Energyvec,sum(bg_specmap(avg,:,2))./length(avg),'color','m') %calibration #1 of background 
    semilogy(Energyvec,sum(bg_specmap(avg,:,3))./length(avg),'color','c') %calibration of raw data
    hold off
    figure
    s2nr=sum(bg_specmap(avg,:,3))./sum(bg_specmap(avg,:,2));
    plot(Energyvec,s2nr)
    grid on
    axis([min(Energyvec) max(Energyvec) 1 3])
end
hold off
end
try
clearvars -global spectra2
global spectra2
spectra2(:,1)=Energyvec;
spectra2(:,2)=sum(specmap(avg,:,1))./length(avg);
spectra2(:,3)=sum(specmap(avg,:,2))./length(avg);
spectra2(:,4)=(spectra2(:,2)+spectra2(:,3))/2;
catch exception
    exception
end

try
    specmap=spec_backup;
end
end