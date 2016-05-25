function [buffer,code] = find_in_file(fid,string)
    while 1
        buffer = fgetl(fid);
        if buffer == -1
            code = -1;
            return;
        elseif strfind(buffer,string)
            code = 0;
            return;
        end
    end
end