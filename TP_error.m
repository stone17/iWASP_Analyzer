ph_d=(175+75+10)*1e-3; %distance pinhole detector
t_ph=1004e-3; %distance target pinhole
diam=200e-6; %pinhole diameter
s=(ph_d+t_ph)/t_ph*diam; %spotsize

B=0.63; %B-field in T
lB=75e-3; %length of B
D=175e-3; %drift after end of B

e=1.60E-19;     %[C] electron charge
mp=1.67E-27;     %[kg] nucleon mass (proton mass)
a=1;    %ion charge
A=1;    %ion mass
q=a*e;
m=A*mp;
iE=1e6:1e6:900e6;
Ek=iE*1e-6;
xp=(q*B*lB*D)./sqrt(2*m.*Ek.*e.*1e6);
xc6=(6*q*B*lB*D)./sqrt(2*12*m.*Ek.*e.*1e6);
xc5=(5*q*B*lB*D)./sqrt(2*12*m.*Ek.*e.*1e6);
xc4=(4*q*B*lB*D)./sqrt(2*12*m.*Ek.*e.*1e6);
y=2.*x.^3.*s./(x.^2-(s./2).^2).^2;  %resolution
yp=2.*s./(xp.*(1-(s./2./x).^2).^2);  %approximated resolution
yc6=2.*s./(xc6.*(1-(s./2./x).^2).^2);  %approximated resolution
yc5=2.*s./(xc5.*(1-(s./2./x).^2).^2);  %approximated resolution
yc4=2.*s./(xc4.*(1-(s./2./x).^2).^2);  %approximated resolution

plot(Ek,yp,'color','b')
hold on
plot(Ek,yc6,'color','r')
plot(Ek,yc5,'color','m')
plot(Ek,yc4,'color','c')
hold off