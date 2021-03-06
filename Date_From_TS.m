function int_date = Date_From_TS(s)
    if ischar(s)
        int_date = str2double(s( 1: 4))*10000000000 + ...
                   str2double(s( 6: 7))*100000000 + ...
                   str2double(s( 9:10))*1000000 + ...
                   str2double(s(12:13))*10000 + ...
                   str2double(s(15:16))*100 + ...
                   str2double(s(18:19));
    else
        int_date = s(1)*10000000000 + ...
                   s(2)*100000000 + ...
                   s(3)*1000000 + ...
                   s(4)*10000 + ...
                   s(5)*100 + ...
                   s(6);    
    end
end


