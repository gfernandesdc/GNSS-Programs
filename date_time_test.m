function [week,sec_of_week] =  date_time_test(epc)
%--------------------------------------------------------------------------
% Preparing the Output day_of_week, week and time
%--------------------------------------------------------------------------
    ss  = epoch2date(epc);
    EPC = zeros(1,6);
    EPC(1) = str2double(ss(1:4));
    EPC(2) = str2double(ss(6:7));
    EPC(3) = str2double(ss(9:10));
    EPC(4) = str2double(ss(12:13));
    EPC(5) = str2double(ss(15:16));
    EPC(6) = str2double(ss(18:19));
    h_loop = EPC(4) + EPC(5)/60 + EPC(6)/3600;
    jd = julday((EPC(1)+2000),EPC(2),EPC(3),h_loop);
    [week,sec_of_week] = gps_time(jd); % sec_of_week   
end