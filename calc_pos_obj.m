function Pos_Est = calc_pos_obj(epoch,Type_obsv)

%   ACESSO A BANCO DE DADOS RETORNANDO OS PARÂMETROS ORBITAIS DE TODOS OS 
%   SATÉLITES NA DATA epoch. RESULTADO EM eph (linhas=sat col=parametros)

    DATA = zeros(32,23);
    ephS = get_eph_from_database(epoch,Type_obsv);
%--------------------------------------------------------------------------
% Obtaining Rho and the SVs numbers of visibles satellites
%--------------------------------------------------------------------------
    pos = 0;
    for k=1:size(ephS,1)
        sv = ephS(k,1);
        [Rho,erro] = get_rho_from_database(epoch,sv,Type_obsv);
        if erro == 0
            pos = pos+1;
            DATA(pos,1) = sv;
            DATA(pos,2) = Rho;
            DATA(pos,3:end) = ephS(k,:);
        end
    end          
%--------------------------------------------------------------------------
%  Computation of receiver position from pseudoranges using ordinary 
%  least-squares principle, if Eph not empty
%-------------------------------------------------------------------------- 
    for k=1:pos
        Pos_Est = rec_pos_ls(DATA);
    end
end


