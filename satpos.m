function satp = satpos(t,eph)
%SATPOS   Calculation of X,Y,Z coordinates at time t
%                   for given ephemeris eph

%Kai Borre 04-09-96
%Copyright (c) by Kai Borre
%$Revision: 1.1 $  $Date: 2004/02/09  $

GM = 3.986005e14;             % earth's universal gravitational
% parameter m^3/s^2
Omegae_dot = 7.2921151467e-5; % earth rotation rate, rad/s

%  Units are either seconds, meters, or radians
%  Assigning the local variables to eph
af2     =  eph(1);
M0      =  eph(2);
roota   =  eph(3);
deltan  =  eph(4);
ecc     =  eph(5);
omega   =  eph(6);
cuc     =  eph(7);
cus     =  eph(8);
crc     =  eph(9);
crs     =  eph(10);
i0      =  eph(11);
idot    =  eph(12);
cic     =  eph(13);
cis     =  eph(14);
Omega0  =  eph(15);
Omegadot=  eph(16);
toe     =  eph(17);
af0     =  eph(18);
af1     =  eph(19);
toc     =  eph(20);

% Procedure for coordinate calculation
A = roota*roota;
tk = check_t(t-toe);
n0 = sqrt(GM/A^3);
n = n0+deltan;
M = M0+n*tk;
M = rem(M+2*pi,2*pi);
E = M;
for i = 1:10
   E_old = E;
   E = M+ecc*sin(E);
   dE = rem(E-E_old,2*pi);
   if abs(dE) < 1.e-12
      break;
   end
end
E = rem(E+2*pi,2*pi);
v = atan2(sqrt(1-ecc^2)*sin(E), cos(E)-ecc);
phi = v+omega;
phi = rem(phi,2*pi);
u = phi              + cuc*cos(2*phi)+cus*sin(2*phi);
r = A*(1-ecc*cos(E)) + crc*cos(2*phi)+crs*sin(2*phi);
i = i0+idot*tk       + cic*cos(2*phi)+cis*sin(2*phi);
Omega = Omega0+(Omegadot-Omegae_dot)*tk-Omegae_dot*toe;
Omega = rem(Omega+2*pi,2*pi);
x1 = cos(u)*r;
y1 = sin(u)*r;
satp(1,1) = x1*cos(Omega)-y1*cos(i)*sin(Omega);
satp(2,1) = x1*sin(Omega)+y1*cos(i)*cos(Omega);
satp(3,1) = y1*sin(i);
%%%%%%%%% end satpos.m %%%%%%%%%
