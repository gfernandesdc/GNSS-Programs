function rinex_nav_genbank

    global textVal id
    textVal = '';
    id = 1;
    
    noeph_total = 0;
    
    fprintf('\n\t------------ NAV DBASE GENERATION ----------------\n\n');
    tStart = tic;
    cur_dir = pwd;
    new_dir = '..\DATABASE';
    cd(new_dir);
    lista = dir('*.*n');
    cd(cur_dir);
    
    for k=1:length(lista)
        fname = fullfile(new_dir,lista(k).name);
        fprintf('\t%3d) Processing file %s ...',k,fname);
        tic;
        noeph = rinex_nav_read(fname);
        fprintf(1,'%7d registers inserted in %7.2f sec.\n',noeph,toc);
        noeph_total = noeph_total + noeph;
    end
    fprintf(1,'\n\tTotal number of registers : %d\n',noeph_total);     
    fileID = fopen('NAV_FILE_II.sql', 'wt');
    fprintf(fileID, [textVal '%s']);
    fclose(fileID);
    
    fprintf(1,'\n\tDuration %.2f sec.\n\n',toc(tStart));
end

