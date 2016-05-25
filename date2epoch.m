function epoca = date2epoch(date)
    if ~ischar(date)
        date = sprintf('%04d-%02d-%02d %02d:%02d:%02d',date(1:6));
    end
    formatIn = 'yyyy-mm-dd HH:MM:SS';
    epoca = 86400*datenum(date,formatIn);
end