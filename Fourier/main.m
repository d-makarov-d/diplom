%22890216.adb - не шум
%22880207.adb - шум

function fourier_fig = main()
    global fourier_axes fourier_mouse_btn_pressed regions add text T fft_sig;
    regions = matlab.graphics.primitive.Rectangle.empty;
    fourier_mouse_btn_pressed = 0;
    add = 0;
    %file reading in mkm/sec
    [y,par]=adb_read('22880207.adb','s',0);
    %time vector, T in seconds
    T=(0:length(y)-1)/par.fs;
    %fft signal
    sig = y(:,2)-mean(y(:,2));
    fft_sig = fft(sig);

    %figure
    fourier_fig = figure('Name','Fourier','NumberTitle','off', 'InnerPosition', [10,100,900,400]);
    add_btn = uicontrol(fourier_fig, ...
        'String', 'Add', ...
        'Style', 'pushbutton', ...
        'Position', [20 20 50 20], ...
        'Callback', @add_callback);
    plot_btn = uicontrol(fourier_fig, ...
        'String', 'Plot', ...
        'Style', 'pushbutton', ...
        'Position', [fourier_fig.InnerPosition(3)./2-10, 20 50 20], ...
        'Callback', @plot_callback);
    clear_btn = uicontrol(fourier_fig, ...
        'String', 'Clear', ...
        'Style', 'pushbutton', ...
        'Position', [fourier_fig.InnerPosition(3)-70 20 50 20], ...
        'Callback', @clear_callback);
    fourier_axes = axes(fourier_fig, 'Position',[0.1 0.2 0.8 0.7]);
    plot(fourier_axes,T,abs(fft_sig));
    text = annotation(fourier_fig, 'textbox', ...
    'Position', [0.4, 0.92, 0.2, 0.05], ...
    'HorizontalAlignment', 'center' ...
    );
    text.EdgeColor = text.BackgroundColor;
    
    fourier_fig.WindowButtonDownFcn = @mouse_btn_down;
    fourier_fig.WindowButtonUpFcn = @mouse_btn_up;
    fourier_fig.WindowButtonMotionFcn = @mouse_btn_motion;
end

function add_callback(source, event)
    global add text;
    add = 1;
    text.String = 'add';
end

function plot_callback(source, event)
    global fft_sig T regions;
    new_fft = fft_sig;
    mask = zeros(size(T));
    for n = 1:length(regions)
        b1 = T>regions(n).Position(1);
        b2 = (T<(regions(n).Position(1)+regions(n).Position(3)));
        t = (b1+b2) == 2;
        mask = mask + t;
    end
    mask = mask == 1;
    new_fft(mask) = 0;
    
    new_fourier_fig = figure('Name','New fourier','NumberTitle','off');
    fourier_axes = axes(new_fourier_fig, 'Position',[0.1 0.1 0.8 0.8]);
    plot(fourier_axes,T,abs(new_fft));
    
    sig_fig = figure('Name','Signal','NumberTitle','off');
    sig_axes = axes(sig_fig, 'Position',[0.1 0.1 0.8 0.8]);
    new_sig = real(ifft(new_fft))*5;
    plot_sg_ax(sig_axes,new_sig,T,27,80);
    hold on;
    %plot_sg_ax(sig_axes,abs(hilbert(new_sig)),T,27,80);
end

function clear_callback(source, event)
    global fourier_axes T fft_sig regions;
    regions = matlab.graphics.primitive.Rectangle.empty;
    hold off;
    plot(fourier_axes,T,abs(fft_sig));
end

function mouse_btn_down(source, event)
    global fourier_axes fourier_mouse_btn_pressed regions add;
    x = fourier_axes.CurrentPoint(1,1);
    y = fourier_axes.CurrentPoint(1,2);
    if add
        fourier_mouse_btn_pressed = 1;
        hold on
        regions(length(regions)+1) = rectangle('Position', [ x, 0, 1, fourier_axes.YLim(2)-fourier_axes.YLim(1)], ...
            'FaceColor', [0,1,0,0.2] ...
            );
    end
end

function mouse_btn_up(source, event)
    global fourier_mouse_btn_pressed add text regions T;
    fourier_mouse_btn_pressed = 0;
    %x = fourier_axes.CurrentPoint(1,1);
    %y = fourier_axes.CurrentPoint(1,2);
    
    if add
        pos = regions(length(regions)).Position;
        m = max(T);
        regions(length(regions)+1) = rectangle('Position', [m - pos(1)-pos(3), pos(2), pos(3), pos(4)], ...
                'FaceColor', [0,1,0,0.2] ...
                );
    end
    add = 0;
    text.String = '';
end

function mouse_btn_motion(source, event)
    global fourier_axes fourier_mouse_btn_pressed regions;
    if fourier_mouse_btn_pressed
        x = fourier_axes.CurrentPoint(1,1);
        %y = fourier_axes.CurrentPoint(1,2);
        hold on
        if x < regions(length(regions)).Position(1)
            regions(length(regions)).Position(3) = regions(length(regions)).Position(3) + regions(length(regions)).Position(1)-x;
            regions(length(regions)).Position(1) = x;
        end
        if x > regions(length(regions)).Position(1) && x < regions(length(regions)).Position(1) + regions(length(regions)).Position(3)
            if x - regions(length(regions)).Position(1) < regions(length(regions)).Position(1) + regions(length(regions)).Position(3) - x
                regions(length(regions)).Position(3) = regions(length(regions)).Position(3) + regions(length(regions)).Position(1)-x;
                regions(length(regions)).Position(1) = x;
            else
                regions(length(regions)).Position(3) = x - regions(length(regions)).Position(1);
            end
        end
        if x > regions(length(regions)).Position(1) + regions(length(regions)).Position(3)
            regions(length(regions)).Position(3) = x - regions(length(regions)).Position(1);
        end
    end
end

function a = check_hit(x,y)
    a = 1;
    
end