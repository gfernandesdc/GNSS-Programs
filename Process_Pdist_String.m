function x = Process_String(s)
    pos = strfind(s,',');
    N   = length(pos);
    x = zeros(N+1,1);
    inic = 1;
    for k=1:N
        ifim = pos(k)-1;
        x(k) = str2double(s(inic:ifim));
        inic = pos(k)+1;
    end
    x(N+1) = str2double(s(inic:end));
end