function [SVID,SVEPOCH,SVPDIST] = Get_Observations(conn,bandId,stationId,epoch,theta)
    
    data1 = epoch2date(epoch-theta);
    data2 = epoch2date(epoch+theta);
    
    q2 = ['select satelliteid, epoch, array_to_string(pdist,'','') from observation where epoch >= ' ...
        '''' data1 '''' ' and epoch <= ' ...
        '''' data2 '''' ' and satelliteid >=1 and satelliteid <=32 and stationid=' int2str(stationId) ];
 

    
%         q2 = ['select satelliteid, epoch, array_to_string(pdist,'','') from observation where epoch >= ' ...
%         num2str(epoch-theta) ' seconds and epoch <= ' ...
%         num2str(epoch+theta) ' seconds and stationid=' int2str(stationId) ' order by epoch'];

  
%      q2 = ['select satelliteid, epoch, array_to_string(pdist,'','') from observation where ...
%            epoch <= to_timestamp(''' epoch ''', ''YYYY-MM-DD HH24:MI:SS'') + interval ''' int2str(theta) ' seconds'' and ...
%            epoch >= to_timestamp(''' epoch ''', ''YYYY-MM-DD HH24:MI:SS'') - interval ''' int2str(theta) ' seconds'' and ...
%            stationid=' int2str(stationId) ' order by epoch'];
    
    curs = exec(conn, q2);
    curs = fetch(curs);
    id   = curs.Data;
%     id = sortrows(id);
    SVID = cell2mat(id(:,1));
    SS   = size(id,1);
    SVEPOCH = zeros(SS,1);
    SVPDIST = zeros(SS,1);
    for k=1:SS
        x = Process_String(id{k,3});
        SVPDIST(k) = x(bandId);
        SVEPOCH(k) = date2epoch(id{k,2});
    end
end

