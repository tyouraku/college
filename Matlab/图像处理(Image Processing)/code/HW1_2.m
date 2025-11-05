load ('hall.mat');
[h, w, c] = size(hall_color);
[x, y] = meshgrid(1:w, 1:h);

%% 红圈
r = min(h, w) / 2; % 半径
circen = [w, h] / 2; % 中心位置
r_circle = (0.96 * r <= sqrt((x - circen(1)).^2 + (y - circen(2)).^2)) & (sqrt((x - circen(1)).^2 + (y - circen(2)).^2) <= r); % 设置圆环宽度为图像半径的4%

% 分离RGB通道
r = hall_color(:,:,1);
g = hall_color(:,:,2);
b = hall_color(:,:,3);
% 把圆环区域设置为红色
r(r_circle) = uint8(255);
g(r_circle) = uint8(0);
b(r_circle) = uint8(0);
im1 = cat(3, r, g, b);

figure;
imshow(im1, 'InitialMagnification', 'fit')

%% 黑白格
pw = round(w/7); % 水平方向分7块
ph = round(h/5); % 竖直方向分5块
block = xor(mod(ceil(x/pw), 2), mod(ceil(y/ph), 2)); % 划分棋盘格

% 分离RGB通道
r = hall_color(:,:,1);
g = hall_color(:,:,2);
b = hall_color(:,:,3);
% 把棋盘格区域内设置黑色
r(block) = uint8(0);
g(block) = uint8(0);
b(block) = uint8(0);
im2 = cat(3, r, g, b);

figure;
imshow(im2, 'InitialMagnification', 'fit')