% 通信与网络 实验5 FDMA
% 载波非正交 BPSK
clearvars;
close all;
clc;
rng(2023);  %固定随机种子，保证结果可复现

% 脉冲成形波形参数
T = 0.01; % 周期
V = 1/sqrt(T); % 幅度

% 用户数（>=2）
N_u = 4;

% 载波参数
delta_fc = 150; % 载波频率间隔从集合{30,50,80,100,130,150,180,200,230}中选取
f_lc = 200; % 最低载波频率
f_c = f_lc + (0:N_u-1)*delta_fc; % 载波频率，满足f_c(n)*T为整数

% 噪声的单边功率谱密度
n0 = 0.5;

% 最小时间间隔
delta_t = 1e-4;

% 每个符号周期采样次数
num_t = round(T/delta_t);

% 功率谱计算选项：1为计算，0为不计算
if_ps = 1;
% if_ps = 0;

N_s = 1e5; % 符号个数
% N_s = 2000;
N_b = N_s; % 每用户信息比特数

Es = V^2*T; % 符号能量
Eb = Es; % BPSK的比特能量

% 功率谱滑动窗参数
win_size = 100; % 滑动窗长与符号周期的比值 
win_step = 80; % 滑动窗移动步长与符号周期的比值
win_num = floor((N_s-win_size)/win_step)+1; % 滑动窗个数

% 功率谱频率分辨率
delta_f = 1/T/win_size;

% 功率谱采样频点
f = (0:win_size*num_t-1) * delta_f; % FFT所得功率谱循环周期为1/delta_t

EbN0_dB = 0:1:10;
EbN0 = 10.^(EbN0_dB/10);
ber_sim = zeros(length(EbN0), N_u);
ber_theory = qfunc(sqrt(EbN0)); % 理论值可以直接统一计算

