clc
clear all
close all

num1=22372;
cr1='138';
cr2='137';
cr3='136';

path='D:\ZZ_LMU_MPQ\06 LANL Apr-2011\CR39 Data\';
dims='_44.9683x44.3894y_um.mat';

file1=[cr1,'.tiff_corrected',dims];
file2=[cr2,'.tiff_corrected',dims];

part1=load([path,file1]);
part1=rot90(rot90(cell2mat(struct2cell(part1))))';

part2=load([path,file2]);
part2=3.5/5*rot90(rot90(cell2mat(struct2cell(part2))'));

size1=size(part1);
size2=size(part2);


if size1(1,1)<size2(1,1)
    ymax=size2(1,1);
else
    ymax=size1(1,1);
end

if size1(1,2)<size2(1,2)
    xmax=size2(1,2);
else
    xmax=size1(1,2);
end

if ~isempty(cr3)
    file3=[cr3,'.tiff_corrected',dims];
    part3=load([path,file3]);
    part3=rot90(rot90(cell2mat(struct2cell(part3))'));
    size3=size(part3);
end

xmax;
ymax;
%combined=zeros(size1(1,1)+size2(1,1)+1,xmax);

%{
%22131 a=7,   b=3, c=1,   d=9
%22132 a=1,   b=3, c=14,  d=8
%22133 a=1,   b=9, c=1,   d=8
%22138 a=5,   b=1, c=1,   d=10
%22140 a=1,   b=2, c=6,   d=8
%22142 a=127, b=2, c=1,   d=8
%}

%012_011 b=1, c=10, d=1, a=1
%015_014 b=18, c=10, d=9, a=1
%018_017 b=18, c=10, d=9, a=1
%021_020 b=14, c=14, d=7, a=1
%024_023 b=14, c=3, d=7, a=1
%027_026 b=14, c=5, d=7, a=1
%030_029 b=14, c=5, d=7, a=1
%033_032 b=14, c=12, d=7, a=1
%036_035 b=14, c=1, d=7, a=1
%042_041 b=14, c=10, d=7, a=1
%048_047 b=14, c=5, d=7, a=1
%054_053 b=14, c=13, d=7, a=1
%057_056 b=14, c=1, d=7, a=1
%066_065 b=14, c=1, d=7, a=1
%072_071 b=14, c=12, d=7, a=1
%075_074 b=14, c=12, d=7, a=1

%078_077_076 g=4, b=14, c=12, d=7, a=1, e=11, f=23
%081_080_079 g=8, b=14, c=15, d=7, a=15, e=13, f=1
%090_089_088 g=7, b=14, c=1, d=7, a=12, e=14, f=11
%093_092_091 g=7, b=14, c=2, d=7, a=1, e=14, f=12
%096_095_094 g=7, b=14, c=2, d=7, a=12, e=14, f=5
%099_098_097 g=7, b=14, c=1, d=7, a=30, e=14, f=1
%102_101_100 g=7, b=14, c=1, d=7, a=5, e=14, f=13
%105_104_103 g=7, b=14, c=16, d=7, a=24, e=14, f=1
%108_107_106 g=-, b=14, c=1, d=7, a=12, e=-, f=-
%114_113_112 g=7, b=14, c=1, d=7, a=15, e=14, f=1
%117_116_115 g=7, b=14, c=1, d=7, a=15, e=14, f=1
%120_119_118 g=7, b=14, c=7, d=7, a=26, e=14, f=1
%123_122_121 g=7, b=14, c=7, d=7, a=26, e=14, f=1
%129_128_127 g=7, b=14, c=11, d=7, a=1, e=14, f=17
%135_134_133 g=7, b=14, c=1, d=7, a=11, e=14, f=4
%138_137_136 g=7, b=14, c=1, d=7, a=11, e=14, f=4
%141_140_139 g=7, b=14, c=7, d=7, a=12, e=14, f=1
%144_143_142 g=7, b=14, c=1, d=7, a=11, e=14, f=4
%147_146_145 g=7, b=14, c=3, d=7, a=1, e=-, f=-
%147_146_145 g=1, b=14, c=5, d=7, a=1, e=-, f=-

%top image
g=7; %cut top of image
b=14; %cut bottom of image
c=5; %shift to the right

%bottom image
d=7; %cut top of image
a=12; %shift image to the right

%image over top
e=14; %cut bottom of image
f=1; %shift to the right

%bottom image
combined(1:size1(1,1)-d,a:size1(1,2)+a-1)=part1(1:size1(1,1)-d,:);
%top image
combined(size1(1,1)+1-d:size1(1,1)-d+size2(1,1)-(b+g),c:size2(1,2)+c-1)=part2(b+1:size2(1,1)-g,:);

%image over top
if ~isempty(cr3)
    hight2=size1(1,1)-d+size2(1,1)-(b+g)+1;
    combined(hight2:hight2+size3(1,1)-e,f:size2(1,2)+f-1)=part3(e:size3(1,1),:);
end

combined(combined<1)=1;
imagesc(combined)
hold on
plot([0:size1(1,2)+a-1],[0:size1(1,2)+a-1]*0+size1(1,1)-d,'linewidth',1,'color','w')
if ~isempty(cr3)
    plot([0:size1(1,2)+a-1],[0:size1(1,2)+a-1]*0+hight2,'linewidth',1,'color','w')
end
hold off
caxis([10 5*mean(mean(combined))])
axis xy

if ~isempty(cr3)
    combined=rot90(rot90(rot90(combined)'));
    save([path,cr1,'_',cr2,'_',cr3,'_combined',dims],'combined')
else
    save([path,cr1,'_',cr2,'_combined',dims],'combined')
end