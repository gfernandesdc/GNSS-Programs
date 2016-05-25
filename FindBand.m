function bandId = FindBand(conn, bandName)
%
%  Get band id by name
%
    q2 = ['select id from band where name=''' bandName ''''];
    curs = exec(conn, q2);
    curs = fetch(curs);
    id = curs.Data;
    if isnan(id{1,1})
        bandId = -1;
    else
        bandId = id{1,1};
    end
end

