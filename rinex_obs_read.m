function REG_COUNT = rinex_obs_read(filename)
    global id
    conn = database('rinex','postgres','123456',...
                    'Vendor','PostgreSQL',...
                    'Server','localhost');
%                
%  Get satellite names
%
    [~,SV_Table]        = GetSatelliteNames(conn);
    [nBT,Band_Table]    = GetBandNames(conn);
    [nST,Station_Table] = GetStationNames(conn);
%--------------------------------------------------------------------------
% Reading the filename
%--------------------------------------------------------------------------
    [fid,S,error] = rd_rnx_header(filename);
    if error > 0
        return;
    end   
%--------------------------------------------------------------------------
% Connecting to the database
%--------------------------------------------------------------------------
%     q2 = ('select max(id) from observation');
%     curs = exec(conn, q2);
%     curs = fetch(curs);
%     id = curs.Data;
%     if isnan(id{1,1})
%         id = 1;
%     else
%         id = id{1,1} + 1;
%     end
%--------------------------------------------------------------------------
% Printing parameters received from the function rd_rnx_header.
%-------------------------------------------------------------------------- 
    fprintf(1,'\n\tThis Rinex Observation File is: %s\n',S.TYPE_SV);
    fprintf(1,'\tThe Marker Name is: %s\n',S.MK_NAME);
    fprintf(1,'\tThe Observation Agency is: %s\n',S.OBSV_AG);
    fprintf(1,'\tAPP RCV location XYZ is: %14.4f  %14.4f  %14.4f\n'...
             ,S.REC_XYZ);
    Num_Band = length(S.TObs);
    fprintf(1,'\tType_Obsv: ');
    fprintf(1,'   %s',S.TObs{1:Num_Band});
    fprintf(1,'\n\n');
%--------------------------------------------------------------------------
    [~,name,~] = fileparts(filename);
    stationName = name(1:4);
    for k=1:nST
        if strcmp(Station_Table(k),stationName)
            break;
        end
    end
    if k>nST
        fprintf(1,'\tERRO STATION\n');
        return;
    end
    stationId = k;
    bloco = 0; 
    REG_COUNT = 0;
    fprintf(1,'\tBLOCO        ');
    while true
        if bloco >= 10    % PARA DEBUG
            break;        % PARA DEBUG
        end               % PARA DEBUG
        buffer = fgetl(fid);  
        if buffer == -1
            break
        end;
        bloco = bloco + 1;
        fprintf(1,'\b\b\b\b\b\b%6d',bloco);
        epoch  = sscanf(buffer,'%f',[1,6]);
%--------------------------------------------------------------------------
% Testing if the first line is empty, to remove the lines between the
% changing hours 59 Minutes and 59 Seconds.
%--------------------------------------------------------------------------    
        if length(epoch) ~= 6
            for k=1:5
                buffer = fgetl(fid);
            end
            epoch  = sscanf(buffer,'%f',[1,6]);
        end
%--------------------------------------------------------------------------
% Loading the numbers of SV (Space Vehicle) - GPS, GLONASS and GALILEO.
%--------------------------------------------------------------------------
        Num_SVs = str2double(buffer(31:32));
        TS  = cell(Num_SVs,1);
        for k=1:Num_SVs
            if k<=12
                inic = 3*k+30;
            elseif k<=24
                inic = 3*k-6;
            else
                inic = 3*k-42;
            end
            if k == 13
               buffer = fgetl(fid);
            elseif k == 25
               buffer = fgetl(fid);
            end
            TS{k} = buffer(inic:inic+2);
        end         
 %-------------------------------------------------------------------------
        SVs_rhos = zeros(Num_SVs,Num_Band);
        for k=1:Num_SVs           
            rr = READ_RHO(Num_Band,fid);
            SVs_rhos(k,:) = rr(:,1);
        end
%--------------------------------------------------------------------------               
%   Inserção no banco de dados
%--------------------------------------------------------------------------   
        for m=1:Num_SVs
            satelliteId = GetSatelliteId(TS{m},SV_Table);
            datum = zeros(nBT,1);
            for n=1:Num_Band
                bandId = GetBandId(S.TObs{n},Band_Table);
                datum(bandId) = SVs_rhos(m,n);
            end
            Insert_In_OBS_Database(conn, id,satelliteId,stationId,...
                                         epoch,datum);
            id = id + 1;
        end
        REG_COUNT = REG_COUNT + Num_SVs;
    end
%==========================================================================
    function r = READ_RHO(n,fid)
        r = zeros(n,2);
        for kk=1:n
            idx = 1+mod(kk-1,5);
            if idx == 1
                BUFFER = fgetl(fid);
            end
            nn = 16*idx;
            if nn<=length(BUFFER)
                temp = str2double(BUFFER(nn-14:nn-2));
                if ~isnan(temp)
                    r(kk,1) = temp;
                    r(kk,2) = str2double(BUFFER(nn));
                end
            end
        end
    end
%==========================================================================
    close(conn);
end
