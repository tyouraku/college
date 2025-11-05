load('hall.mat');
im = double(hall_gray) - 128;

%% 对全图操作
dct_left = @(P) set_left(dct2(P));
dct_right = @(P) set_right(dct2(P));

% 分块处理整个图像
C1 = blockproc(im, [8, 8], @(block) dct2(block.data));
C2 = blockproc(im, [8, 8], @(block) dct_left(block.data));
C3 = blockproc(im, [8, 8], @(block) dct_right(block.data));

% 逆变换
im1 = uint8(blockproc(C1, [8, 8], @(block) idct2(block.data)) + 128);
im2 = uint8(blockproc(C2, [8, 8], @(block) idct2(block.data)) + 128);
im3 = uint8(blockproc(C3, [8, 8], @(block) idct2(block.data)) + 128);

% 显示结果
figure;
subplot(2,2,1); imshow(hall_gray); title('原始图片');
subplot(2,2,2); imshow(im1); title('原始DCT还原');
subplot(2,2,3); imshow(im2); title('左侧四列置0的DCT还原');
subplot(2,2,4); imshow(im3); title('右侧四列置0的DCT还原');

%% 选取一块操作
block = im(80:87, 56:63);

% 对选定的块进行DCT变换和处理
dct_ori = dct2(block);
dct_left = set_left(dct_ori);
dct_right = set_right(dct_ori);

% 逆变换
block = uint8(block + 128);
im4 = uint8(idct2(dct_ori) + 128);
im5 = uint8(idct2(dct_left) + 128);
im6 = uint8(idct2(dct_right) + 128);

% 显示结果
figure;
subplot(2,2,1); imshow(block); title('原始图像块');
subplot(2,2,2); imshow(im4); title('原始DCT还原');
subplot(2,2,3); imshow(im5); title('左侧四列置0的DCT还原');
subplot(2,2,4); imshow(im6); title('右侧四列置0的DCT还原');

%% 函数声明
function C = set_left(C)
    C(:, 1:4) = 0;
end

function C = set_right(C)
    C(:, 5:8) = 0;
end