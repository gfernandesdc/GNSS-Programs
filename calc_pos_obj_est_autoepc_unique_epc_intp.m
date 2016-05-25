% This function receives epc (input_EPOCH) and Type_obsv (Pseudorange Type)
% that will be used by the function recpo_ls for the computation of
% receiver position from pseudoranges using ordinary
% least-squares principle. Returning on pos vector the receiver position
% in ECEF coordinates.
function [Pos_vet,Err] = calc_pos_obj_est_autoepc_unique_epc_intp(epc,Type_obsv)
% Year Month Day (Date)
    Err = [];
    EPC_s = [];
    Pos_vet = [];
%--------------------------------------------------------------------------
% Precision ECEF Position of the Object
%--------------------------------------------------------------------------
    prec_pos = [4084943.5655;-4209412.1586;-2498101.0476];
%--------------------------------------------------------------------------
% Getting epc as the Input Epoch 1
% Using the EPOCH (epc) to form the Navigation File Name!!!
%--------------------------------------------------------------------------
    inp_epoch_1 = sscanf(epc,'%d',6); % Reading epc_day
    hour_epc1  = [inp_epoch_1(1) inp_epoch_1(2) inp_epoch_1(3)...
            inp_epoch_1(4) inp_epoch_1(5) inp_epoch_1(6)];
    d2s = 24*3600; % convert day to seconds
    hour_epc1_sec   = d2s*datenum(hour_epc1); 
    epc_day_before  = (hour_epc1_sec - 86400); % day before in seconds
    date_epc_before = datevec(epc_day_before/d2s); % day before in date
    epc_day_post    = (hour_epc1_sec + 86400); % post day in seconds
    date_epc_post   = datevec(epc_day_post/d2s); % post day in date
%--------------------------------------------------------------------------
% DATE & TIME - Day before epc from Rinex Navigation files
%--------------------------------------------------------------------------
    create_rnx_nav_name_before (date_epc_before);
    fid = fopen('name_rnx_nav_before.txt');
    ofile = fgetl(fid); 
    rinexe_gf(ofile,'eph.dat');
    eph_bef = get_eph_gf('eph.dat');
%     noeph_bef = length(eph_bef);     
%--------------------------------------------------------------------------
% Making the Navigation File Name!!!
%--------------------------------------------------------------------------
    create_rnx_nav_name (hour_epc1)
    fid1 = fopen('name_rnx_nav.txt');
    ofile1 = fgetl(fid1);
    rinexe_gf(ofile1,'eph.dat');
    eph = get_eph_gf('eph.dat');
    noeph = length(eph);
%--------------------------------------------------------------------------
% DATE & TIME - Day Post from Rinex Navigation files
%--------------------------------------------------------------------------
    create_rnx_nav_name_post (date_epc_post);    
    fid2 = fopen('name_rnx_nav_post.txt');
    ofile2 = fgetl(fid2); 
    rinexe_gf(ofile2,'eph.dat');
    eph_post = get_eph_gf('eph.dat');
%     noeph_post = length(eph_post);
%--------------------------------------------------------------------------
% Creating an eph matrix with all tree days together
% Preparing to interpolate
%--------------------------------------------------------------------------
    eph_tree = [eph_bef eph eph_post];
%--------------------------------------------------------------------------
% Knowing how many SOW (seconds of week)and EPC_s (Epoch in Seconds)
% there are in the Eph (from the original Rinex Navigation File)
%--------------------------------------------------------------------------
    for i = 1 : noeph
        aux_epc = eph((22:27),i);
        hour_epc  = [aux_epc(1) aux_epc(2) aux_epc(3)...
            aux_epc(4) aux_epc(5) aux_epc(6)];
        epc_s  = d2s*datenum(hour_epc);
        EPC_s = [EPC_s epc_s];
    end
%--------------------------------------------------------------------------
    all_sow = eph(21,:);
    all_sow_unique = unique(all_sow);
    EPC_s_unique = unique(EPC_s);
%--------------------------------------------------------------------------
% Finding SOW from the inp_epoch_1 (input epc), essential to calculate
% the Estimated Object Position using recpos_ls
%--------------------------------------------------------------------------
    hour_epc1_ptr = find(EPC_s_unique==hour_epc1_sec);
    sec_of_week = all_sow_unique(hour_epc1_ptr);
    if  isempty(sec_of_week)
%--------------------------------------------------------------------------
% Auxiliary variable orig_sow to know that is no SOW of the inp_epoch_1
%--------------------------------------------------------------------------
        h_inp_epoch_1 = inp_epoch_1(4) + inp_epoch_1(5)/60 + inp_epoch_1(6)/3600;
        jd = julday((inp_epoch_1(1)+2000),inp_epoch_1(2),inp_epoch_1(3),h_inp_epoch_1);
        [day_of_week,week,sec_of_week] = gps_time(jd); % sec_of_week 
    end
    time = sec_of_week;
%--------------------------------------------------------------------------
% Obtaining Rho and the SVs numbers of visibles satellites
%--------------------------------------------------------------------------
        [obs,sats1] = find_rho_sv_nonintp_autoepc(epc,inp_epoch_1,Type_obsv);
%--------------------------------------------------------------------------
% Finding the SVs Visibles and its Eph in epc1
%--------------------------------------------------------------------------
        [EPH] = find_sv_visible(eph,sats1,all_sow_unique);
%--------------------------------------------------------------------------
% Get only Eph of the SV LOS
%--------------------------------------------------------------------------
%         sow_unit = all_sow_unique(aux_count_noeph);
        [Eph,obs,sats] = get_eph_from_EPH(EPH,time,obs,sats1);
        if isempty(Eph)
        [Eph,sats] = intp_eph_tree(sats1,eph_tree,time);    
        end
%--------------------------------------------------------------------------
%  Computation of receiver position from pseudoranges using ordinary 
%  least-squares principle, if Eph not empty
%-------------------------------------------------------------------------- 
        if ~isempty(Eph)
            [pos] = recpo_ls(obs,sats,time,Eph);
            Pos_vet = [Pos_vet pos];
            err = pos(1:3) - prec_pos;
            Err = [Err err];
        end
    fclose('all');
end


