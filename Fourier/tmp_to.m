function [std_sig, std_no_sig] = tmp_to(sig, mask)
    signal = sig;
    signal(~mask) = 0;
    
    no_sig = sig;
    no_sig(mask) = 0;
    
    std_sig = std(signal);
    std_no_sig = std(no_sig);
end