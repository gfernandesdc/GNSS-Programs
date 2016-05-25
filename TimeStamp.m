function ts = TimeStamp(epoch)
   ts = sprintf('%04d-%02d-%02d %02d:%02d:%02d',...
        epoch(1), epoch(2), epoch(3), epoch(4), epoch(5), epoch(6));
end