load('hall.mat');
load('JpegCoeff.mat');

n = 10;  % 试验次数
msg_length = 1000;  % 测试1000个比特
fprintf('试验次数: %d\n', n);

% 初始化统计变量
acc1 = zeros(1, n); % JPEG编码前正确率
acc2 = zeros(1, n); % JPEG编码后正确率
PSNR = zeros(1, n); % PSNR

for i = 1 : n    
    msg_bits = randi([0, 1], 1, msg_length); % 生成随机测试信息
    row0 = 50; col0 = 50; % 隐藏信息的初始行列
    image_LSB = LSB_hide(hall_gray, msg_bits, row0, col0); % 空域信息隐藏（LSB替换）
    extracted_bits = LSB_seek(image_LSB, msg_length, row0, col0); % 从含密图像中提取信息
    
    % 计算未进行JPEG编码时的正确率
    err1 = sum(extracted_bits ~= msg_bits) / msg_length * 100;
    acc1(i) = 100 - err1;
    
    % 对图像进行JPEG编码和解码
    [DC_ans, AC_ans, h, w] = JPEG_encode(image_LSB, QTAB, DCTAB, ACTAB);
    image_JPEG = JPEG_decode(DC_ans, AC_ans, h, w, QTAB, DCTAB, ACTAB);
    
    % 计算PSNR
    MSE = sum(sum((double(image_JPEG) - double(image_LSB)).^2)) / (h * w);
    PSNR(i) = 10 * log10(255^2 / MSE);
    
    msg_bits1 = LSB_seek(image_JPEG, msg_length, row0, col0); % 从JPEG编码后的图像中提取信息
    
    % 计算正确率
    err2 = sum(msg_bits1 ~= msg_bits) / msg_length * 100;
    acc2(i) = 100 - err2;
end

% 计算平均值和标准差
acc1_mean = mean(acc1);
acc1_std = std(acc1);
acc2_mean = mean(acc2);
acc2_std = std(acc2);
PSNR_mean = mean(PSNR);
PSNR_std = std(PSNR);

% 显示结果
fprintf('未编码时平均正确率: %.2f%% ± %.2f%%\n', acc1_mean, acc1_std);
fprintf('JPEG编码后平均正确率: %.2f%% ± %.2f%%\n', acc2_mean, acc2_std);
fprintf('平均PSNR: %.2f dB ± %.2f dB\n', PSNR_mean, PSNR_std);

figure;
subplot(2,1,1);
plot(1:n, acc1, 'bo-', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
hold on;
plot(1:n, acc2, 'ro-', 'LineWidth', 1.5, 'MarkerFaceColor', 'r');
title('正确率');
xlabel('试验次数');
ylabel('正确率 (%)');
legend('JPEG编码前', 'JPEG编码后');
grid on;

subplot(2,1,2);
plot(1:n, PSNR, 'go-', 'LineWidth', 1.5, 'MarkerFaceColor', 'g');
title('PSNR');
xlabel('试验次数');
ylabel('PSNR (dB)');
grid on;

%% 辅助函数定义
function image_LSB = LSB_hide(image, msg_bits, row0, col0)
    image_LSB = image;
    [h, w] = size(image); % 获取图像尺寸
    msg_idx = 1; % 初始化信息索引
    
    for row = row0 : h % 遍历图像的每行每列
        for col = col0 : w
            if msg_idx > length(msg_bits) % 如果所有信息都已隐藏，则提前返回
                return;
            end
            image_LSB(row, col) = bitset(image_LSB(row, col), 1, msg_bits(msg_idx)); % 修改像素的LSB用于隐藏信息
            msg_idx = msg_idx + 1; % 移动到下一个要隐藏的信息比特
        end
    end
end

function bits = LSB_seek(image_JPEG, msg_length, row0, col0)
    bits = zeros(1, msg_length);
    [h, w] = size(image_JPEG); % 获取图像尺寸
    msg_idx = 1; % 初始化信息索引
    
    for row = row0 : h % 遍历图像的每行每列
        for col = col0 : w
            if msg_idx > msg_length % 如果所有信息都已找到，则提前返回
                return;
            end
            bits(msg_idx) = bitget(image_JPEG(row, col), 1); % 读取像素的最低位
            msg_idx = msg_idx + 1; % 移动到下一个存储位置
        end
    end
end