function [fid,s,erro] = rd_rnx_header(filename)
    fid = fopen(filename);
    if fid < 0
        erro = 8;   % filename não existe
        return;
    end
    s = struct('TYPE_SV',[],'MK_NAME',[],'OBSV_AG',[],'REC_XYZ',[],...
        'TObs',[]);
    while 1  
        [Buffer,Ecode] = find_in_file(fid,'RINEX VERSION / TYPE');
        if Ecode == 0
%             version = sscanf(Buffer,'%f',1);
            if strfind(Buffer,'MIXED')
                s.TYPE_SV = 'MIXED';
            elseif strfind(Buffer,'GALILEO')
                s.TYPE_SV = 'GALILEO';
            elseif strfind(Buffer,'GLONASS')
                s.TYPE_SV = 'GLONASS';
            else
                s.TYPE_SV = 'GPS';
            end
        else
            erro = 1;   % Não existe linha com RINEX VERSION
            return;
        end        
        [Buffer,Ecode] = find_in_file(fid,'MARKER NAME');  
        if Ecode == 0
           s.MK_NAME = sscanf(Buffer,'%s',(1));
        else
            erro = 2;   % Não existe linha com MARKER NAME
            return;
        end
        [Buffer,Ecode] = find_in_file(fid,'OBSERVER');  
        if Ecode == 0
            s.OBSV_AG = sscanf(Buffer,'%s%s%s',[1,3]);
        else
            erro = 3;   % Não existe linha com OBSERVER
            return;
        end 
        [Buffer,Ecode] = find_in_file(fid,'APPROX');
        if Ecode == 0
            s.REC_XYZ = sscanf(Buffer,'%f',[1,3]);
        else
            erro = 4;   % Não existe linha com APPROX
            return;
        end
        [Buffer,Ecode] = find_in_file(fid,'TYPES OF OBSERV');
        flag = 0;
        if Ecode == 0
            Num_type_obsv = sscanf(Buffer,'%d',1);
            Type_obsv = cell(Num_type_obsv,1);
            for k=1:Num_type_obsv
                idx = 1+mod(k-1,9);
                if idx == 1
                    if flag == 0 
                        flag = 1;
                    else
                        Buffer = fgetl(fid);
                    end
                end
                nn = 6*idx+5;
                Type_obsv{k} = Buffer(nn:nn+1);
            end          
        else
           erro = 5;   % Não existe linha com TYPES OF OBSERV
           return;
        end
        [~,Ecode] = find_in_file(fid,'END OF HEADER');
        if Ecode == 0
            erro = 0;
            s.TObs = Type_obsv;
            return;
        else
           erro = 6;   % Não existe linha com END OF HEADER
           return;
        end
    end 
end