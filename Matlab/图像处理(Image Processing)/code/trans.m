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