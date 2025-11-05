function [DC_ans, AC_ans, h, w] = JPEG_encode(image_ori, QTAB, DCTAB, ACTAB)
    [h, w] = size(image_ori);
    im = double(image_ori) - 128;
    
    Co = trans(im, QTAB); % 求系数矩阵，参数是预处理后的图像和标准量化表
    
    % DC系数处理
    DC = Co(1, :); % DC系数是系数矩阵的第一行
    DC_ans = DCencode(DC, DCTAB); % DPCM差分编码 + Huffman编码
    
    % AC系数处理
    AC = Co(2:end, :); % AC系数是系数矩阵除了第一行的部分
    AC_ans = [];
    n = w * h / 64; % 块数
    
    for idx = 1 : n % 遍历所有子块
        AC_idx = AC(:, idx)'; % 得到当前块的所有AC系数
        AC_block = ACencode(AC_idx, ACTAB); % 游程编码 + Huffman编码
        AC_ans = [AC_ans, AC_block]; % 合并AC熵编码
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

%% DC系数编码函数
function DC_ans = DCencode(DC, DCTAB)
    DC_ans = [];
    DC = [DC(1), -diff(DC)]; % DPCM差分编码
    
    for block = 1:length(DC)
        mag = DC(block); % 计算Magnitude
        
        % 计算Category
        if mag == 0
            cat = 0;
        else
            cat = ceil(log2(abs(mag) + 1)); % Category计算公式
        end
        
        % 获取Huffman码字
        code_length = DCTAB(cat + 1, 1); % 获取码字长度
        huffman = DCTAB(cat + 1, 2:code_length + 1); % 获取对应码字内容
        
        % 幅度值二进制编码
        if mag > 0
            mag_bin = double(dec2bin(mag, cat)) - 48; % dec2bin将正数转换为指定位数的二进制字符串，-48将字符转换为数字
        elseif mag < 0
            mag_bin = double(dec2bin(2^cat + mag - 1, cat)) - 48; % 负数用补码表示
        else
            mag_bin = [];
        end
       
        DC_ans = [DC_ans, huffman, mag_bin]; % 组合DC熵编码
    end
end

%% AC系数编码函数
function AC_ans = ACencode(AC_idx, ACTAB)
    AC_ans = [];    
    nzero_pos = find(AC_idx); % 找到所有非零系数的位置
    
    if isempty(nzero_pos)
        AC_ans = [1, 0, 1, 0];  % 如果全为0，直接使用EOB结束符并返回
        return;
    end
    
    % 计算零游程长度
    if nzero_pos(1) == 1 % 第一个系数非零
        run_length = [0, diff(nzero_pos) - 1]; % 相邻非零系数位置的差值减去当前非零系数本身的位置即为0的个数
    else
        run_length = [nzero_pos(1) - 1, diff(nzero_pos) - 1];
    end
    
    % 处理每个非零系数
    for idx = 1:length(nzero_pos)
        run = run_length(idx);
        amp = AC_idx(nzero_pos(idx));
        
        % 处理长零游程
        while run > 15
            AC_ans = [AC_ans, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1]; % 插入ZRL符号
            run = run - 16;
        end
        
        % 计算size
        if amp == 0
            size = 0;
        else
            size = ceil(log2(abs(amp) + 1)); % Size和DC编码的Category计算公式相同
        end
        
        % 获取Huffman码字
        index = find(ACTAB(:, 1) == run & ACTAB(:, 2) == size, 1); % Run/Size      
        code_length = ACTAB(index, 3); % 获取码字长度
        huffman = ACTAB(index, 4:code_length + 3); % 获取对应码字内容
        
        % 幅度值二进制编码，类似DC编码过程
        if amp > 0
            amp_bin = double(dec2bin(amp, size)) - 48; % dec2bin将正数转换为指定位数的二进制字符串，-48将字符转换为数字
        elseif amp < 0
            amp_bin = double(dec2bin(2^size + amp - 1, size)) - 48; % 负数用补码表示
        else
            amp_bin = [];
        end
       
        AC_ans = [AC_ans, huffman, amp_bin]; % 组合AC熵编码
    end
    
    AC_ans = [AC_ans, 1, 0, 1, 0];  % 插入块结束符EOB
end