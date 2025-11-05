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