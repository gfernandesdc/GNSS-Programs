function noeph = rinex_nav_read(filename)
%
%  Reads a RINEX Navigation Message file given by "filename" and store its 
%  contents in the database. 
%
    global id
    
    conn = database('rinex','postgres','123456',...
                    'Vendor','PostgreSQL',...
                    'Server','localhost');
%                
%  Get satellite names
%
    [~,SV_lista] = GetSatelliteNames(conn);
%
%  Process RINEX file
%
    fide = fopen(filename);
    
    head_lines = 1;
    line = fgetl(fide);
    if strfind(line,'GPS') > 0
        Field = 'G';
    elseif strfind(line,'GLONASS') > 0
        Field = 'R';
    else
        Field = 'E';
    end
    while 1  % We skip header
       head_lines = head_lines+1;
       line = fgetl(fide);
       answer = strfind(line,'END OF HEADER');
       if ~isempty(answer), break;	end;
    end;
    noeph = -1;
    
    while 1
       noeph = noeph+1;
       line = fgetl(fide);
       if line == -1, break;  end
    end;
    noeph = noeph/8;
    frewind(fide);
    for i = 1:head_lines, fgetl(fide); end;
%
% Set aside memory for the input
%
    svprn	 = zeros(1,noeph);
    tgd	     = zeros(1,noeph);
    af2	     = zeros(1,noeph);
    af1	     = zeros(1,noeph);
    af0	     = zeros(1,noeph);
    deltan	 = zeros(1,noeph);
    M0	     = zeros(1,noeph);
    ecc	     = zeros(1,noeph);
    roota	 = zeros(1,noeph);
    toe	     = zeros(1,noeph);
    cic	     = zeros(1,noeph);
    crc	     = zeros(1,noeph);
    cis	     = zeros(1,noeph);
    crs	     = zeros(1,noeph);
    cuc	     = zeros(1,noeph);
    cus	     = zeros(1,noeph);
    Omega0	 = zeros(1,noeph);
    omega	 = zeros(1,noeph);
    i0	     = zeros(1,noeph);
    Omegadot = zeros(1,noeph);
    idot	 = zeros(1,noeph);
    year	 = zeros(1,noeph);
    month	 = zeros(1,noeph);
    day	     = zeros(1,noeph);
    hour	 = zeros(1,noeph);
    minute	 = zeros(1,noeph);
    second	 = zeros(1,noeph);

    for i = 1:noeph
       line        = fgetl(fide);
       line = strrep(line,'D','e');
       svprn(i)    = str2double(line(1:2));
       year(i)     = str2double(line(3:6));
       month(i)    = str2double(line(7:9));
       day(i)      = str2double(line(10:12));
       hour(i)     = str2double(line(13:15));
       minute(i)   = str2double(line(16:18));
       second(i)   = str2double(line(19:22));
       af0(i)      = str2double(line(23:41));
       af1(i)      = str2double(line(42:60));
       af2(i)      = str2double(line(61:79));
       
       line        = fgetl(fide);	  
       line = strrep(line,'D','e');
       crs(i)      = str2double(line(23:41));
       deltan(i)   = str2double(line(42:60));
       M0(i)       = str2double(line(61:79));
       
       line        = fgetl(fide);	  
       line = strrep(line,'D','e');
       cuc(i)      = str2double(line(4:22));
       ecc(i)      = str2double(line(23:41));
       cus(i)      = str2double(line(42:60));
       roota(i)    = str2double(line(61:79));
       
       line        = fgetl(fide);
       line = strrep(line,'D','e');
       toe(i)      = str2double(line(4:22));
       cic(i)      = str2double(line(23:41));
       Omega0(i)   = str2double(line(42:60));
       cis(i)      = str2double(line(61:79));
       
       line        = fgetl(fide);	    
       line = strrep(line,'D','e');
       i0(i)       = str2double(line(4:22));
       crc(i)      = str2double(line(23:41));
       omega(i)    = str2double(line(42:60));
       Omegadot(i) = str2double(line(61:79));
       
       line        = fgetl(fide);	    
       line = strrep(line,'D','e');
       idot(i)     = str2double(line(4:22));
       
       line        = fgetl(fide);
       line = strrep(line,'D','e');
       tgd(i)      = str2double(line(42:60));

       fgetl(fide);	    %
    end
    fclose(fide);
%    
%  Description of variable eph.
%
    eph = zeros(noeph,27);
    
    eph(:,1)  = svprn;
    eph(:,2)  = af2;
    eph(:,3)  = M0;
    eph(:,4)  = roota;
    eph(:,5)  = deltan;
    eph(:,6)  = ecc;
    eph(:,7)  = omega;
    eph(:,8)  = cuc;
    eph(:,9)  = cus;
    eph(:,10) = crc;
    eph(:,11) = crs;
    eph(:,12) = i0;
    eph(:,13) = idot;
    eph(:,14) = cic;
    eph(:,15) = cis;
    eph(:,16) = Omega0;
    eph(:,17) = Omegadot;
    eph(:,18) = toe;
    eph(:,19) = af0;
    eph(:,20) = af1;
    eph(:,21) = toe;
    eph(:,22) = year;
    eph(:,23) = month;
    eph(:,24) = day;
    eph(:,25) = hour;
    eph(:,26) = minute;
    eph(:,27) = second;
%
%   Colocação no banco de dados
%   
%     q2 = ('select max(id) from navigation');
%     curs = exec(conn, q2);
%     curs = fetch(curs);
%     id = curs.Data;
%     if isnan(id{1,1})
%         id = 1;
%     else
%         id = id{1,1};
%         id = id + 1;
%     end
    
    for k=1:noeph
        epoca = eph(k,22:27);
        satelliteName   = sprintf('%c%02d',Field,eph(k,1));
        datum = eph(k,2:21);       
        satelliteId = GetSatelliteId(satelliteName,SV_lista);
        Insert_In_NAV_Database(conn, id, satelliteId, epoca, datum);
        id = id + 1;
    end
    
    close(conn);
end