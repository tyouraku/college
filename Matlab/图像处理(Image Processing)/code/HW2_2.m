load ('hall.mat');

hall_test = double(hall_gray(80:87, 56:63)); % 8×8 子块
im = hall_test - 128; 

dctim1 = dct2(im);
dctim2 = my_dct2(im);

err = max(abs(dctim1(:) - dctim2(:))); % 计算最大绝对误差
fprintf('最大绝对误差 = %.5e\n', err);

if err < 1e-12
    disp('等价');
else
    disp('不等价');
end

%% 显示部分
figure;
imshow(log(abs(dctim1)+1), [], 'InitialMagnification', 'fit');
title('自带库函数DCT');

figure;
imshow(log(abs(dctim2)+1), [], 'InitialMagnification', 'fit');
title('编程实现DCT');

%% 二维DCT
function C = my_dct2(P)
    [h, w] = size(P);
    assert(w == h, "不是方阵，输入非法！");
    d1 = 1 : 2 : 2 * w - 1;
    d2 = (1 : w - 1)';
    D = cos(d1 .* d2 * pi / (2 * w));
    D = [ones(1, w) * sqrt(1/w); D * sqrt(2/w)];
    C = D * P * D';
end