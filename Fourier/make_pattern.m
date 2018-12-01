function m = make_pattern(pattern)
    len = length(pattern{1});
    for i = 2:length(pattern)
        [r,laggs] = xcorr(pattern{i-1},pattern{i});
        [~,n] = max(r);
        shift = laggs(n);
        pattern(i) = circshift(pattern(i),shift);
        if len > length(pattern{i}); len = length(pattern{i}); end
    end
    m = zeros( [len,1] );
    for i = 1:length(pattern)
        m = m + pattern{i}(1:len,1);
    end
    m = m./length(pattern);
end