for idx = 1:length(EbN0)
    % 噪声的单边功率谱密度
    % n0 = 0.5;
    n0 = Eb / EbN0(idx) * 2;

    % 仿真时间
    t = (delta_t:delta_t:N_s*T);

    % 成形脉冲
    p_t = V * ones(num_t, 1);

    % 基带脉冲成形
    x0_t = zeros(N_u, N_s*num_t);

    % 发送波形
    x_t = zeros(1, N_s*num_t);

    tic;

    % 随机生成符号序列
    bit_data = randi([0 1], N_u, N_b);

    % 转化为BPSK调制后的电平序列
    mod_data = ma_gray_map_real_M2(bit_data);

    % 脉冲成形
    for n_u = 1:N_u
        for n_s = 1:N_s
            x0_t(n_u,num_t*(n_s-1)+1:num_t*n_s) = mod_data(n_u,n_s)*p_t;
        end
    end
    % 逐用户上变频
    for n_u = 1:N_u
        x_t = x_t + x0_t(n_u,:) .* sqrt(2) .* cos(2*pi*f_c(n_u)*t);
    end

    % 功率谱绘图（仅idx==1且if_ps==1时）
    if if_ps == 1 && idx == 1
        S_X = zeros(1,win_size*num_t); % 功率谱初始化
        for win_id = 1:win_num % 滑动窗编号
            window = (win_id-1)*win_step*num_t+1:(win_id-1)*win_step*num_t+win_size*num_t;
            S_X = S_X + abs(fft(x_t(window))).^2;
        end
        S_X = S_X / win_num; % 窗之间求平均
        S_X = S_X / (num_t*win_size)^2 / delta_f; % 功率谱密度函数系数

        P_total = sum(S_X) * delta_f; % 计算总功率，对Sx积分
        P_user = zeros(1, N_u);
        
        % 将Sx和f重新排列到中心
        fs = 1/delta_t;
        S_X_1 = fftshift(S_X);
        f_1 = (-fs/2 : delta_f : fs/2 - delta_f);

        for n_u = 1:N_u
            f_ci = f_c(n_u);
            idx_pos = (f_1 >= f_ci - 1.3/T) & (f_1 <= f_ci + 1.3/T); % 正频率频段
            idx_neg = (f_1 >= -f_ci - 1.3/T) & (f_1 <= -f_ci + 1.3/T); % 负频率频段
            P_user(n_u) = sum(S_X_1(idx_pos | idx_neg)) * delta_f; % 积分求和
        end
        
        fprintf('理论总功率: %.2f W\n', N_u * (1/T));
        fprintf('仿真总功率: %.2f W\n', P_total);
        for n_u = 1:N_u
            fprintf('用户%d仿真功率: %.2f W (理论值: %.2f W)\n', n_u, P_user(n_u), 1/T);
        end
        
        figure;
        plot(f(f<1/2/delta_t), 10*log10(S_X(f<1/2/delta_t)), 'b', 'LineWidth', 1);
        hold on;
        plot(f(f>=1/2/delta_t)-1/delta_t, 10*log10(S_X(f>=1/2/delta_t)), 'b', 'LineWidth', 1);
        xlabel('频率/Hz');
        ylabel('功率谱密度/[dBW/Hz]');
        title(sprintf('功率谱,△f_c=%dHz',delta_fc));
        xlim([-1/2/delta_t 1/2/delta_t])
        ylim(10*log10(max(S_X)*[1E-5 1.2]));
        box on;
        grid on;
    end
    
    % 加性噪声
    noise_power = n0/2/delta_t;
    noise = sqrt(noise_power) * randn(size(t));

    % AWGN信道
    y_t = x_t + noise;

    % 等效基带接收波形
    y0_t = zeros(N_u, N_s*num_t);

    % 逐用户下变频
    for n_u = 1:N_u
        y0_t(n_u,:) = y_t .* sqrt(2) .* cos(2*pi*f_c(n_u)*t);
    end

    % 初始化接收符号
    y = zeros(N_u, N_s);

    % 逐用户最佳接收
    for n_u = 1:N_u
        for n_s = 1:N_s 
            y(n_u,n_s) = sum(y0_t(n_u, (n_s-1)*num_t+1 : n_s*num_t)) * delta_t;
        end
    end

    % 最佳判决结果
    bit_hat = ma_inverse_gray_map_real_M2(y);

    % 差错比特
    bit_err = xor(bit_data, bit_hat);
    % 计算各用户的误比特率
    ber = sum(bit_err,2);
    ber = ber/N_b;
    ber_sim(idx,:) = ber;

    toc;

    % 发送/接收波形绘图（仅idx==1时）
    if idx == 1
        figure;
        plot((delta_t:delta_t:4*T)', y_t(1:4*num_t), 'LineWidth', 1);
        hold on;
        plot((delta_t:delta_t:4*T)', x_t(1:4*num_t), 'LineWidth', 1);
        xlabel('时间/s');
        ylabel('幅度/V');
        title(sprintf('波形图,△f_c=%dHz',delta_fc));
        box on;
        grid on;
        legend('接收波形信号','发送波形信号','fontsize',12);
    end
end

% 绘制误比特率与Eb/n0之间的关系曲线
figure;
semilogy(EbN0_dB, mean(ber_sim,2), 'o-b', 'LineWidth', 2, 'MarkerSize', 6); hold on;
semilogy(EbN0_dB, ber_theory, '--r', 'LineWidth', 2);
xlabel('E_b/n_0 (dB)');
ylabel('BER');
title(sprintf('BPSK传输下误比特率与E_b/n_0之间的关系曲线,△f_c=%dHz',delta_fc));
legend('仿真BER','理论BER');
grid on;


% M=2，由bit序列映射到电平符号
function mod_data = ma_gray_map_real_M2(bit_data)
% 对应的符号序列长度
[N_u, N_s] = size(bit_data);
mod_data = zeros(N_u, N_s);
% 逐用户、逐符号判断映射关系
for n_u = 1:N_u
    for n_s = 1:N_s
        current_bits = bit_data(n_u,n_s);
        if current_bits == 0
            mod_data(n_u,n_s) = -1;
        elseif current_bits == 1
            mod_data(n_u,n_s) = 1;
        end
    end
end
end

% M=2，由电平符号映射到bit序列
function demod_bit_data = ma_inverse_gray_map_real_M2(rx_data)
% 符号序列长度
[N_u, N_s] = size(rx_data);
demod_bit_data = zeros(N_u,N_s);
% 逐用户、逐符号判决
for n_u = 1:N_u
    for n_s = 1:N_s
        current_level = rx_data(n_u,n_s);
        if current_level < 0
            demod_bit_data(n_u,n_s) = 0;
        else
            demod_bit_data(n_u,n_s) = 1;
        end
    end
end
end