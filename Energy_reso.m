%reso=load('TP_Resolution iWASP H+.txt','-ascii');

reso=load('TP_Resolution iWASP C6+.txt','-ascii');

emax=round(emax);


emax(:,2)=reso(emax(:,1),2);
