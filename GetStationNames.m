function [sze,stnames] = GetStationNames(conn)
%
%   Get band names and form a table
%
    curs = exec(conn, 'select name from station');
    curs = fetch(curs);
    stnames = curs.Data;
    sze = size(stnames,1);
end

