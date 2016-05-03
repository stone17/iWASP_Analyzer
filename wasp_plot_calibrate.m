%function [ce,CE,specmap,angle,Energyvec,solidangle,bfit,conversion]=wasp_plot(pname,fname,specmap,Energyvec,angle,A,cut,conversion,msr,diam,t_ph)
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

if nargin==0 || nargin>11
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
    specmap=specmap(:,:,1);
catch exception
    exception
end

%specmap(specmap<9e5)=0; %CR39 jpg
%specmap(specmap<4e4)=0; %IP for H+
%specmap(specmap<1e4)=0; %IP for C6+
specmap(specmap<1e1)=0; %CR39 for C6+
specmap(isnan(specmap))=0;

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

%create 3d surf plot
figure
%angle=abs(angle-16);
%specmap=specmap*1e2;
%angle=-(angle-16.6+1.7378);
surf(log(Energyvec),angle(:,1),log(specmap));
shading(gca,'interp')
%caxis([0.01*mean(mean(specmap)) max(max(specmap))])
if A==1
    ticks=[1.1,2,3,4,5,10,10.4,11,20:10:fix(cut(2)/10)*10];
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
        steps=[1.1,2,3,4,5,10,10.4,11,20:10:floor(cut(2)/10)*10];
    else
        steps=[20,50,100,150,200,230,300:100:floor(cut(2)/10)*10];
    end
	for contstep=steps
        if contstep<min(Energyvec) || contstep>max(Energyvec)
        else
        Ediff=sqrt((Energyvec-contstep).^2);
        [value,index]=min(Ediff);
        hold on
        energy=plot3(log(Energyvec(index))+0*[1:length(angle(:,1))],angle(:,1),log(specmap(:,index)),'linewidth',1.5,'color',[0.4 0.4 0.4]);
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

t=strcat(fname,' iWasp Signal');
T=title(t);
set(T,'interpreter','none')

figure
surf(log(Energyvec),angle(:,1),specmap);
shading(gca,'interp')
set(gca,'XTick',log(ticks))
set(gca,'XTickLabel',ticks)

cch=colorbar;


econt=1;
col=0;
if econt==1
    if A==1 %set contour steps depending on species
        steps=[1.1,2,3,4,5,11,20:10:floor(cut(2)/10)*10];
    else
        steps=[20,50,100,150,200,230,300:100:floor(cut(2)/10)*10];
    end
	for contstep=steps
        if contstep<min(Energyvec) || contstep>max(Energyvec)
        else
        Ediff=sqrt((Energyvec-contstep).^2);
        [value,index]=min(Ediff);
        hold on
        energy=plot3(log(Energyvec(index))+0*[1:length(angle(:,1))],angle(:,1),(specmap(:,index)),'linewidth',1.5,'color',[0.4 0.4 0.4]);
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
        plot3(log(Energyvec),angle(index,1)+0*[1:length(Energyvec)],(specmap(index,:)),'linewidth',1.5,'color',[0.4 0.4 0.4])
        hold off
        end
	end           
else
end

xlabel('Energy (MeV)');
ylabel('Angle(°)')
zlabel('Counts/MeV/msr');


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
size(specmap)
size(Energyvec)
for a=1:length(specmap(:,1))
    pslE(a)=sum(specmap(a,:)*Energyvec)/sum(specmap(a,:));
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

try
    mina=find(angle(:,1)>=-0);
    mina=mina(1);
    maxa=find(angle(:,1)<=21);
    maxa=maxa(length(maxa));
    openangle=24.5;
    length(angle(:,1));
    length(conversion);

    solidangle=2*pi*t_ph*1e3*openangle/360*diam*1e3/(t_ph*1e3)^2*1e3; %solid angle of slit [msr]
    solidangle_rotated=4*pi*sin(2*openangle*2*pi/360/4)^2*1e3 %solid angle if slit is rotated by 360° [msr]
    
    CE=sum(conversion(mina:maxa,1))*solidangle_rotated/solidangle/80*100;
    particles=sum(conversion(mina:maxa,2))*solidangle_rotated/solidangle;
    CE=sum(conversion(:,1))*solidangle_rotated/solidangle/80*100;
    particles=sum(conversion(:,2))*solidangle_rotated/solidangle;
catch exception
    exception;
    CE=0;
end

for a=1:length(angle(:,1))
     [value,index]=max(specmap(a,:));
     line(a,1)=angle(a,1);
     line(a,2)=Energyvec(index);
end

if 1==1
close 2 3 4 5 
figure
line(:,1)=line(:,1).*10;
plot(line(:,1),line(:,2))
bfit=load('iWASP_Calibration_22461.txt');
%manual way to iterate
n=1
if n==1
    f = fittype('a*x+b');
    [c,gof] = fit(line(:,1),line(:,2),f,'Startpoint',[1,1]);
    correct=c.a.*bfit(:,1)+c.b;
elseif n==2
    f = fittype('a*x^2+b*x+c');
    [c,gof] = fit(line(:,1),line(:,2),f,'Startpoint',[1,1,1]);
    correct=c.a.*bfit(:,1).^2+c.b.*bfit(:,1)+c.c;
elseif n==3
    f = fittype('a*x^3+b*x^2+c*x+d');
    [c,gof] = fit(line(:,1),line(:,2),f,'Startpoint',[1,1,1,1]);
    correct=c.a.*bfit(:,1).^2+c.b.*bfit(:,1)+c.c*bfit(:,1)+c.d;
end
hold on
plot(c)
%{
correct=fit.coeff(1).*bfit(:,1)+fit.coeff(2);
correct=fit.coeff(1).*bfit(:,1).^2+fit.coeff(2).*bfit(:,1)+fit.coeff(3);
correct=fit.coeff(1).*bfit(:,1).^3+fit.coeff(2).*bfit(:,1).^2+fit.coeff(3).*bfit(:,1)+fit.coeff(4);
correct=fit.coeff(1).*bfit(:,1).^4+fit.coeff(2).*bfit(:,1).^3+fit.coeff(3).*bfit(:,1).^2+fit.coeff(4).*bfit(:,1)+fit.coeff(5);
correct=fit.coeff(1).*bfit(:,1).^5+fit.coeff(2).*bfit(:,1).^4+fit.coeff(3).*bfit(:,1).^3+fit.coeff(4).*bfit(:,1).^2+fit.coeff(5).*bfit(:,1)+fit.coeff(6);
correct=fit.coeff(1).*bfit(:,1).^6+fit.coeff(2).*bfit(:,1).^5+fit.coeff(3).*bfit(:,1).^4+fit.coeff(4).*bfit(:,1).^3+fit.coeff(5).*bfit(:,1).^2+fit.coeff(6).*bfit(:,1)+fit.coeff(7);
%}
bfit(:,3)=bfit(:,2).*sqrt(10.5./correct(:));

figure
plot(bfit(:,1),bfit(:,2),'color','r')
hold on
plot(bfit(:,1),bfit(:,3),'color','b')
hold off

if 1==2
    bfit(:,2)=bfit(:,3);
    bfit=bfit(:,1:2);
    save(['iWASP_Calibration_vert_new.txt'],'bfit','-ascii')
end
end