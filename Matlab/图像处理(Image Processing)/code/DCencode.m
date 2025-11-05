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