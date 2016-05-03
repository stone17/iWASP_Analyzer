clc
clear all
close all
avg= 879.2930;

%path='D:\ZZ_LMU_MPQ\06 LANL Apr-2011\CR39 Data\';
path='D:\ZZ_LMU_MPQ\06 LANL Apr-2011\CR39_images_a\';
dims='_44.9683x44.3894y_um.mat';
index=0;
for crnum=56:57
    crnum
    if crnum<10
        file=[path,'00',num2str(crnum),'.tiff'];
    elseif crnum<100
        file=[path,'0',num2str(crnum),'.tiff'];
    elseif crnum<1000
        file=[path,num2str(crnum),'.tiff'];
    end
    
    if crnum<127 && crnum~=119 && crnum~=120 && crnum~=124 && crnum~=125
        bg=[path,'bg_1.tiff'];
    elseif crnum>126 && crnum<155 || crnum==119 || crnum==120
        bg=[path,'bg_119_120_124_125_127_af.tiff'];
    elseif crnum>154
        bg=[path,'bg_155_af.tiff'];
    end
    bg=[path,'bg_57_56.tiff'];
    try

    cr=imread(file,'tiff');
    avg_current=mean(mean(cr(1:250,:)));
    cr=double(cr(546:1650,116:2340));
    fac=double(avg/avg_current);
    cr=cr.*fac;
    
    bg_matrix=imread(bg,'tiff');
    avg_bg=mean(mean(bg_matrix(1:250,:)));
    bg_matrix=double(bg_matrix(546:1650,116:2340));
    fac=double(avg/avg_bg);
    bg_matrix=bg_matrix.*fac;
    
    cr_clean=cr-bg_matrix;
    %imagesc(cr)
    %figure
    %imagesc(cr-bg_matrix)
    
    index=index+1;
    save([file,'_corrected',dims],'cr_clean')
    catch exception
        %exception
        message=['File ',file,' does not exist!']
    end
end