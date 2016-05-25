function [SAT,sv] = int_sp3_xyz(ofile2,splint)
% INT_SP3_xyz Read new sp3 file (satellites identified by PG01, PG02,...)
%		and interpolate sat positions
%		sp3file = input orbit file (sp3 format)
%
%		For the new sp3file format
%
%		SAT = structure, for each field (= PRN), every splint sec:
%		  X (m)
%		  Y (m)
%		  Z (m)
%		sv = list of prn number present in sp3 file (vector)
%		
%		[SAT,sv] = int_sp3(sp3file, splint);
%
% message

disp(['Processing orbit file ' ofile2]);

% Earth's radius, meters
R = 6471000;

% initialize SAT structure
SAT = [];

% get list of prns from sp3 header
ofile2 = fopen(ofile2,'r');
line = fgetl(ofile2); line = fgetl(ofile2); line = fgetl(ofile2);
n_sv = sscanf(line(2:length(line)),'%d',1);

% sv1 = sscanf(line(11:length(line)),'%d'); sv = sv1(find(sv1));
deli=line(10);
[sv1]=strread(line(11:length(line)),'%f','delimiter',deli); sv = sv1(find(sv1));
line = fgetl(ofile2);
[sv2]=strread(line(11:length(line)),'%f','delimiter',deli); sv = [sv;sv2(find(sv2))];

% for each satellite
for i=1:length(sv)

    % read sp3 file for satellite sv
   [Xs,Ys,Zs,Ts] = read_sp3_new(ofile2,sv(i));
   if (~isempty(find(Xs)))
    
      % convert sp3 to meters
      Xs = Xs.*1000;
      Ys = Ys.*1000;
      Zs = Zs.*1000;

      % interpolate
      Ti = 0:splint:24*3600;
      Xi = interp1(Ts,Xs,Ti,'PCHIP');
      Yi = interp1(Ts,Ys,Ti,'PCHIP');
      Zi = interp1(Ts,Zs,Ti,'PCHIP');

      % convert time to hours
      T = Ti / 3600;

      % matrix of satellite positions (ECEF, meters)
      S = [Xs Ys Zs];

      % fill out SAT structure
      sat_tmp = [T;Xi;Yi;Zi];
      field = ['PRN' num2str(sv(i))];
      SAT = setfield(SAT,field,sat_tmp);
   end
end
fclose(ofile2);
end


