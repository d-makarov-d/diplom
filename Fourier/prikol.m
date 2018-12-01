function prikol()
    global dots fuel x y;
    dots = zeros(0,81);
    fuel = 20;
    x =0;
    y =0;
    i=1;
    for X = -4:4
        for Y = -4:4
            dots(i).x = X;
            dots(i).y = Y;
            dots(i).p = true;
            i = i+1;
        end
    end
    while isempty()
        move();
    end
end

function [r,dot] = get_closest(x,y)
    global dots;
    r = Inf;
    ind = 1;
    for i=1:length(dots)
        tmp_r = abs(dots(i).x-x) + abs(dots(i).y-y);
        if tmp_r < r && dots(i).p && tmp_r ~=0
            r = tmp_r;
            ind = i;
        end
    end
    dot = dots(ind);
end

function a =isempty()
    global dots;
    a = false;
    for i=1:length(dots)
        if dots(i).p
            a = true;
            break;
        end
    end
end

function move()
    global fuel x y;
    [r,next] = get_closest(x,y);
    if (2*r + 4)>fuel
        go(0,0);
        fuel = 20;
    else
        go(next.x, next.y);
    end
end

function go(X,Y)
    global x y fuel;
    while X ~= x || Y ~= y
        if x<X
            x = x+1;
            mark(x,y);
            fuel = fuel -1;
        elseif x>X
            x = x-1;
            mark(x,y);
            fuel = fuel -1;
        end
        if y<Y
            y = y+1;
            mark(x,y);
            fuel = fuel -1;
        elseif y>Y
            y = y-1;
            mark(x,y);
            fuel = fuel -1;
        end
        disp(fuel);
        pl();
    end
end

function pl()
    global dots x y;
    cla;
    hold on;
    for i=1:length(dots)
        if dots(i).p
            plot(dots(i).x, dots(i).y, 'r.');
        else
            plot(dots(i).x, dots(i).y, 'g.');
        end
    end
    plot(x,y, 'or');
    pause(0.3);
    hold off;
end

function mark(x,y)
    global dots;
    for i=1:length(dots)
        if dots(i).x == x && dots(i).y == y
            dots(i).p = false;
            break;
        end
    end
end