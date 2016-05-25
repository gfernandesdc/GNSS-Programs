function satelliteId = FindSatellite(conn, satelliteName)
%
%   Get satellite id by name
%
    q2 = ['select id from satellite where name=''' satelliteName ''''];
    curs = exec(conn, q2);
    curs = fetch(curs);
    id   = curs.Data;
    if isnan(id{1,1})
        satelliteId = -1;
    else
        satelliteId = id{1,1};
    end
end

