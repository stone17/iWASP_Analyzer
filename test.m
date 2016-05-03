clear all
clc

load test
splxi=[];
splyi=[];
for a=1:length(splx)-1
    intx=splx(a):((splx(a+1)-splx(a)))/100:splx(a+1);
    splxi(length(splxi)+1:length(splxi)+length(intx),1)=intx;
    inty=sply(a):((sply(a+1)-sply(a)))/100:sply(a+1);
    splyi(length(splyi)+1:length(splyi)+length(inty),1)=inty;
    clear intx inty
end

    