clear; close all; clc;
rng(2025);

% 码长
n = 7;

% 信息位长
k = 4;

% 传输比特块数
% M = 5; % 20bit传输时
M = 10000;

% 交织块行数
row = 5;
% 交织块列数
column = 7;
% 交织行列总数
count = row * column;
% 交织块数量
number = (M*n)/(row*column);


%% 验证交织解交织功能1
ori_sequence1 = 1:count;
in_sequence1 = interleaver(row, column, ori_sequence1);
de_sequence1 = deinterleaver(row, column, in_sequence1);

figure;
subplot(3, 1, 1);
stem(ori_sequence1);
title('交织前序列');
xlabel('n');
ylabel('data');
subplot(3, 1, 2);
stem(in_sequence1);
title('交织后序列/解交织前序列');
xlabel('n');
ylabel('data');
subplot(3, 1, 3);
stem(de_sequence1);
title('解交织后序列');
xlabel('n');
ylabel('data');


%% 验证交织解交织功能2
L = row;
ori_sequence2 = zeros(1, count);
in_sequence2 = interleaver(row, column, ori_sequence2);
in_error2 = burst_error(in_sequence2, L);
de_error2 = deinterleaver(row, column, in_error2);

figure;
subplot(3, 1, 1);
stem(in_sequence2);
title('交织后序列');
xlabel('n');
ylabel('data');
subplot(3, 1, 2);
stem(in_error2);
title('解交织前序列');
xlabel('n');
ylabel('data');
subplot(3, 1, 3);
stem(de_error2);
title('解交织后序列');
xlabel('n');
ylabel('data');


%% 验证交织解交织功能3
L = 2 * row;
ori_sequence3 = zeros(1, count);
in_sequence3 = interleaver(row, column, ori_sequence3);
in_error3 = burst_error(in_sequence3, L);
de_error3 = deinterleaver(row, column, in_error3);

figure;
subplot(3, 1, 1);
stem(in_sequence3);
title('交织后序列');
xlabel('n');
ylabel('data');
subplot(3, 1, 2);
stem(in_error3);
title('解交织前序列');
xlabel('n');
ylabel('data');
subplot(3, 1, 3);
stem(de_error3);
title('解交织后序列');
xlabel('n');
ylabel('data');


%% 矩阵定义
% 生成矩阵
Q = [1 1 0; 1 0 1; 0 1 1; 1 1 1];
G = [eye(k) Q];

