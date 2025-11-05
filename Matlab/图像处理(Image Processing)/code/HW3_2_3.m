load ('hall.mat');
load ('JpegCoeff.mat');

[h, w] = size(hall_gray);
im = double(hall_gray) - 128; % 图像预处理

Co = trans(im, QTAB); % 分块，DCT变换，量化

% 生成信息序列，长度为块数（w*h/64），每个块隐藏1比特信息
info = double(randi([0, 1], 1, w * h / 64));
info = info * 2 - 1; % 转换为±1序列：0→-1，1→1

% 隐藏信息到DCT系数中
for i = 1 : w * h / 64
    idx = find(Co(:, i)); % 找到当前块中非零系数的位置
    if isempty(idx)
        Co(2, i) = info(1, i); % 如果全为零，在第一个AC系数位置隐藏信息
    else
        if idx(end) == 64
            Co(64, i) = info(1, i); % 如果最后一个系数非零，用信息位替换该系数
        else
            Co(idx(end) + 1, i) = info(1, i); % 在最后一个非零系数后追加信息
        end
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

% 从DCT系数中提取隐藏信息
info1 = zeros(1, w * h / 64);
for i = 1 : w * h / 64
    idx = find(im_ans2(:, i)); % 找到当前块中非零系数的位置
    if ~isempty(idx)
        info1(1, i) = im_ans2(idx(end), i);
    end
end

% 计算信息提取准确率
accuracy = length(find(info == info1)) / (w * h / 64);
fprintf("信息恢复准确率为%.2f%%\n", accuracy * 100);

wb = w / 8;
hb = h / 8;

for i = 1 : hb
    for j = 1 : wb
        Co_block = im_ans2(:, (i - 1) * wb + j)'; % 获取当前块的系数向量
        im_block = zigzag_i(Co_block, 8, 8); % 使用反向zigzag扫描将向量转换为8x8矩阵
        
        im_block = im_block .* QTAB; % 逆向量化
        im_block = idct2(im_block); % 逆DCT变换
        image((8 * i - 7) : 8 * i, (8 * j - 7) : 8 * j) = im_block; % 将块放置在完整图像中的正确位置
    end
end
image = uint8(image + 128); % 逆向预处理操作

% 计算PSNR
MSE = sum(sum((double(image) - double(hall_gray)).^2)) / (w * h);
PSNR = 10 * log10(255^2 / MSE);

fprintf("PSNR为%.3f\n", PSNR);

figure; imshow(hall_gray, 'InitialMagnification', 'fit'); title('原图');
figure; imshow(image, 'InitialMagnification', 'fit'); title('隐藏信息图');