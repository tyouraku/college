%% 编码过程
load('hall.mat');
load('JpegCoeff.mat');

[DC_ans, AC_ans, h, w] = JPEG_encode(hall_gray, QTAB / 2, DCTAB, ACTAB);

save('jpegcodes1.mat', 'DC_ans', 'AC_ans', 'h', 'w'); % 保存结果到jpegcodes1.mat
    
% 计算并显示
comp = w * h * 8 / (length(DC_ans) + length(AC_ans)); % 压缩比 = 输入文件长度（像素数 * 每个像素8bit） / 输出码流长度
fprintf('图像尺寸: %d x %d\n', h, w);
fprintf('DC码流长度: %d bits\n', length(DC_ans));
fprintf('AC码流长度: %d bits\n', length(AC_ans));
fprintf('总码流长度: %d bits\n', length(DC_ans) + length(AC_ans));
fprintf('压缩比: %.3f:1\n', comp);

%% 解码过程
load('jpegcodes1.mat');

image = JPEG_decode(DC_ans, AC_ans, h, w, QTAB / 2, DCTAB, ACTAB);

% 计算并显示
MSE = sum(sum((double(image) - double(hall_gray)).^2)) / (h * w);
PSNR = 10 * log10(255^2 / MSE); % 计算PSNR
fprintf('PSNR: %.3f dB\n', PSNR);

figure; imshow(hall_gray, 'InitialMagnification', 'fit'); title('原始图像');
figure; imshow(image, 'InitialMagnification', 'fit'); title('解码图像');