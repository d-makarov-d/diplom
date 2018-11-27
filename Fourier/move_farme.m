function move_farme()
    global FRAME_LENGTH DELTA_FRAME DOT_LENGTH T dx sig_axes fourier_axes sig pattern N;
    FRAME_LENGTH = 100;
    DELTA_FRAME = 20;
    DOT_LENGTH = get_dot_length();
    dx = 0;
    N = 0;
    pattern = double.empty;
    
    fourier_fig = figure('Name','Fourier','NumberTitle','off', 'InnerPosition', [10,450,1300,300]);
    fourier_axes = axes(fourier_fig, 'Position',[0.1 0.1 0.8 0.8]);
    
    sig_fig = figure('Name','Sig','NumberTitle','off', 'InnerPosition', [10,50,1300,300]);
    sig_axes = axes(sig_fig, 'Position',[0.1 0.1 0.8 0.8]);
    
    %file reading in mkm/sec
    [y,par]=adb_read('22890216.adb','s',0);
    %time vector, T in seconds
    T=(0:length(y)-1)/par.fs;
    %fft signal
    sig = y(:,2)-mean(y(:,2));
    replot();
    
    sig_fig.WindowKeyPressFcn = @key_pressed_callback;
end

function fram = frame(dx)
    global FRAME_LENGTH DELTA_FRAME T;
    fram1 = T > -FRAME_LENGTH + dx;
    fram2 = T < DELTA_FRAME + FRAME_LENGTH + dx;
    fram = (fram1 + fram2) == 2;
end

function fram = frame1(dx)
    global DOT_LENGTH sig T;
    i = 1;
    while T(i) < dx
        i = i + 1;
    end
    fram = zeros(size(sig));
    fram((i+1):(i+DOT_LENGTH)) = 1;
    fram = logical(fram);
%     fram1 = T > dx;
%     fram2 = T < DELTA_FRAME + dx;
%     fram = (fram1 + fram2) == 2;
end

function i = get_dot_length()
    global DELTA_FRAME T;
    i = 1;
    while T(i) < DELTA_FRAME
        i = i + 1;
    end
end

function key_pressed_callback(source, event)
    global dx pattern sig DOT_LENGTH;
    switch event.Key
        case 'rightarrow'
            dx = dx + 1;
        case 'leftarrow'
            dx = dx - 1;
        case '1'
            pattern{length(pattern)+1} = [transpose(sig( frame1(dx) )), 1];
        case '0'
            pattern{length(pattern)+1} = [transpose(sig( frame1(dx) )), 0];
        case 's'
            save('patterns/1.mat', 'pattern');
            fileID = fopen('patterns/train.csv', 'w');
            format_spec = '%f';
            for i = 1:(DOT_LENGTH-1)
                format_spec = strcat(format_spec, ' %f');
            end
            format_spec = strcat(format_spec, ' %i\n');
            fprintf(fileID, '%i %i\n', [DOT_LENGTH, length(pattern)]);
            for i = 1:length(pattern)
                fprintf(fileID, format_spec, pattern{i});
            end
            fclose(fileID);
    end
    replot();
end

function replot()
    global T sig_axes dx sig DELTA_FRAME fourier_axes;
    plot(sig_axes, T(frame(dx)), sig(frame(dx)).^2 );
    sig_axes.YLim = [0 1100];
    rectangle(sig_axes, 'Position', [ dx, sig_axes.YLim(1), DELTA_FRAME, sig_axes.YLim(2)-sig_axes.YLim(1)], ...
            'FaceColor', [0,1,0,0.2] ...
            );
    axis(sig_axes, 'tight');
    
    fourier = fft( sig(frame1(dx)) );
    plot(fourier_axes, abs(fourier));
    fourier_axes.YLim = [0 10000];
end