function [POS,Err_POS] = GEN_POS_STATION_test(stationId,from_date,to_date,...
    time_unit,bandId)
%
%  Determina a posição da estação definida "station", no intervalo de
%  tempo compreendido entre "from_date" e "to_date" com discretização
%  temporal de "time_unit" (expresso em segundos) usando informação de uma 
%  "banda" particular.
%
    conn = database('rinex','postgres','123456',...
                    'Vendor','PostgreSQL',...
                    'Server','localhost');

    epoca1   = date2epoch(from_date);
    epoca2   = date2epoch(to_date);
    nEPC     = round(epoca2-epoca1)/600;
    
    POS      = zeros(4,nEPC);
    Err_POS  = zeros(3,nEPC);
%     GDOP_ALL = zeros(nEPC,1);
    
    epc_count= 0; % auxiliary variable to debug 
    for t = epoca1:time_unit:epoca2
        epc_count = epc_count + 1;
        [sVEPHO,svidO,svpdistO] = Find_Visible_SVs(conn,t,bandId,stationId);
         
        [sVEPHO,svidO,svpdistO] = zero_elim (sVEPHO,svidO,svpdistO);
        
        [sow] = date_time_conv(t);
        Eph = sVEPHO';
        [pos, El, GDOP, basic_obs] = rec_pos_ls(svpdistO,sow,Eph);
        
        POS(:,epc_count) = pos;
        pos_st5 = [4077724.8412;-4216210.5918;-2498409.9958];
        err_pos = (minus(pos(1:3),pos_st5)./pos_st5)*100;
        Err_POS(:,epc_count) = err_pos;
        
%         El_all (epc_count,:) = El;
%         GDOP_ALL (epc_count) = GDOP;
%         BASIC_OBS = [BASIC_OBS basic_obs];
%         BASIC_OBS(:,:,epc_count,:) = basic_obs;
    end
end
%--------------------------------------------------------------------------
function [sVEPHO,svidO,svpdistO] = Find_Visible_SVs(conn,t,bandId,stationId)
%
%  Calcula a lista de satélites existentes no momento "t" para uma 
%  determinada "station". Retorna a lista de nomes de satélites "svname" e 
%  suas pseudo distâncias a estação "station"
%
    [SVID,SVTIME,SVPDIST] = Get_Observations(conn,bandId,stationId,t,3);
    if isempty(SVID)
        return;
    end
    
    svidO  = unique(SVID);
    nO = length(svidO);
    svpdistO = zeros(nO,1);
    for k=1:nO
        idx = find(SVID == svidO(k));        
        [PDIST,ERRO] = Interpola(t,SVTIME(idx),SVPDIST(idx));
        if ERRO > 0
           return; 
        end
        svpdistO(k) = PDIST;
    end
%
%  Calcula a lista de satélites existentes no momento "t" . 
%  Retorna a lista de nomes de satélites "svid" e suas efemérides
%
    [SVID,SVTIME,SVEPH] = Get_Navigations(conn,t,4);
    if isempty(SVID)
        return;
    end

    sVEPHO = zeros(nO,20);
    fVEPHO = zeros(nO,1);
    for k=1:nO
        idx = find(svidO(k) == SVID);
        if ~isempty(idx)
            if size(idx,1) == 1
                SVeph = SVEPH(idx,:);
            else
                [SVeph,ERRO] = Interpola(t,SVTIME(idx),SVEPH(idx,:));
                if ERRO > 0
                   return; 
                end
            end
            fVEPHO(k) = 1;
            sVEPHO(k,:) = SVeph;
        end
    end       
    
end
%--------------------------------------------------------------------------