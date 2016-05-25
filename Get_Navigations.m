function [SVID,SVEPOCH,SVEPH] = Get_Navigations(conn,epoch,theta)

    data1  = epoch2date(epoch-theta);
    data2  = epoch2date(epoch-(theta-3600));
    data3  = epoch2date(epoch-(theta-7200));
    data4  = epoch2date(epoch-(theta-10800));
    data5  = epoch2date(epoch-(theta-14400));
    data6  = epoch2date(epoch);
    data7  = epoch2date(epoch+(theta-14400));
    data8  = epoch2date(epoch+(theta-10800));
    data9  = epoch2date(epoch+(theta-7200));
    data10 = epoch2date(epoch+(theta-3600));
    data11 = epoch2date(epoch+theta);
    
%     q2 = ['select satelliteid, epoch, array_to_string(ephemeris,'','') from navigation where epoch >= ' ...
%         '''' data1 '''' ' and epoch <= ' ...
%         '''' data2 '''' ' and satelliteid >=1 and satelliteid <=32 '];
    
    q2 = ['select satelliteid, epoch, array_to_string(ephemeris,'','') from navigation where epoch = ' ...
        '''' data1 '''' ' or epoch = ' '''' data2 '''' '  or epoch = '...
        '''' data3 '''' ' or epoch = ' '''' data4 '''' '  or epoch = '...
        '''' data5 '''' ' or epoch = ' '''' data6 '''' '  or epoch = '...
        '''' data7 '''' ' or epoch = ' '''' data8 '''' '  or epoch = '...
        '''' data9 '''' ' or epoch = ' '''' data10 '''' ' or epoch = '...
        '''' data11 '''' ' and satelliteid >=1 and satelliteid <=32 '];
    
%    select satelliteid, epoch, array_to_string(ephemeris,'','') from navigation where satelliteid >=1 and 
%  satelliteid <=32 and (epoch ='0014-01-09 20:00:00' or epoch = '0014-01-09 22:00:00' or 
%  epoch ='0014-01-10 00:00:00' or epoch ='0014-01-10 02:00:00' or epoch = '0014-01-10 04:00:00');
     
    curs = exec(conn, q2);
    curs = fetch(curs);
    id = curs.Data;
    SS = size(id,1);
    SVID    = zeros(SS,1);
    SVEPOCH = zeros(SS,1);
    SVEPH   = zeros(SS,20);
    for k=1:SS
        SVID(k)    = id{k,1};
        SVEPOCH(k) = date2epoch(id{k,2});
        SVEPH(k,:) = Process_String(id{k,3});
    end
end

