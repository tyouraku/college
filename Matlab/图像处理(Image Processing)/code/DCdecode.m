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