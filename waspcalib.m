clc
clear all

[ce,CE,specmap0,angle0,Energyvec0]=wasp_plot;
close all
[ce,CE,specmap1,angle1,Energyvec1]=wasp_plot;
close all

[y,x]=size(specmap0);

for a=1:x
    specmap0_int(:,a)=interp1(angle0,specmap0(:,a),angle1);
end

[y,x]=size(specmap0_int);

for a=1:y
    specmap0_interp(a,:)=interp1(Energyvec0,specmap0_int(a,:),Energyvec1);
end

[y,x]=size(specmap0_interp);

%{
surf(log(Energyvec0),angle0,log(specmap0));
shading(gca,'interp')
figure
surf(log(Energyvec1),angle1,log(specmap0_interp));
shading(gca,'interp')
%}
diff=specmap1./specmap0_interp;
clc
avg(1:x)=0;
for a=1:round(x/1)
    index=0;
    for b=1:14;%round(y/5)
        if ~isnan(diff(b,a))
            index=index+1;
            avg(a)=avg(a)+diff(b,a);
        end
    end
    avg(a)=avg(a)/index;
end
           
plot(Energyvec1,avg)
