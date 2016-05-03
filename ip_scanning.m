function fac=ip_scanning
if exist('lastpath.txt','file')
	fid = fopen('lastpath.txt','r');
	pname=(fread(fid,'*char'))';
	fclose(fid);
else
	pname='c:\';
end

[Matrix,incx,incy,fname,pname]=loadasf(pname);
if fname==0
    fac=1;
else
m=figure;
imagesc(Matrix)
rect=getrect;
dim=size(Matrix);
if rect(1)<1
    rect(1)=1;
end
if rect(2)<1
    rect(2)=1;
end
if rect(1)+rect(3)>dim(2)
    rect(3)=dim(2)-rect(1);
end
if rect(2)+rect(4)>dim(1)
    rect(4)=dim(1)-rect(2);
end
%rect=[xmin ymin width height]
scan(:,:,1)=Matrix(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3));
close(m)
clear Matrix incx incy 

error=0;
run=1;
while error==0
    run=run+1;
    fname_new=[fname(1:7),num2str(run-1),fname(8:length(fname))]
    try
        [Matrix,incx,incy,fn,pname]=loadasf(pname,fname_new);
        scan(:,:,run)=Matrix(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3));
        clear Matrix incx incy
    catch
        fname_new=[fname(1:end-4),['0'],num2str(run-1),fname(end-3:end)]
        try
            [Matrix,incx,incy,fn,pname]=loadasf(pname,fname_new);
            scan(:,:,run)=Matrix(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3));
            clear Matrix incx incy
        catch
            fname_new=[fname(1:end-5),num2str(run),fname(end-3:end)]
            try
                [Matrix,incx,incy,fn,pname]=loadasf(pname,fname_new);
                scan(:,:,run)=Matrix(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3));
                clear Matrix incx incy
            catch
                error=1;    
            end
        end
    end
end

for a=1:run-2
    fac(a)=mean(mean(scan(:,:,a+1)./scan(:,:,a)));
end
figure
title(pname)
hold on
plot(fac)
hold off
f=mean(mean(scan(:,:,a+1)./scan(:,:,1)))
figure
title(pname)
avg=mean(mean(scan(:,:,1:run-1)));
av(1:run-1)=avg(1,1,:);
plot(av)

if exist('lastpath.txt','file')
	fid = fopen('lastpath.txt','r');
	pname=(fread(fid,'*char'))';
	fclose(fid);
else
	pname='c:\';
end
clear scan
[Matrix,incx,incy,fname,pname]=loadasf(pname);
Matrix=Matrix./f;
inc=num2str(incx);
filename=[pname,fname(1:length(fname)),'_',inc,'mu','_corrected.mat']
uisave('Matrix',filename)
end
end