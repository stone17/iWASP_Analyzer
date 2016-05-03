%function [ce,CE,specmap,angle,Energyvec,solidangle,bfit]=wasp_plot(specmap,Energyvec,angle,A,cut,fname,conversion)

clear all
load files
%files=files_surf3d; %generate 3d surf plot
%files=files_surf2d;
%files=files_all;
%files=files_all_C;
files=files_surf2d_C;
if exist('lastpath.txt','file')
    fid = fopen('lastpath.txt','r');
    pname=(fread(fid,'*char'))';
    fclose(fid);
else
    pname='c:\';
end

if nargin==0 || nargin>7
    %[fname,pname]=uigetfile({'*.mat','Spectrum files'},'Select spectrum file',pname);
    try
        %file=[pname,fname];  
        %load(file)
    catch
        disp('No valid spectrum file selected')
        return
    end
else
    
end

for inda=1:length(files)
    inda
    filename=[pname,num2str(files(inda)),'_A_25mu_corrected.mat_H1+_0.44T.mat'];
    if exist(filename,'file')==0
        filename=[pname,num2str(files(inda)),'_A.img_H1+_0.44T.mat'];
        if exist(filename,'file')==0
            filename=[pname,num2str(files(inda)),'_A_25_um.mat_H1+_0.44T.mat'];
            if exist(filename,'file')==0
                filename=[pname,num2str(files(inda)),'_A_25um_corrected.mat_H1+_0.44T.mat'];
                if exist(filename,'file')==0
                    filename=[pname,num2str(files(inda)),'_filtered_44.3894x44.9683y_um.mat_C6+_0.44T.mat'];
                end
            end
        end
    end
    clear angle specmap pslE
    load(filename)
    %specmap(specmap<0)=0;
    specmap(specmap<4e4)=0;
    specmap(isnan(specmap))=0;
    fid = fopen('lastpath.txt', 'wt');
    fprintf(fid, '%s', pname);
    fclose(fid);

    if length(cut)==1
        cut(2)=cut;
    end

    %write down avg energy over all angles
    for a=1:length(specmap(:,1))
        pslE(a)=sum(specmap(a,:)*Energyvec)/sum(specmap(a,:));
    end    
    %pslE(isnan(pslE))=50;
    avgE(inda)=mean(pslE);
    
    %write down CE for specific angle region
    try
        mina=find(angle>=-0.5);
        mina=mina(1);
        maxa=find(angle<=21);
        %maxa=find(angle<=max(angle));
        maxa=maxa(length(maxa));
        openangle=0.5+21;
        length(angle);
        length(conversion);
        
        solidangle=2*pi*t_ph*1e3*openangle/360*diam*1e3/(t_ph*1e3)^2*1e3 %solid angle of slit [msr]
        solidangle_rotated=4*pi*sin(2*openangle*2*pi/360/4)^2*1e3; %solid angle if slit is rotated by 360° [msr]

        CE(inda)=sum(conversion(mina:maxa,1))*solidangle_rotated/solidangle/80*100;
        particles(inda)=sum(conversion(mina:maxa,2))*solidangle_rotated/solidangle;
    catch exception
        exception;
        CE=0;
    end

    for a=1:length(angle)
         [value,index]=max(specmap(a,:));
         line(a,1)=angle(a);
         line(a,2)=Energyvec(index);
    end
    
    %figure
    %semilogy(angle,conversion(:,2)'./(angle(2)-angle(1)))
    %xlabel('Angle(°)')
    %ylabel('Particles(#/°)')
    %ce(:,1)=angle;
    %ce(:,2)=sum(specmap')*msr;
    %ce(:,2)=conversion(:,2)'./(angle(2)-angle(1));
    
    avgpart=conversion(:,2)'/(angle(2)-angle(1));
    
    %interpolate spectra
    angle_i=-0.0:0.25:21.5;
    avgpart_i=interp1(angle,avgpart,angle_i);
 
    avg(:,inda)=avgpart_i;      
        
    %mirror spectra
    angle_im=-21.5:.25:21.5;
    for inv=1:length(angle_i-1)
        avg_m(inv,inda)=avg(length(angle_i)-inv+1,inda);
    end
    avg_m(length(angle_i):2*length(angle_i)-1,inda)=avg(:,inda);
    

    

end
    
    angle_imc=angle_im;%(:,[1:41,45:468,472:475,481:483,487:503,5010:534,538:1184,1188:1212,1219:1235,1239:1241,1247:1250,1254:1677,1681:length(angle_im)]);
    avg_m=avg_m;%([1:41,45:468,472:475,481:483,487:503,5010:534,538:1184,1188:1212,1219:1235,1239:1241,1247:1250,1254:1677,1681:length(angle_im)],:);
    hold on
    semilogy(angle_imc,avg_m)
    hold off
    xlabel('Angle(°)')
    ylabel('PSL/msr');
    legend(num2str(files(:,2)))  
   
    %generate surf plot of integrated partciles vs angle vs thickness 
    figure
    angle_icut=angle_imc;
    avg=avg_m;
    surf((files(:,2)),angle_icut,log(avg));
    cch=colorbar;
    clc
    set(cch,'Ytick',log([10^4,10^5,10^6,10^7,10^8,10^9,10^10,10^11]))
    set(cch,'YTickLabel',{'1e4','1e5','1e6','1e7','1e8','1e9','1e10','1e11'})
    set(gca,'ZTick',log([10^4,10^5,10^6,10^7,10^8,10^9,10^10,10^11]))
    set(gca,'ZTickLabel',{'1e4','1e5','1e6','1e7','1e8','1e9','1e10','1e11'})
    shading(gca,'interp')
    xlabel('Thickness (nm)');
    ylabel('Angle(°)')
    zlabel('Particles (integrated)');
    col=0;
    if 1==1
            steps=[50:50:25000];
        for contstep=steps
            if contstep<min(files(:,2)) || contstep>max(files(:,2))
            else
            Ediff=sqrt(((files(:,2))-contstep).^2);
            [value,index]=min(Ediff);
            hold on
            energy=plot3((files(index,2))+0*[1:length(angle_icut)],angle_icut,(log(avg(:,index))),'linewidth',1.5,'color',[0.4 0.4 0.4]);
            hold off
            col=col+1;
            end
        end           
    else
    end
    acont=1;
    if acont==1

        steps=-20:5:20; 
        for contstep=steps
            if contstep<min(angle_icut) || contstep>max(angle_icut)
            else
            adiff=sqrt((angle_i-contstep).^2);
            [value,index]=min(adiff);
            hold on
            plot3(files(:,2),angle_icut(index)+0*[1:length(files(:,2))],log(avg(index,:)),'linewidth',1.5,'color',[0.4 0.4 0.4])
            hold off
            end
        end           
    else
    end