load ('hall.mat');
load ('JpegCoeff.mat');

[h, w] = size(hall_gray);
im = double(hall_gray) - 128; % 图像预处理

Co = trans(im, QTAB); % 分块，DCT变换，量化

info = double(randi([0, 1], 1000, 1)); % 生成1000比特的随机信息

% 选择要嵌入信息的系数位置（不是所有系数都嵌入）
num = 20; % 每个块中嵌入信息的系数数量
block = w * h / 64;
pos = zeros(num, block);

for idx = 1 : block
    pos_idx = randperm(63, num) + 1; % 在每个块中随机选择num个位置，+1跳过DC系数
    pos(:, idx) = pos_idx;
end

% 将信息嵌入到选定的系数位置
info_idx = 1; % 信息索引
Co_bin = dec2bin(Co); % 把系数转为二进制
for idx = 1 : block
    for pos_idx = 1 : num
        if info_idx > length(info)
            break; % 所有信息都已隐藏，则提前返回
        end
        linear_idx = (idx - 1) * 64 + pos(pos_idx, idx); % 线性索引计算
        Co_bin(linear_idx, end) = dec2bin(info(info_idx)); % 在LSB存储隐藏信息
        info_idx = info_idx + 1;
    end
    if info_idx > length(info)
        break; % 所有信息都已隐藏，则提前返回
    end
end

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
for idx = 1 : block
    AC_idx = AC(:, idx)'; % 每个块的AC系数（行向量）
    AC_block = ACencode(AC_idx, ACTAB); % 对AC系数编码
    AC_ans1 = [AC_ans1 AC_block]; % 拼合所有块的AC系数
end

comp = h * w * 8 / (length(DC_ans1) + length(AC_ans1)); % 计算压缩比
fprintf("压缩比为%.3f\n", comp);

image = zeros(h, w);

DC_ans2 = DCdecode(DC_ans1, DCTAB, block); % 对DC系数解码
AC_ans2 = ACdecode(AC_ans1, ACTAB, block); % 对AC系数解码
im_ans2 = [DC_ans2; AC_ans2];

% 提取隐藏的信息
info1 = [];
info_idx = 1;

for idx = 1 : block
    for pos_idx = 1 : num
        if info_idx > length(info)
            break; % 如果所有信息都已找到，则提前返回
        end
        info2 = dec2bin(im_ans2(pos(pos_idx, idx), idx)); % 转换为二进制方便提取
        info2 = bin2dec(info2(end)); % 提取隐藏在LSB的信息
        info1 = [info1; info2];
        info_idx = info_idx + 1; % 移动到下一个存储位置
    end
    if info_idx > length(info)
        break; % 如果所有信息都已找到，则提前返回
    end
end

acc = length(find(info == info1(1:length(info)))) / length(info); % 计算信息提取准确率
fprintf("信息恢复准确率为%.2f%%\n", acc * 100);

wb = w / 8;
hb = h / 8;

for i = 1 : hb
    for j = 1 : wb
        idx = (i - 1) * wb + j;
        Co_block = im_ans2(:, idx)'; % 获取当前块的系数向量
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