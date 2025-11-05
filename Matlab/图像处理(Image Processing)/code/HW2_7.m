matrix = reshape(1:64, 8, 8)'; % 创建8x8测试矩阵
fprintf('原始8x8矩阵:\n');
disp(matrix);

result = zigzag(matrix); % 执行Zig-Zag扫描
fprintf('Zig-Zag扫描结果:\n');
disp(result);

% 显示扫描顺序
fprintf('扫描顺序:\n');
order = zeros(8, 8);
for i = 1:64
    [row, col] = find(matrix == result(i));
    order(row, col) = i;
end
disp(order);

%% Zig-Zag扫描函数
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