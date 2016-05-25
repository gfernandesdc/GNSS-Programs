function pos = GetBandId(bd_name,bd_lista)

    for k=1:size(bd_lista,1)
        if strcmp(bd_lista{k},bd_name)
            pos = k;
            break;
        end
    end
    
end