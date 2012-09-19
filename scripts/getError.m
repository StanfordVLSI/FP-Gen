%
% Xi - point of interest
% Y_1, Y_2 - input data aray which might not be defined in Xi
% X_1, X_2 - points wher Y_1 and Y_2 are defined
%
% Using interpolation calculate relative difference between Y_1 and Y_2
% in points defined by Xi. 


function [Err] = getError (Xi, X_1, Y_1, X_2, Y_2)

    [b, ind_1, n] = unique(Y_1);
    [b, ind_2, n] = unique(Y_2);

    Y_1_i = interp1(X_1(ind_1,:),Y_1(ind_1,:), Xi);
    Y_2_i = interp1(X_2(ind_2,:),Y_2(ind_2,:), Xi);
    Err = 100.*(Y_1_i-Y_2_i)./Y_2_i;
    
end