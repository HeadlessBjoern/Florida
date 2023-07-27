function sendtrigger(trg,port,SITE,stayup)

sendpulse = [109 104];
trigtransform = [1 nan nan 2 3 nan nan 8 9 nan nan 10 11 nan nan 16 17 nan nan 18 19 nan nan 24 25 nan nan 26 27];

if SITE=='C', 
    IOPort('Write', port, uint8([sendpulse trigtransform(trg) 0]), 0); 
elseif SITE=='E', 
    lptwrite(1,1); if ~stayup, WaitSecs(0.005); lptwrite(port,0); end
elseif SITE=='P', 
    lptwrite(port,trg); if ~stayup, WaitSecs(0.005); lptwrite(port,0); end 
elseif SITE=='T', 
    lptwrite(port,trg); if ~stayup, WaitSecs(0.005); lptwrite(port,0); end
elseif SITE=='N',
    NetStation('event',num2str(trg));
elseif SITE == 'A' % A = ANT Neuro
    ppdev_mex('Write', port, trg);
   if ~stayup 
       WaitSecs(0.010);
       ppdev_mex('Write', 1, 0);
   end
end  