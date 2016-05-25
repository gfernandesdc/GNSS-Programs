function [sze,svnames] = GetSatelliteNames(conn)
%
%   Get satellite names and form a table
%
    curs = exec(conn,'select name from satellite');
    curs = fetch(curs);
    svnames   = curs.Data;
    sze = size(svnames,1);
end

