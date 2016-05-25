function DataString = epoch2date(epoca)
    temp = datevec(epoca/86400);
    DataString = sprintf('%04d-%02d-%02d %02d:%02d:%02d',temp);
end