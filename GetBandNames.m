function [sze,bdnames] = GetBandNames(conn)
%
%   Get band names and form a table
%
    curs = exec(conn, 'select name from band');
    curs = fetch(curs);
    bdnames = curs.Data;
    sze = size(bdnames,1);
end

