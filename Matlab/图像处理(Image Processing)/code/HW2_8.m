% 加载数据
load('hall.mat');
load('JpegCoeff.mat');

% 图像预处理
im = double(hall_gray) - 128;
[h, w] = size(im);

Co = trans(im, QTAB); % 求系数矩阵，参数是预处理后的图像和标准量化表

% 显示结果
fprintf('系数矩阵尺寸: %d x %d\n', size(Co));
fprintf('DC系数: ');
disp(Co(1, :));

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

%% 系数矩阵计算函数
function Co = trans(im, QTAB)
    [h, w] = size(im);
    %分成多个8*8大小的子块
    wp = w / 8;
    hp = h / 8;
    
    Co = zeros(64, wp * hp); % 初始化系数矩阵
    idx = 1; % 初始化索引
    
    for i = 1 : 8: h % 遍历每一行
        for j = 1 : 8: w % 遍历每一列
            block = im(i : i + 7, j : j + 7); % 对图像分块
            dct = dct2(block); % DCT变换
            quant = round(dct ./ QTAB); % 量化
            Zigzag = zigzag(quant); % Zig-Zag扫描
            Co(:, idx) = Zigzag'; % 存储结果，zigzag函数返回的是行向量，需要转置
            idx = idx + 1;
        end
    end
end