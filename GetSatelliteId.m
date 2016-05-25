function pos = GetSatelliteId(sv_name,sv_lista)
    pos = -1;
    for k=1:size(sv_lista,1)
        if strcmp(sv_lista{k},sv_name)
            pos = k;
            break;
        end
    end
    if pos < 0
        fprintf(1,'\n\t*** ERROR - %s not found\n',sv_name);
    end
end