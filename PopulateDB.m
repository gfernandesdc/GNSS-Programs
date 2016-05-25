function PopulateDB () 

    tic;
    conn = database('rinex','postgres','123456',...
                    'Vendor','PostgreSQL',...
                    'Server','localhost');
    
    fprintf('\n\t----------- DATABASE INITIALIZATION ---------------\n\n');
    
    % Popular satélites
    
    TAM  = [32 32 38 20];
    CTAM = cumsum(TAM);
    
    for k=1:TAM(1)
        temp = sprintf('G%02d',k);
        fastinsert(conn, 'satellite', {'id', 'name'}, {k, temp});
    end
    fprintf(1,'\tG-Satellites included : %d\n',TAM(1));
    
    for k=1:TAM(2)
        temp = sprintf('R%02d',k);
        fastinsert(conn, 'satellite', {'id', 'name'}, {CTAM(1)+k, temp});
    end 
    fprintf(1,'\tR-Satellites included : %d\n',TAM(2));
    
    for k=1:TAM(3)
        temp = sprintf('S%02d',k);
        fastinsert(conn, 'satellite', {'id', 'name'}, {CTAM(2)+k, temp});
    end
    fprintf(1,'\tS-Satellites included : %d\n',TAM(3));
    
    for k=1:TAM(4)
        temp = sprintf('E%02d',k);
        fastinsert(conn, 'satellite', {'id', 'name'}, {CTAM(3)+k, temp});
    end
    fprintf(1,'\tE-Satellites included : %d\n',TAM(2));
    
    % Popular bandas
    
    bandas = {'L1','L2','L3','L5','L7','L8','C1','C2','C5','C7','C8','P1','P2','P5'};
    for k=1:length(bandas)
        fastinsert(conn, 'band', {'id', 'name'}, {k, bandas{k}});
    end
    fprintf(1,'\tNo. of bands included : %d\n',length(bandas));
    
    %  Popular com as estações
    
    stations = {'PRU1','PRU2','PRU3','SJCE','SJCU'};  
    coords   = [ 3687610.8400  -4620824.4881  -2386895.5991;
                 3687692.4306  -4620663.3185  -2387103.2257;
                 3678839.8754  -4620675.6009  -2386791.7045;
                 4084943.4269  -4209412.5101  -2498101.1667;
                 4077724.8412  -4216210.5918  -2498409.9958];
   
    for k=1:length(stations)
        fastinsert(conn, 'station', {'id', 'name','x','y','z'}, ...
            {k, stations{k}, coords(k,1), coords(k,2), coords(k,3)});
    end
    close(conn);
    
    fprintf(1,'\tStations included     : %d\n',length(stations));
    fprintf(1,'\n\tDuration %.2f sec.\n\n',toc);
end