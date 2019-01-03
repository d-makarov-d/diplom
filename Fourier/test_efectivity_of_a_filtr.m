%сравнение эффективности нормированного и ненормированного фильтра
function test_efectivity_of_a_filtr()
    filtr = load_filtr('ans_sig_part_2.dta');
    batch = load_test_batch('patterns\train_part_1.csv', 32);
    
    figure(1);
    hold on;
    for i = 1:length(batch)
        if batch(i).is_sig
            plot(calc_y(batch(i).data, filtr), i, 'og');
        else
            plot(calc_y(batch(i).data, filtr), i, 'or');
        end
    end
    
    filtr = (filtr - min(filtr))./(max(filtr) - min(filtr));
    figure(2);
    hold on;
    for i = 1:length(batch)
        if batch(i).is_sig
            plot(calc_y(batch(i).data, filtr), i, 'og');
        else
            plot(calc_y(batch(i).data, filtr), i, 'or');
        end
    end
    
    %file reading in mkm/sec
    [y,par]=adb_read('22880207.adb','s',0);
    %time vector, T in seconds
    T=(0:length(y)-1)/par.fs;
    %fft signal
    sig = y(:,2)-mean(y(:,2));
    
    for i = 1:(length(sig) - length(filtr))
        ans(i) = calc_y(sig(i+1:i+length(filtr)), filtr);
    end
end

function batch = load_test_batch(path, batch_size)
    fid = fopen(path, 'r');
    line = fgetl(fid);
    data = textscan(line, '%f %f');
    len = data{1};
    size = data{2};
    all = repmat(struct('data', 'is_sig'), size, 1);
    cnt = 1;
    while ~feof(fid)
        line = fgetl(fid);
        data = textscan(line, '%f', len+1);
        all(cnt).data = data{1}(1:len);
        all(cnt).is_sig = data{1}(len+1) > 0;
        cnt = cnt + 1;
    end
    fclose(fid);
    batch = all;
end

function var = load_filtr(path)
    str = fileread(path);
    var = str2double(strsplit(str, '|'));
    var(length(var)) = [];
end

function y = calc_y(sig, filtr)
    y = norm( abs( ifft( fft(sig ./ norm(sig)) .* filtr' ) ) );
end
