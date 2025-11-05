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