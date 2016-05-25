function stationId = FindStation(conn, stationName)
%
%  Get station id by name
%
    q2 = ['select id from station where name=''' stationName ''''];
    curs = exec(conn, q2);
    curs = fetch(curs);
    id   = curs.Data;
    if isnan(id{1,1})
        stationId = -1;
    else
        stationId = id{1,1};
    end
end

