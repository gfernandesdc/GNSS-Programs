function [XYZ] = calc_sv_pos(epoca,tobs)
    SV_Names = Find_Visible_SVs(epoca,tobs);
    for k=1:length(SV_Names)
        [Xsv,Ysv,Zsv] = Eval_SV_Pos(epoca,SV_Names(k));
    end
    
% Kai Borre 31-10-2001
% Copyright (c) by Kai Borre
% $Revision: 1.0 $  $Date: 2001/10/31  $
% Read RINEX ephemerides file and convert to
% internal Matlab format
% eph = zeros(425,22);
rinexe_gf('sjsp0101.14n','eph.dat');
Eph = get_eph_gf('eph.dat');
noeph = length(Eph);
%--------------------------------------------------------------------------
% Input Epoch
%--------------------------------------------------------------------------
inp_epoch= sscanf(epc,'%d',6);
inp_DATE = inp_epoch(1)*10000+inp_epoch(2)*100+inp_epoch(3);
inp_TIME = inp_epoch(4)*10000+inp_epoch(5)*100+inp_epoch(6);
inp_EPOCH = inp_DATE * 1000000 + inp_TIME;
%--------------------------------------------------------------------------
% Input SV
%--------------------------------------------------------------------------
% We look for inp_sv in Eph and write a new inp_sv_Eph vector
% containing only inp_sv Epochs and prepare nav_sv_Eph and
% nav_sv_Eph_aux.
[Eph_SV_asc] = nav_SV_in_order(noeph,Eph);
out_sv = find(Eph_SV_asc(:,1)==sv);
nav_sv_EPOCH_aux = Eph_SV_asc(out_sv,22);
nav_sv_Eph = Eph_SV_asc(out_sv,(2:21));
%-------------------------------------------------------------------------- 
% Localize the inp_EPOCH in nav_EPOCH or interpolate it!!!
%--------------------------------------------------------------------------
for i = 1 : length(out_sv)
    if inp_EPOCH == nav_sv_EPOCH_aux(i,1) 
        fprintf(1,'%s\n','nav_EPOCH and inp_EPOCH ==');
        nav_sv_Eph_nonintp = nav_sv_Eph(i,:);
        eph((1:21),1) = [sv,nav_sv_Eph_nonintp];
    break
    else fprintf(1,'%s\n','nav_EPOCH and inp_EPOCH ~= interpolate');   
         nav_sv_Eph_intp = interp1(nav_sv_EPOCH_aux(:,:),nav_sv_Eph(:,:),inp_EPOCH);
         eph((1:21),1) = [sv,nav_sv_Eph_intp];
         if isnan(eph((2:21),:))
         fprintf(1,'%s\n','SV with no Ephemeris'); 
         fprintf(1,'%s\n','Choose another SV');
         return
         end    
    break
    end
end
%--------------------------------------------------------------------------
% Identify the Rinex Obsv file and open it!
%--------------------------------------------------------------------------
% Valid, only, for years after 2000
%--------------------------------------------------------------------------
% Calculation of the positions of the inp_EPOCH SV 
%--------------------------------------------------------------------------
h = inp_epoch(4) + inp_epoch(5)/60 + inp_epoch(6)/3600;
jd = julday((inp_epoch(1)+2000),inp_epoch(2),inp_epoch(3),h);
[day_of_week,week,sow] = gps_time(jd); % sec_of_week - seconds of week (de 0 a 604.800)
sat(1:3) = satpos(sow,eph); % Coordinates ECEF of SV for input EPC
fprintf(1,'%14.3f %14.3f %14.3f\n',sat);
XYZ = sat(1:3);  
end