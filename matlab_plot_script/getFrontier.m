function [xo, yo] = getFrontier (xi, yi)
    [x2, index] = sort(xi);
    y2 = yi(index);
    k = 1;
    for i = 1:length(x2)
        flag = true;
        for j = 1:length(x2)
            if ( x2(j) <= x2(i) && y2(j) < y2(i))
                flag = false;
                break
            end
        end
        if ( flag == true)
            xo(k) = x2(i);
            yo(k) = y2(i);
            k = k +1;
        end
    end
end