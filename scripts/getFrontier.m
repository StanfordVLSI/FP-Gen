function [xo, yo] = getFrontier (xi, yi)
    [x2, index] = sort(xi);
    y2 = yi(index);
    k = 1;
    xo = [];
    yo = [];
    for i = 1:length(x2)
        if(isnan(y2(i)) || isnan(x2(i)))
            continue;
        end
        flag = true;
        for j = 1:length(x2)
            if ( x2(j) <= x2(i) && y2(j) < y2(i) * 1)
                flag = false;
                break
            end
        end
        if ( flag == true)
            xo(k,1) = x2(i);
            yo(k,1) = y2(i);
            k = k +1;
        end
    end
end