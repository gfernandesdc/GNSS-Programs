function Pst = Get_Station_Coord(conn,stationId)
    q2 = ['select * from station where id = ' int2str(stationId) ];
    curs = exec(conn, q2);
    curs = fetch(curs);
    id = curs.Data;
    Pst = zeros(3,1);
    Pst(1) = id{3};
    Pst(2) = id{4};
    Pst(3) = id{5};
end