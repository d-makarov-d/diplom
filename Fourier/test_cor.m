%тестирование насколько совпадают прогнозы человека и прграммы

function test_cor()
    global sig T;
    %file reading in mkm/sec
    [y,par]=adb_read('22880207.adb','s',0);
    %time vector, T in seconds
    T=(0:length(y)-1)/par.fs;
    sig = y(:,2)-mean(y(:,2));
    [mask_hi, test_sig] = mk_test_sig();
    mask_ai = filtr_integral(T, sig);
    
    hold on;
    plot(T, sig-50, 'b');
    plot(T, test_sig-50, 'r');
    
    matches = mask_ai & mask_hi;
    all_finded = mask_ai | mask_hi;
    percent = length(find(matches))./length(find(all_finded)).*100;
    disp(strcat(num2str(round(percent.*100)./100), '%'));
end

function [mask, rsig] = mk_test_sig()
    global sig T;
    load('data.mat');
    rsig = NaN(size(sig));
    mask = false(size(T));
    for i = 1:length(intervals)
        f1 = T > intervals{i}(1);
        f2 = T < intervals{i}(1) + intervals{i}(2);
        f = (f1+f2) == 2;
        mask = mask + f;       
    end
    mask = mask >= 1;
    rsig(mask) = sig(mask);
end