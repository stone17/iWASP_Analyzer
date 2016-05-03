function splsorted=sortspline(splx,sply,incx,incy)
splxi=interp(splx,1000);
splyi=interp(sply,1000);

%plot(splx,sply)

for a=1:length(splxi)
    splxi(a)=round(splxi(a)/incx)*incx;
    splyi(a)=round(splyi(a)/incy)*incy;
end

spli(:,1)=splxi;
spli(:,2)=splyi;
spli=sortrows(spli);
index=0;
for a=2:length(spli(:,1))
    if spli(a,1)==spli(a-1,1) && spli(a,2)==spli(a-1,2)
    else
        index=index+1;
        splsorted(index,1)=spli(a,1);
        splsorted(index,2)=spli(a,2);
    end
end

%hold on
%plot(spli_c(:,1),spli_c(:,2),'x')
%hold off
end