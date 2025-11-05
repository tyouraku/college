function result = zigzag(matrix)
    [m, n] = size(matrix); % 获取矩阵尺寸
    result = zeros(1, m * n); % 初始化结果矩阵
    
    counter = 1; % 结果矩阵计数器
    for s = 1:(m + n - 1) % 遍历所有对角线
        if mod(s, 2) == 0 % 偶数对角线，向下扫描
            for i = max(1, s - n + 1):min(s, m) % 行数的范围
                j = s - i + 1; % 计算对应元素的列数
                result(counter) = matrix(i, j);
                counter = counter + 1;
            end
        else % 奇数对角线，向上扫描
            for i = min(s, m):-1:max(1, s - n + 1) % 行数的范围
                j = s - i + 1; % 计算对应元素的列数
                result(counter) = matrix(i, j);
                counter = counter + 1;
            end
        end
    end
end