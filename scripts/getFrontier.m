function [xo, yo, index] = getFrontier (xi, yi)
    [x2, idx] = sort(xi);
    y2 = yi(idx);
    k = 1;
    xo = [];
    yo = [];
    index = [];
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
            index(k,1) = idx(i);
            k = k +1;
        end
    end
end