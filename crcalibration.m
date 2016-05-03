%clc
%clear all
%close all

[ce,CE,specmap,angle,Energyvec,solidangle,bfit]=wasp_plot('D:\ZZ_LMU_MPQ\06 LANL Apr-2011\CR39 Data\','138_137_136_combined_44.9683x44.3894y_um.mat_C6+_0.44T.mat');
close all
[ce,CE,specmapraw,angleraw,Energyvecraw,solidangle,bfit]=wasp_plot('D:\ZZ_LMU_MPQ\06 LANL Apr-2011\CR39 raw\','136.mat_C6+_0.44T.mat');
close all

if min(Energyvec)<min(Energyvecraw)
    minE=min(Energyvec);
else
    minE=min(Energyvecraw);
end

if max(Energyvec)<max(Energyvecraw)
    maxE=max(Energyvec);
else
    maxE=max(Energyvecraw);
end


Energy_int=[round(minE):1:fix(maxE)];
for ind0=1:367;
specmap_int(ind0,:)=interp1(Energyvec,specmap(ind0,:),Energy_int);
specmapraw_int(ind0,:)=interp1(Energyvecraw,specmapraw(ind0,:),Energy_int);
end

semilogy(Energy_int,sum(specmap_int(1:367,:)),'color','b')
hold on
semilogy(Energyvec,sum(specmap(1:367,:)),'color','r')
semilogy(Energy_int,sum(specmapraw_int(1:367,:)),'color','b')
semilogy(Energyvecraw,sum(specmapraw(1:367,:)),'color','r')
hold off
calib=specmapraw_int(1:367,:)./specmap_int(1:367,:);
figure
hold on
semilogy(Energy_int,sum(calib(1:50,:))/50,'color','k')
semilogy(Energy_int,sum(calib(51:100,:))/50,'color','g')
semilogy(Energy_int,sum(calib(101:150,:))/50,'color','b')
semilogy(Energy_int,sum(calib(151:200,:))/50,'color','r')
semilogy(Energy_int,sum(calib(201:250,:))/50,'color','y')
semilogy(Energy_int,sum(calib(251:300,:))/50,'color','m')
semilogy(Energy_int,sum(calib(301:367,:))/67,'color','c')
semilogy(Energy_int,sum(calib(:,:))/367,'color',[.25 .25 .25],'linewidth',3)
hold off
set(gca,'yscale','log')
crcalib(:,1)=Energy_int;
crcalib(:,2)=sum(calib(:,:))/367;
save('cr_calibration.txt','crcalib','-ascii');
