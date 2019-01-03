function [mask, a] = filtr_integral(T, sig)
    str = fileread('ans_sig_part_2.dta');
    var = str2double(strsplit(str, '|'));
    var(length(var)) = [];
    var = (var - min(var))./(max(var) - min(var));
    
    fft_sig = fft(sig);
    fft_sig1 = mul(fft_sig,var);
    sig1 = real(ifft(fft_sig1));
    [mask, a] = apply_frame(T,sig1, 2001);
    hold on;
    plot(T,sig1, 'b');
    plot(T(mask), sig1(mask), 'r');
    plot(T,sig - 25, 'b');
    %plot(T(mask),sig(mask) - 25, 'r');
    %ylim([-60, 100]);
end

function an = mul(a, b)
    frame = fix(length(a)/length(b));
    an = zeros(size(a));
    for i = 0:(length(b)-1)
        an((i*frame+1):(i+1)*frame) = a((i*frame+1):(i+1)*frame) .* b(i+1);
    end
    an(((length(b))*frame):length(a)) = a(((length(b))*frame):length(a)) .* b(length(b));
end

function [ind, mask] = pos_max(x)
    xd = diff(x); 
    xds = sign(xd); 
    ix = (xds(1:end-1)~=xds(2:end)); % all extrema 
    ix = ix & (xds(1:end-1)>0); % only maximums 
    mask(2:length(ix)+1) = ix; 
    ind = find(mask); 
end

function a = integ_frame(X, Y, fr_len)
    if rem(fr_len, 2) == 0
        fr_len = fr_len + 1;
    end
    half_len = (fr_len - 1)./2;
    x = X(half_len:(length(X)-half_len));
    y = Y(half_len:(length(Y)-half_len));
    a = zeros(size(x));
    for i = 1:(length(x)-1)
        interval = half_len + ((i - half_len) : (i + half_len));
        a(i) = trapz(X(interval), Y(interval));
    end
    plot(x,a);
end

function [ans_mask, y] = apply_frame(X,Y, fr_len)
    y = integ_frame(X, abs(Y), fr_len);
    if rem(fr_len, 2) == 0
        fr_len = fr_len + 1;
    end
    half_len = (fr_len - 1)./2;
%     s2 = Y(half_len:length(X)-half_len);
%     x = X(half_len:length(X)-half_len);
    %y2 = conv(ones(1,1000), abs(sig1));
    mask = y>50;
    ans_mask = false(size(X));
    ans_mask(half_len:length(X)-half_len) = mask;
end