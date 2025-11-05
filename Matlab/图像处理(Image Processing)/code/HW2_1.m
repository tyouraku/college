load('hall.mat');
hall_test = double(hall_gray(80:87, 56:63)); % 8×8 子块

% 空域
im1 = hall_test - 128; % 直接减去128
dctim1 = dct2(im1);

% 变换域
dctim2 = dct2(hall_test);
dctim2(1,1) = dctim2(1,1) - 128 * 8; % 需要减去128 * 8

err = max(abs(dctim1(:) - dctim2(:))); % 计算最大绝对误差
fprintf('最大绝对误差 = %.5e\n', err);

if err < 1e-12
    disp('等价');
else
    disp('不等价');
end

%% 显示部分
figure;
imshow(uint8(hall_test), 'InitialMagnification', 'fit');
title('8 * 8子块');

figure;
imshow(log(abs(dctim1)+1), [], 'InitialMagnification', 'fit');
title('空域DCT');

figure;
imshow(log(abs(dctim2)+1), [], 'InitialMagnification', 'fit');
title('变换域DCT');