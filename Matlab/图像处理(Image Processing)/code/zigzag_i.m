function matrix = zigzag_i(vector, m, n)
    matrix = zeros(m, n);
    counter = 1;
    
    for s = 1:(m + n - 1)
        if mod(s, 2) == 0 % 偶数对角线，向下扫描
            for i = max(1, s - n + 1) : min(s, m)
                j = s - i + 1;
                matrix(i, j) = vector(counter);
                counter = counter + 1;
            end
        else % 奇数对角线，向上扫描
            for i = min(s, m) : -1 : max(1, s - n + 1)
                j = s - i + 1;
                matrix(i, j) = vector(counter);
                counter = counter + 1;
            end
        end
    end
end