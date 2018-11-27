function test()
    %file reading in mkm/sec
    [y,par]=adb_read('22880207.adb','s',0);
    %time vector, T in seconds
    T=(0:length(y)-1)/par.fs;
    sig = y(:,2)-mean(y(:,2));
    frame = length(sig(T<10));
    
    func = zeros( [size(T,1), size(T,2)-frame+1] );
    for i = 1:(length(T)-frame)
        t = abs(fft(sig(i:(i+frame))));
        func(i) = sum(t(11:100));
    end
    plot_sg(sig.^2,T,27,80);
    hold on;
    plot_sg(func./max(func).*100, T(1:(length(T)-frame+1)), 27, 80);
    
    figure(2);
    plot(T,sig.^2);
    hold on;
    plot(T(1+floor(frame/2):(length(T)-ceil(frame/2)+1)),func./max(func).*100,'r');
    
    mask = func>mean(func);
    t = T(1+floor(frame/2):(length(T)-ceil(frame/2)+1));
    s = sig(1+floor(frame/2):(length(T)-ceil(frame/2)+1));
    plot(t(mask), s(mask), '*g')
end