clc
clear all
try
    close 1 2
end

startE=35;

%material='Al'
%material='CR39'
material='Cu'

if strcmp(material,'Al')
    data=load('AlusrimC.txt');
elseif strcmp(material,'CR39')
    data=load('CR39srimC.txt');
elseif strcmp(material,'Cu')
    data=load('CusrimC.txt');
end

Ein=data(:,1)/1e3;
dEdx_el=data(:,2);
dEdx_nucl=data(:,3);
range=data(:,4);

B=0.44; %[T]
lB=0.1; %[m]
lE=lB;
D=0.3; %[m]
A=12;

trace6=tracer(0,lE,B,lB,D,6,A);
trace5=tracer(0,lE,B,lB,D,5,A);

min5=trace5(1,1);
min6=trace6(1,1);

if min5==min6
elseif min5<min6
    ind=find(trace5(:,1)==trace6(1,1));
    trace5=trace5(ind:end,:);
else
    ind=find(trace6(:,1)==trace5(1,1));
    trace6=trace6(ind:end,:);
end

dim6=size(trace6);
dim5=size(trace5);

if dim6(1)>dim5(1)
    trace6=trace6(1:dim5(1),:);
else
    trace5=trace5(1:dim6(1),:);
end

figure
plot(trace6(:,1)/1e6,trace6(:,2))
hold on
plot(trace5(:,1)/1e6,trace5(:,2))
hold off
axis([10 500 0 30])
title('Defelction as function of Energy')
ylabel('Deflection [mm]')
xlabel('Energy [MeV]')

figure
plot(trace6(:,1)/1e6,trace6(:,2)-trace5(:,2))
axis([10 500 0 10])
title('Difference in deflection for C6+ and C5+ as function of Energy')
xlabel('Energy [MeV]')
ylabel('\Delta Deflection [mm]')


Ei=trace5(:,1)/1e6;
ri = interp1(Ein,range,Ei);

filter(:,1)=trace5(:,1)/1e6; %Energy [MeV]
filter(:,2)=trace6(:,2); %C6+ B-Deflection [mm]
filter(:,3)=trace5(:,2); %C5+ B-Deflection [mm]
filter(:,4)=ri; %range in filter [microns]
filter(:,5)=(filter(:,2)-filter(:,3))/2+filter(:,3); %median filter thickness

%calulate play for filter thickness

filter_ri(:,1)=1:5000;
filter_ri(:,2)=interp1(ri,filter(:,2),filter_ri(:,1));
filter_ri(:,3)=interp1(ri,filter(:,3),filter_ri(:,1));
filter_ri(:,4)=(filter_ri(:,2)-filter_ri(:,3))/2+filter_ri(:,3); %median filter thickness
filter_ri(:,5)=(filter_ri(:,2)-filter_ri(:,3))*1/2; %position tolerance [mm]

%calulate play for filter thickness

filter_di(:,1)=1:.1:100;
filter_di(:,2)=interp1(filter(:,2),filter(:,4),filter_di(:,1));
filter_di(:,3)=interp1(filter(:,3),filter(:,4),filter_di(:,1));
filter_di(:,4)=interp1(filter(:,2),filter(:,1),filter_di(:,1));

figure
hl(1)=line(filter(:,2),filter(:,4),'color','r'); 
hold on
hl(2)=line(filter(:,3),filter(:,4),'color','b');
hl(3)=line(filter(:,5),filter(:,4),'color','black');
%hl(4)=line(filter_ri(:,4),filter_ri(:,1),'color','black');
hl(5)=line(filter_ri(:,4),filter_ri(:,5),'color','magenta'); %latteral tolerance in mm
hl(6)=line(filter_di(:,1),filter_di(:,2)-filter_di(:,3),'color','green');
ax1=gca;
hold off
axis([filter(find(trace6(:,1)==round(500*1e6)),3) filter(find(trace6(:,1)==round(10*1e6)),3) 0 100])

xticks=get(gca,'Xtick');
xlabels=get(gca,'XTicklabel');
xlims=get(gca,'XLim');
yticks=get(gca,'Ytick');
ylabels=get(gca,'YTicklabel');

legend('C^{6+} Cut','C^{5+} Cut','Filter Thickness','Latteral tolerance [mm]','Thickness tolerance')

for a=1:length(xlabels(:,1))
    ind=find(filter_di(:,1)==str2double(xlabels(a,:)))
    try
    xlabels_new(a,:)=[xlabels(a,:),' [',num2str(round(filter_di(ind,4))),'MeV]'];
    catch
        try
            xlabels_new(a,:)=[xlabels(a,:),' [0',num2str(round(filter_di(ind,4))),'MeV]'];
        catch
            try
                xlabels_new(a,:)=[xlabels(a,:),' [00',num2str(round(filter_di(ind,4))),'MeV]'];
            end
        end
    end
end

set(gca,'XtickLabel',xlabels_new)
title('Range as function of Deflection')
xlabel('Deflection [mm]')
ylabel('Range [microns]')
grid on
