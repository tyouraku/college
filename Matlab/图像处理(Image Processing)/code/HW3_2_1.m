load ('hall.mat');
load ('JpegCoeff.mat');

[h, w] = size(hall_gray);
im = double(hall_gray) - 128; % 图像预处理

Co = trans(im, QTAB); % 分块，DCT变换，量化

info = double(randi([0, 1], 1000, 1)); % 生成1000比特的随机信息
pad = zeros(h * w - 1000, 1); % 填充剩余位置
info1 = cat(1, info, pad); % 合并成能覆盖图像所有位置的信息

Co_bin = dec2bin(Co); % 把系数转为二进制
Co_bin(:, end) = dec2bin(info1); % 在LSB存储隐藏信息
Co = zeros(size(Co));
for idx = 1 : numel(Co)
    if Co_bin(idx, 1) == '1' % 负数
        Co(idx) = bin2dec(Co_bin(idx, :)) - 256; % 补码处理
    else % 正数
        Co(idx) = bin2dec(Co_bin(idx, :));
    end
end

DC = Co(1, :); % 在系数矩阵中提取DC系数
DC_ans1 = DCencode(DC, DCTAB); % 对DC系数编码

AC = Co(2 : end, :); % 在系数矩阵中提取AC系数
AC_ans1 = [];
for idx = 1 : w * h / 64
    AC_idx = AC(:, idx)';
    AC_block = ACencode(AC_idx, ACTAB); % 对AC系数编码
    AC_ans1 = [AC_ans1 AC_block]; % 拼合所有块的AC系数
end

comp = h * w * 8 / (length(DC_ans1) + length(AC_ans1)); % 计算压缩比
fprintf("压缩比为%.3f\n", comp);

image = zeros(h, w);
block = h * w / 64;

DC_ans2 = DCdecode(DC_ans1, DCTAB, block); % 对DC系数解码
AC_ans2 = ACdecode(AC_ans1, ACTAB, block); % 对AC系数解码
im_ans2 = cat(1, DC_ans2, AC_ans2);

info2 = dec2bin(im_ans2); % 转换为二进制方便提取
info2 = bin2dec(info2(:, end)); % 提取隐藏在LSB的信息
acc = length(find(info == info2(1:1000))) / 1000; % 计算信息提取准确率
fprintf("信息恢复准确率为%.2f%%\n", acc * 100);

wb = w / 8;
hb = h / 8;

for i = 1 : hb
    for j = 1 : wb
        Co = im_ans2(:, (i - 1) * wb + j)'; % 获取当前块的系数向量
        im = zigzag_i(Co, 8, 8); % 使用反向zigzag扫描将向量转换为8x8矩阵
        
        im = im .* QTAB; % 逆向量化
        im = idct2(im); % 逆DCT变换
        image((8 * i - 7) : 8 * i, (8 * j - 7) : 8 * j) = im; % 将块放置在完整图像中的正确位置
    end
end
image = uint8(image + 128); % 逆向预处理操作

% 计算PSNR
MSE = sum(sum((double(image) - double(hall_gray)).^2)) / (w * h);
PSNR = 10 * log10(255^2 / MSE);

fprintf("PSNR为%.3f\n", PSNR);

figure; imshow(hall_gray, 'InitialMagnification', 'fit'); title('原图');
figure; imshow(image, 'InitialMagnification', 'fit'); title('隐藏信息图');