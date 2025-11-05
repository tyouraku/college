function image = JPEG_decode(DC_ans, AC_ans, h, w, QTAB, DCTAB, ACTAB)
    % 初始化参数
    block = h * w / 64;
    wb = w / 8;
    hb = h / 8;
    image = zeros(h, w);
    
    DC_ans1 = DCdecode(DC_ans, DCTAB, block); % DC系数解码
    AC_ans1 = ACdecode(AC_ans, ACTAB, block); % AC系数解码
    im_ans1 = cat(1, DC_ans1, AC_ans1); % 合并DC和AC系数
    
    for i = 1 : hb
        for j = 1 : wb
            Co = im_ans1(:, (i - 1) * wb + j); % 获取当前块的系数向量
            im = zigzag_i(Co, 8, 8); % 使用反向zigzag扫描将向量转换为8x8矩阵
            im = im .* QTAB; % 逆向量化
            im = idct2(im); % 逆DCT变换     
            image((8 * i - 7):8 * i, (8 * j - 7):8 * j) = im; % 将块放置在完整图像中的正确位置
        end
    end
    image = uint8(image + 128); % 逆向预处理操作
end

%% 逆向Zig-Zag扫描函数
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

%% DC解码函数
function DC_ans1 = DCdecode(DC_ans, DCTAB, block)
    DC_ans1 = zeros(1, block); % 创建空矩阵存储DC系数
    count = 1; % 当前块位置
    i = 1; % 编码位置
    
    while i <= size(DC_ans, 2) && count <= block
        for j = 1:size(DCTAB, 1)
            code_length = DCTAB(j, 1); % Huffman编码长度
            if i + code_length - 1 <= size(DC_ans, 2) && all(DCTAB(j, 2 : 1 + code_length) == DC_ans(1, i : i + code_length - 1))
                i = i + code_length; % 跳过Huffman编码
                cat = j - 1; % 计算幅度值类别
                if cat == 0 
                    DC_ans1(1, count) = 0;
                else
                    if i + cat - 1 <= size(DC_ans, 2)
                        mag = DC_ans(1, i : i + cat - 1); % 读取幅度值比特
                        % 解码幅度值
                        if mag(1) == 1
                            DC_ans1(1, count) = bin2dec(char(mag + '0')); % 正数直接转十进制
                        else
                            DC_ans1(1, count) = -bin2dec(char(~mag + '0')); % 负数先取反转十进制再加负号
                        end
                        i = i + cat;
                    end
                end
                count = count + 1;
                break;
            end
        end
    end
    
    for n = 2 : block
        DC_ans1(1, n) = DC_ans1(1, n - 1) - DC_ans1(1, n); % 差分解码
    end
end

%% AC解码函数
function AC_ans1 = ACdecode(AC_ans, ACTAB, block)
    AC_ans1 = zeros(block, 63);  % 创建空矩阵存储63个AC系数
    block = 1; % 当前处理的块编号
    count = 1; % 当前块内AC系数位置
    i = 1; % 编码位置
    ZRL = [1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1];
    EOB = [1, 0, 1, 0];
    
    while i <= size(AC_ans, 2) % 编码位置不超过AC编码长度时
        if i + length(EOB) - 1 <= size(AC_ans, 2) && all(EOB == AC_ans(1, i:i+length(EOB)-1)) % 遇到EOB表示当前块的所有AC系数都已解码完毕
            count = 1; % 重置系数位置
            i = i + length(EOB); % 移动编码位置
            block = block + 1; % 移动到下一个块
            
        elseif i + length(ZRL) - 1 <= size(AC_ans, 2) && all(ZRL == AC_ans(1, i:i+length(ZRL)-1)) % 遇到ZRL直接填充16个零，避免逐个解码
            AC_ans1(block, count:count+15) = 0; % 直接填充16个0
            count = count + 16; % 移动系数位置
            i = i + length(ZRL); % 移动编码位置
            
        else % 一般情况
            for j = 1 : size(ACTAB, 1)
                code_length = ACTAB(j, 3); % Huffman编码长度
                if i + code_length - 1 <= size(AC_ans, 2) && all(ACTAB(j, 4 : 3 + code_length) == AC_ans(1, i : i + code_length - 1))
                    i = i + code_length; % 跳过Huffman编码
                    run = ACTAB(j, 1); % 零游程长度
                    size_bit = ACTAB(j, 2); % 幅度值比特数
                    
                    % 添加零游程
                    AC_ans1(block, count : count + run) = 0;
                    count = count + run;
                    
                    % 解码幅度值
                    if size_bit > 0
                        if i + size_bit - 1 <= size(AC_ans, 2)
                            amplitude = AC_ans(1, i : i + size_bit - 1);
                            if amplitude(1) == 1
                                AC_ans1(block, count) = bin2dec(char(amplitude + '0')); % 正数直接转十进制
                            else
                                AC_ans1(block, count) = -bin2dec(char(~amplitude + '0')); % 负数先取反转十进制再加负号
                            end
                            count = count + 1;
                            i = i + size_bit;
                        end
                    end
                    break;
                end
            end
        end
    end
    AC_ans1 = AC_ans1';
end