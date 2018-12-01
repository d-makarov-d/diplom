function filtr()
    str = fileread('var.dta');
    var = str2double(strsplit(str, '|'));
    var(length(var)) = [];
    var = (var - 0.5)*2;
    plot(var);
    
    %file reading in mkm/sec
    [y,par]=adb_read('22890216.adb','s',0);
    %time vector, T in seconds
    T=(0:length(y)-1)/par.fs;
    %fft signal
    sig = y(:,2)-mean(y(:,2));
    fft_sig = fft(sig);
    fft_sig1 = mul(fft_sig,var);
    sig1 = real(ifft(fft_sig1));
    figure(1);
    plot_sg_col(5*sig1,T,27,80,'b');
    hold on;
    %plot_sg(sig,T,27,80);
    %figure(2);
    %plot_sg(angle(sig1),T,27,80);
    [~, mask] = pos_max(sig1);
    figure(2);
    %plot_sg_col(5*sig1(mask),T(mask),27,80,'r');
    hold on;
    plot(T, sig1,'b');
    plot(T(mask), sig1(mask), '-r');
    t1 = T(mask);
    s1 = sig1(mask);
    [ind, ~] = pos_strong_max(s1);
    for i=1:length(ind)
        plot(t1(ind(i)), s1(ind(i)), 'go');
    end
    for i=1:length(ind)-3
        test = [s1(ind(i)), s1(ind(i+1)), s1(ind(i+2)), s1(ind(i+3))];
        test_t = [t1(ind(i)), t1(ind(i+1)), t1(ind(i+2)), t1(ind(i+3))];
        if check_mask(test)
            plot(test_t, test, 'ko');
        end
    end
    a=gca(); 
    a.YLim = [-60,60];
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

function [ind, mask] = pos_strong_max(x)
    xd = diff(x); 
    xds = sign(xd); 
    ix = (xds(1:end-1)~=xds(2:end)); % all extrema 
    maxx = ix & (xds(1:end-1)>0); % only maximums 
    minx = ix & (xds(1:end-1)<0); % only minimums
    maskmax(2:length(maxx)+1) = maxx;
    maskmin(2:length(minx)+1) = minx;
    indmax = find(maskmax);
    indmin = find(maskmin);
    k = 1;
    for i = 1:length(indmax)-1
        if abs(x(indmax(i)) - x(indmin(i))) > 0.2 && abs(x(indmax(i)) - x(indmin(i)+1)) > 0.2
            ind(k) = indmax(i);
            k = k+1;
        end
    end
    mask = false(size(x));
    mask(ind) = true;
end
function a = check_mask(dots)
    if length(dots) == 4
        a = abs(dots(1) - dots(4)) < 5 &&...
            abs(dots(2) - dots(3)) < 2 &&...
            (dots(1) - dots(2) > 3 && dots(4) - dots(3) > 3) &&...
            dots(2) + dots(3) < dots(1) + dots(4) + 3;
    end
end