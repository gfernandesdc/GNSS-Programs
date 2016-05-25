function rinex_obs_genbank
    global fileID id
    id = 1;
    
    fprintf('\n\t------------ OBS DBASE GENERATION ----------------\n\n');
    tStart = tic;
    cur_dir = pwd;
    new_dir = '..\DATABASE';
    cd(new_dir);
    lista = dir('*.*o');
    cd(cur_dir);
    
    TOTAL_COUNT = 0;
    fileID = fopen('OBS_FILE.sql', 'wt');
    for k=1:length(lista)
        fname = fullfile(new_dir,lista(k).name);
        fprintf('\tProcessing file %s ...',fname);
        tic;
        r_count = rinex_obs_read(fname);
        fprintf(1,' %7d records %7.2f seg\n\n',r_count,toc);
        TOTAL_COUNT = TOTAL_COUNT + r_count;
    end
    fclose(fileID);
    cd(cur_dir);
    fprintf(1,'\n\tTotal records : %d sec.\n',TOTAL_COUNT);
    fprintf(1,'\n\tDuration %.2f sec.\n\n',toc(tStart));
end
