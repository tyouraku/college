load('hall.mat');
im = double(hall_gray) - 128;

%% 对全图操作
dct_t = @(P) set_t(dct2(P));
dct_90 = @(P) set_90(dct2(P));
dct_180 = @(P) set_180(dct2(P));

% 分块处理整个图像
C1 = blockproc(im, [8, 8], @(block) dct_t(block.data));
C2 = blockproc(im, [8, 8], @(block) dct_90(block.data));
C3 = blockproc(im, [8, 8], @(block) dct_180(block.data));

% 逆变换
im1 = uint8(blockproc(C1, [8, 8], @(block) idct2(block.data)) + 128);
im2 = uint8(blockproc(C2, [8, 8], @(block) idct2(block.data)) + 128);
im3 = uint8(blockproc(C3, [8, 8], @(block) idct2(block.data)) + 128);

% 显示结果
figure;
subplot(2,2,1); imshow(hall_gray); title('原始图片');
subplot(2,2,2); imshow(im1); title('转置DCT还原');
subplot(2,2,3); imshow(im2); title('旋转90°的DCT还原');
subplot(2,2,4); imshow(im3); title('旋转180°的DCT还原');

%% 选取一块操作
block = im(80:87, 56:63);

% 对选定的块进行DCT变换和处理
dct_t = set_t(dct2(block));
dct_90 = set_90(dct2(block));
dct_180 = set_180(dct2(block));

% 逆变换
block = uint8(block + 128);
im4 = uint8(idct2(dct_t) + 128);
im5 = uint8(idct2(dct_90) + 128);
im6 = uint8(idct2(dct_180) + 128);

% 显示结果
figure;
subplot(2,2,1); imshow(block); title('原始图像块');
subplot(2,2,2); imshow(im4); title('转置DCT还原');
subplot(2,2,3); imshow(im5); title('旋转90°的DCT还原');
subplot(2,2,4); imshow(im6); title('旋转180°的DCT还原');

%% 函数声明
function C = set_t(C)
    C = C';
end

function C = set_90(C)
    C = rot90(C);
end

function C = set_180(C)
    C = rot90(C, 2);
end