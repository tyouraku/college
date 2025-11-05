%% 编码过程
load('snow.mat');
load('JpegCoeff.mat');

[DC_ans, AC_ans, h, w] = JPEG_encode(snow, QTAB, DCTAB, ACTAB);

save('jpegcodes_snow.mat', 'DC_ans', 'AC_ans', 'h', 'w'); % 保存结果到jpegcodes_snow.mat
    
% 计算并显示
comp = w * h * 8 / (length(DC_ans) + length(AC_ans)); % 压缩比 = 输入文件长度（像素数 * 每个像素8bit） / 输出码流长度
fprintf('图像尺寸: %d x %d\n', h, w);
fprintf('DC码流长度: %d bits\n', length(DC_ans));
fprintf('AC码流长度: %d bits\n', length(AC_ans));
fprintf('总码流长度: %d bits\n', length(DC_ans) + length(AC_ans));
fprintf('压缩比: %.3f:1\n', comp);

%% 解码过程
load('jpegcodes_snow.mat');

image = JPEG_decode(DC_ans, AC_ans, h, w, QTAB, DCTAB, ACTAB);

% 计算并显示
MSE = sum(sum((double(image) - double(snow)).^2)) / (h * w);
PSNR = 10 * log10(255^2 / MSE); % 计算PSNR
fprintf('PSNR: %.3f dB\n', PSNR);

figure; imshow(snow, 'InitialMagnification', 'fit'); title('原始图像');
figure; imshow(image, 'InitialMagnification', 'fit'); title('解码图像');