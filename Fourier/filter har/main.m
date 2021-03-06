function sig1 = main(sig)
    str = fileread('ans_sig_part_1.dta');
    var = str2double(strsplit(str, '|'));
    var(length(var)) = [];
    var = (var - min(var))./(max(var) - min(var));
    
    fft_sig = fft(sig);
    fft_sig1 = mul(fft_sig,var);
    sig1 = real(ifft(fft_sig1));
    
    z = 0:10000;
    eval(fun(sig, 'V', 'z'))
    eval(fun(sig1, 'U', 'z'))
end

function an = mul(a, b)
    frame = fix(length(a)/length(b));
    an = zeros(size(a));
    for i = 0:(length(b)-1)
        an((i*frame+1):(i+1)*frame) = a((i*frame+1):(i+1)*frame) .* b(i+1);
    end
    an(((length(b))*frame):length(a)) = a(((length(b))*frame):length(a)) .* b(length(b));
end

function an = imp(len)
    an = zeros(1,len);
    an(1:10) = 1;
end

function an = fun(u, ch, var)
    an = string(u(1));
    for i = 2:length(u)
        an = an + sprintf(' + %f*(%s.^(%i))', u(i), var, -i); 
    end
    an = [ch ' = '  char(an)  ';'];
end