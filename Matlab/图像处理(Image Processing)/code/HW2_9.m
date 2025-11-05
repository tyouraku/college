load('hall.mat');
load('JpegCoeff.mat');

[DC_ans, AC_ans, h, w] = JPEG_encode(hall_gray, QTAB, DCTAB, ACTAB);

save('jpegcodes.mat', 'DC_ans', 'AC_ans', 'h', 'w'); % 保存结果到jpegcodes.mat
    
% 计算并显示
comp = w * h * 8 / (length(DC_ans) + length(AC_ans)); % 压缩比 = 输入文件长度（像素数 * 每个像素8bit） / 输出码流长度
fprintf('图像尺寸: %d x %d\n', h, w);
fprintf('DC码流长度: %d bits\n', length(DC_ans));
fprintf('AC码流长度: %d bits\n', length(AC_ans));
fprintf('总码流长度: %d bits\n', length(DC_ans) + length(AC_ans));
fprintf('压缩比: %.3f:1\n', comp);