function corelation(pat)
    %file reading in mkm/sec
    [y,par]=adb_read('22890216.adb','s',0);
    %time vector, T in seconds
    T=(0:length(y)-1)/par.fs;
    sig = y(:,2)-mean(y(:,2));
    len = length(T(T<1));
    
%     plot_sg(sig,T,27,80);
%     hold on;
    [r,lag] = xcorr(sig, make_pattern(pat));
    hold on;
    plot(T,sig.^2,'g');
    plot(lag./len + 86,r./50,'r');
end