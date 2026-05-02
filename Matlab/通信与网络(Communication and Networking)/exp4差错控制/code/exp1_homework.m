clear; close all; clc;
rng(2025);

% 码长
n = 7;

% 信息位长
k = 4;

% 传输比特块数
M = 10000;

% 生成矩阵
Q = [1 1 1; 1 1 0; 1 0 1; 0 1 1];
G = [eye(k) Q];

% 监督矩阵
H = [Q' eye(n-k)];

% 随机生成M个需要传输的比特块
x_data = randi([0 1], M, k);

% 将每个比特块编码成（7，4）汉明码
x_code = mod(x_data*G , 2); % 进行编码c=xG

% p_values = [0.001, 0.005, 0.01, 0.05, 0.1, 0.2];
p_values = logspace(-3, log10(0.2), 50);
num_p = length(p_values);
result = zeros(num_p, 4); 

for j = 1:num_p
    % 经过误符号率为p的BSC信道
    p = p_values(j);
    noise = rand(M, n) < p;
    y = mod(x_code + noise, 2);
    
    % 利用监督矩阵计算校正子
    syndrome = mod(y * H', 2); % s=yH^T
    
    % 比较校正子和监督矩阵，找出错误位置
    error_positions = zeros(M,1);
    H_transpose = H'; % 预计算 H'
    for i = 1:M
        if ismember(H',syndrome(i,:),'rows') == zeros(n,1)
            error_positions(i,1) = 0; 
        else
            error_positions(i,1) = find(ismember(H',syndrome(i,:),'rows'));
        end
    end
    
    % 进行纠错
    y_decode = y;
    for i = 1:M
        if error_positions(i,1) ~= 0
            y_decode(i, error_positions(i,1)) = ~y_decode(i, error_positions(i,1)); 
        end
    end
    
    % 去掉监督位
    y_decode_info = y_decode(:,1:k);
    
    % 计算无信道编码时的误块率和误比特率
    result_uncode = mod(x_data+y(:,1:k),2);
    BitErrorRate_uncode = sum(result_uncode,'all')/(M*k);
    BlockErrorRate_uncode = sum(~ismember(result_uncode,zeros(1,k),'rows'))/M;

    % 计算有信道编码时的误块率和误比特率
    result_code = mod(x_data+y_decode_info, 2);
    BitErrorRate_code = sum(result_code,'all')/(M*k);
    BlockErrorRate_code = sum(~ismember(result_code, zeros(1,k), 'rows'))/M;

    % 存储结果
    result(j, :) = [BitErrorRate_uncode, BlockErrorRate_uncode, BitErrorRate_code, BlockErrorRate_code];
    
    % 输出误码率
    % fprintf('BSC信道误符号率: %.4f\n', p);
    % fprintf('无汉明码: 误比特率 %.6f, 误块率 %.6f\n', BitErrorRate_uncode, BlockErrorRate_uncode);
    % fprintf('有汉明码: 误比特率 %.6f, 误块率 %.6f\n', BitErrorRate_code, BlockErrorRate_code);
end

figure;
loglog(p_values, result(:, 1), 'bo-', 'MarkerSize', 3, 'MarkerFaceColor', 'b', 'DisplayName', '无汉明码-误比特率'); 
hold on;
loglog(p_values, result(:, 2), 'bo--', 'MarkerSize', 3, 'MarkerFaceColor', 'b', 'DisplayName', '无汉明码-误块率'); 
loglog(p_values, result(:, 3), 'ro-', 'MarkerSize', 3, 'MarkerFaceColor', 'r', 'DisplayName', '有汉明码-误比特率'); 
loglog(p_values, result(:, 4), 'ro--', 'MarkerSize', 3, 'MarkerFaceColor', 'r', 'DisplayName', '有汉明码-误块率');

grid on;
title('(7, 4)汉明码在BSC信道下的误码率性能');
xlabel('信道误符号率 \epsilon (对数坐标)');
ylabel('误码率 (对数坐标)');
legend('Location', 'southwest');
xlim([min(p_values) max(p_values)]); % 确保横坐标范围正确显示
hold off;