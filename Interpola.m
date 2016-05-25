function [y0,erro] = Interpola(x0,x,y,caso)
    temp = x(1);
    x    = x - temp;
    x0   = x0 - temp;
    if x0<x(1) || x0>x(end)
        erro = 1;
        return;
    end
    n = find(x==x0);
    if ~isempty(n)
        y0 = y(n,:);
    elseif caso == 1
%
%   Utiliza todos os dados para interpolação
%
        y0 = interp1(x,y,x0,'pchip');
    elseif caso == 2
%
%   Utiliza apenas os dados vizinhos
%        
        n = find(x<=x0+180);
        idxL = n(end);
        n = find(x>=x0-180);
        idxU = n(1);
        if idxL==idxU
            y0 = y(idxU,:);
        else
            xx = zeros(2,1);
            yy = zeros(2,size(y,2));
            xx(1)   = x(idxL);
            yy(1,:) = y(idxL,:);
            xx(2)   = x(idxU);
            yy(2,:) = y(idxU,:);
            y0 = interp1(xx,yy,x0,'pchip');
        end
    else
        
%
%   Utiliza apenas o anterior
%        
        n = find(x<=x0+180);
        idxL = n(end);
        y0 = y(idxL,:);
    end  
    erro = 0;
end