% 监督矩阵
H = [Q' eye(n-k)];


%% 有交织/解交织
% 随机生成Mk个需要传输的比特
x_data = randi([0 1], 1, M*k);
% fprintf('x_data\n');
% disp(x_data);

% 每4个信息比特作为一个比特块，编码成（7，4）汉明码，得到比特流向量
x_code = zeros(1, M*n);
for i = 1:M
    x_code((i-1)*n+1:i*n) = mod(x_data((i-1)*k+1:i*k)*G , 2); 
end
% fprintf('x_code\n');
% disp(x_code);

% 交织 按行写入 按列读出成比特流向量
x_interleave = zeros(1,M*n);
for i = 1:number
    x_interleave((i-1)*row*column+1:i*row*column) =  interleaver(row, column, x_code((i-1)*row*column+1:i*row*column));
end
% fprintf('x_interleave\n');
% disp(x_interleave);

% 经过信道 产生长度为L的突发错误
L = 5; % L = [3,5,10,15,20,25]
y = zeros(1,M*n);
for i = 1:number
    y((i-1)*row*column+1:i*row*column) =  burst_error(x_interleave((i-1)*row*column+1:i*row*column),L);
end
% fprintf('y\n');
% disp(y);

% 解交织 按列写入 按行读出成比特流向量
y_deinterleave = zeros(1,M*n);
for i = 1:number
    y_deinterleave((i-1)*row*column+1:i*row*column) =  deinterleaver(row, column, y((i-1)*row*column+1:i*row*column));
end
% fprintf('y_deinterleave\n');
% disp(y_deinterleave);

% 每7个比特为一组，进行译码
y_decode = zeros(1,M*k);
for i = 1:M
    % 利用监督矩阵计算校正子
    r = y_deinterleave((i-1)*n+1:i*n);
    syndrome = mod(r * H', 2);

    % 比较校正子和监督矩阵，找出错误位置
    if ismember(H',syndrome,'rows') == zeros(n,1)
        error_positions = 0; 
    else
        error_positions = find(ismember(H',syndrome,'rows'));
    end

    % 进行纠错
    y_decode_all = y_deinterleave((i-1)*n+1:i*n);
    if error_positions ~= 0
        y_decode_all(error_positions) = ~y_decode_all(error_positions); 
    end

    % 去除监督位
    y_decode((i-1)*k+1:i*k) = y_decode_all(1:k);
end
% fprintf('y_decode\n');
% disp(y_decode);

% 计算有交织时的误块率和误比特率
result = mod(x_data+y_decode,2);
result = transpose(reshape(result,[k,M]));
BlockErrorRate_code = sum(~ismember(result,zeros(1,k),'rows'))/M;
BitErrorRate_code = sum(result,'all')/(M*k);
fprintf('使用交织和(7,4)汉明码后的性能:\n');
fprintf('误比特率 %f\n', BitErrorRate_code);
fprintf('误块率 %f\n', BlockErrorRate_code);


%% 无交织/解交织
total_errors = number * L; % 总突发错误长度
y0 = x_code; % 初始化

% 将数据流分成若干段，每段添加一个突发错误
segment_length = floor(M*n / number); % 每段长度≈交织块大小
for i = 1:number
    start_idx = (i-1)*segment_length + 1;
    end_idx = min(i*segment_length, M*n);
    if end_idx - start_idx + 1 >= L % 确保段长度足够，在该段添加一个L长度的突发错误
        segment = y0(start_idx:end_idx); % 提取该段
        corrupted_segment = burst_error(segment, L); % 在该段添加突发错误
        y0(start_idx:end_idx) = corrupted_segment; % 替换回原数据流
    end
end

% 每7个比特为一组，进行译码
y_decode0 = zeros(1,M*k);
for i = 1:M
    % 利用监督矩阵计算校正子
    r = y0((i-1)*n+1:i*n);
    syndrome = mod(r * H', 2);

    % 比较校正子和监督矩阵，找出错误位置
    if ismember(H',syndrome,'rows') == zeros(n,1)
        error_positions = 0; 
    else
        error_positions = find(ismember(H',syndrome,'rows'));
    end

    % 进行纠错
    y_decode_all0 = y0((i-1)*n+1:i*n);
    if error_positions ~= 0
        y_decode_all0(error_positions) = ~y_decode_all0(error_positions); 
    end

    % 去除监督位
    y_decode0((i-1)*k+1:i*k) = y_decode_all0(1:k);
end
% fprintf('y_decode0\n');
% disp(y_decode0);
    
% 计算误码率
result0 = mod(x_data + y_decode0, 2);
result0 = transpose(reshape(result0,[k,M]));
BlockErrorRate_code0 = sum(~ismember(result0,zeros(1,k),'rows'))/M;
BitErrorRate_code0 = sum(result0,'all')/(M*k);
fprintf('无交织和(7,4)汉明码后的性能:\n');
fprintf('误比特率 %f\n', BitErrorRate_code0);
fprintf('误块率 %f\n', BlockErrorRate_code0);


%% 函数定义
function x_interleave = interleaver(row, column, x)
x = reshape(x, column, row);
x = x';
x_interleave = x(:)';
end

function y = burst_error(x, L)
noise = zeros(1,size(x,2));
error_idx = randi([1,size(x,2)-L+1]);
noise(1,error_idx:error_idx+L-1) = (rand(1,L)<0.5);
y = mod(x + noise, 2);
end

function y_deinterleave = deinterleaver(row, column, y)
y = reshape(y, row, column);
y = y';
y_deinterleave = y(:)';
end
