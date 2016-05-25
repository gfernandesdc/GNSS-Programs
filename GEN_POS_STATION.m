function GEN_POS_STATION(stationId,from_date,to_date,time_unit,bandId)
%
%  Determina a posição da estação definida "station", no intervalo de
%  tempo compreendido entre "from_date" e "to_date" com discretização
%  temporal de "time_unit" (expresso em segundos) usando informação de uma 
%  "banda" particular.
%
    conn = database('rinex','postgres','123456',...
                    'Vendor','PostgreSQL',...
                    'Server','localhost');

    Pst = Get_Station_Coord(conn,stationId);
    fprintf(1,'\nEstação %d  Posição = % 9.3f  % 9.3f  % 9.3f\n\n',...
            stationId,Pst(1),Pst(2),Pst(3));
                
    epoca1 = date2epoch(from_date);
    epoca2 = date2epoch(to_date);
    for t = epoca1:time_unit:epoca2
        [EPH,SV,PDIST] = Find_Visible_SVs(conn,t,bandId,stationId);
        
        idx   = find(SV~=19);
        EPH   = EPH(idx,:);
        SV    = SV(idx);
        PDIST = PDIST(idx);
        
        idx   = find(SV~=30);
        EPH   = EPH(idx,:);
        SV    = SV(idx);
        PDIST = PDIST(idx);
        
        idx = find(PDIST>0);
        EPH   = EPH(idx,:);
        SV    = SV(idx);
        PDIST = PDIST(idx);
        
        [~,sow] = date_time_test(t);
        [pos, El, GDOP, basic_obs] = rec_pos_ls(PDIST,sow,EPH');
        fprintf(1,'Data %s -> Posição Estimada = % 9.3f  % 9.3f  % 9.3f',...
            epoch2date(t),pos(1),pos(2),pos(3));
        fprintf('   erro = % 7.3f m\n',norm(pos(1:3)-Pst,'fro'));
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
        [PDIST,ERRO] = Interpola(t,SVTIME(idx),SVPDIST(idx),1);
        if ERRO > 0
           return; 
        end
        svpdistO(k) = PDIST;
    end
%
%  Calcula a lista de satélites existentes no momento "t" . 
%  Retorna a lista de nomes de satélites "svid" e suas efemérides
%
    [SVID,SVTIME,SVEPH] = Get_Navigations(conn,t,18000);
    if isempty(SVID)
        return;
    end
       
    sVEPHO = zeros(nO,20);
    fVEPHO = zeros(nO,1);
    for k=1:nO
        idx = find(svidO(k) == SVID);
        if ~isempty(idx)
            [SVeph,ERRO] = Interpola(t,SVTIME(idx),SVEPH(idx,:),3);
            if ERRO > 0
               return; 
            end
            fVEPHO(k) = 1;
            sVEPHO(k,:) = SVeph;
        end
    end       
end
%--------------------------------------------------------------------------
