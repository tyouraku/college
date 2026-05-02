% 通信与网络 实验3 载波传输
% BPSK和4PAM误码性能对比
clearvars;
close all;
clc;
rng(2023);

% 通用参数
N = 1e5;
Es = 1;
T = 0.01;
delta_t = 1e-4;
f_c = 500;
num = T/delta_t;
t = delta_t:delta_t:N*T;

% 信噪比设置
EbN0_dB = 2:2:12;
EbN0 = 10.^(EbN0_dB/10);

% 匹配滤波器
h2_t = (1/sqrt(T)) * ones(1, num);
t_sample = T:T:N*T;
idx_sample = round(t_sample/delta_t);

%% BPSK仿真
A_bpsk = sqrt(Es/T);
bit_data_bpsk = randi([0 1], 1, N);
mod_data_bpsk = 2*bit_data_bpsk - 1;

x0_t_bpsk = zeros(1, N*num);
for cnt = 1:N   
    x0_t_bpsk(num*(cnt-1)+1:num*cnt) = mod_data_bpsk(cnt)*A_bpsk*ones(1,num);
end
x_t_bpsk = x0_t_bpsk.*sqrt(2).*cos(2*pi*f_c*t);

Eb_bpsk = Es;
N0_list_bpsk = Eb_bpsk ./ EbN0;
BER_bpsk_sim = zeros(size(EbN0_dB));

for idx = 1:length(EbN0_dB)
    n0 = N0_list_bpsk(idx);
    noise_power = n0/(2*delta_t);
    noise = sqrt(noise_power) * randn(size(t));
    y_t = x_t_bpsk + noise;
    y_base = y_t.*sqrt(2).*cos(2*pi*f_c*t);
    mf_out = conv_no_delay(y_base, fliplr(h2_t), delta_t);
    y_sampled = mf_out(idx_sample);
    x_hat = y_sampled > 0;
    bit_err = x_hat ~= bit_data_bpsk;
    BER_bpsk_sim(idx) = sum(bit_err) / length(bit_err);
end

BER_bpsk_theory = qfunc(sqrt(2*EbN0));

%% 4PAM仿真
M = 4;
A_pam = sqrt(3*Es/(T*(M^2-1)));
bit_data_pam = randi([0 1], 1, 2*N);
mod_data_pam = my_gray_map_real_M4(bit_data_pam);

x0_t_pam = zeros(1, N*num);
for cnt = 1:N   
    x0_t_pam(num*(cnt-1)+1:num*cnt) = mod_data_pam(cnt)*A_pam*ones(1,num);
end
x_t_pam = x0_t_pam.*sqrt(2).*cos(2*pi*f_c*t);

Eb_pam = Es / log2(M);
N0_list_pam = Eb_pam ./ EbN0;
EsN0 = EbN0 * log2(M);
BER_pam_sim = zeros(size(EbN0_dB));

for idx = 1:length(EbN0_dB)
    n0 = N0_list_pam(idx);
    noise_power = n0/2/delta_t;
    noise = sqrt(noise_power) * randn(size(t));
    y_t = x_t_pam + noise;
    y_base = y_t.*sqrt(2).*cos(2*pi*f_c*t);
    mf_out = conv_no_delay(y_base, fliplr(h2_t), delta_t);
    y_sampled = mf_out(idx_sample);
    
    x_hat = zeros(1,2*N);
    for k = 1:N
        x_hat((k-1)*2+1:k*2) = my_inverse_gray_map_real_M4(y_sampled(k)/(A_pam*sqrt(T)));
    end
    
    bit_err = xor(bit_data_pam, x_hat);
    BER_pam_sim(idx) = sum(bit_err)/length(bit_err);
end

ser_theory = (2*(M-1)/M) * qfunc(sqrt(6*EsN0/(M^2-1)));
BER_pam_theory = ser_theory / log2(M);

%% 绘制对比图
figure; 
semilogy(EbN0_dB, BER_bpsk_theory, 'b-', 'LineWidth', 2); hold on;
semilogy(EbN0_dB, BER_pam_theory, 'r-', 'LineWidth', 2);
semilogy(EbN0_dB, BER_bpsk_sim, 'go', 'LineWidth', 1.5, 'MarkerSize', 8);
semilogy(EbN0_dB, BER_pam_sim, 'ms', 'LineWidth', 1.5, 'MarkerSize', 8);

set(gca, 'YScale', 'log');
legend('BPSK理论', '4PAM理论', 'BPSK仿真', '4PAM仿真', 'Location', 'best');
xlabel('E_b/N_0 (dB)');
ylabel('误比特率 (BER)');
title('BPSK和4PAM误比特率性能对比');
grid on; box on;


%% 计算10^-3误比特率所需的Eb/N0差距
ber_target = 1e-3;

% 计算理论值在10^-3处的Eb/N0
valid_idx = isfinite(log10(BER_bpsk_theory)) & BER_bpsk_theory > 0;
EbN0_bpsk_theory = interp1(log10(BER_bpsk_theory(valid_idx)), EbN0_dB(valid_idx), log10(ber_target), 'linear');

valid_idx = isfinite(log10(BER_pam_theory)) & BER_pam_theory > 0;
EbN0_pam_theory = interp1(log10(BER_pam_theory(valid_idx)), EbN0_dB(valid_idx), log10(ber_target), 'linear');

% 计算仿真值在10^-3处的Eb/N0（添加安全检查）
valid_bpsk = isfinite(log10(BER_bpsk_sim)) & BER_bpsk_sim > 0;
if sum(valid_bpsk) > 1 && min(BER_bpsk_sim(valid_bpsk)) <= ber_target && max(BER_bpsk_sim(valid_bpsk)) >= ber_target
    EbN0_bpsk_sim = interp1(log10(BER_bpsk_sim(valid_bpsk)), EbN0_dB(valid_bpsk), log10(ber_target), 'linear');
else
    % 如果超出范围，使用最接近的点
    [~, idx] = min(abs(BER_bpsk_sim - ber_target));
    EbN0_bpsk_sim = EbN0_dB(idx);
end

valid_pam = isfinite(log10(BER_pam_sim)) & BER_pam_sim > 0;
if sum(valid_pam) > 1 && min(BER_pam_sim(valid_pam)) <= ber_target && max(BER_pam_sim(valid_pam)) >= ber_target
    EbN0_pam_sim = interp1(log10(BER_pam_sim(valid_pam)), EbN0_dB(valid_pam), log10(ber_target), 'linear');
else
    % 如果超出范围，使用最接近的点
    [~, idx] = min(abs(BER_pam_sim - ber_target));
    EbN0_pam_sim = EbN0_dB(idx);
end

% 计算差距
gap_theory = EbN0_pam_theory - EbN0_bpsk_theory;
gap_sim = EbN0_pam_sim - EbN0_bpsk_sim;

% 在命令行输出结果
fprintf('\n=== 10^-3误比特率性能分析 ===\n');
fprintf('BPSK理论值所需 Eb/N0: %.2f dB\n', EbN0_bpsk_theory);
fprintf('4PAM理论值所需 Eb/N0: %.2f dB\n', EbN0_pam_theory);
fprintf('理论值差距: %.2f dB\n\n', gap_theory);

fprintf('BPSK仿真值所需 Eb/N0: %.2f dB\n', EbN0_bpsk_sim);
fprintf('4PAM仿真值所需 Eb/N0: %.2f dB\n', EbN0_pam_sim);
fprintf('仿真值差距: %.2f dB\n\n', gap_sim);


%% 辅助函数
function mod_data = my_gray_map_real_M4(bit_data)
if mod(length(bit_data),2)==0
    N = length(bit_data)/2;
    mod_data = zeros(1,N);
    for n = 1:N
        current_bits = bit_data(2*n-1 : 2*n);
        if current_bits(1)==0 && current_bits(2)==0
            mod_data(n) = -3;
        elseif current_bits(1)==0 && current_bits(2)==1
            mod_data(n) = -1;
        elseif current_bits(1)==1 && current_bits(2)==1
            mod_data(n) = 1;
        else
            mod_data(n) = 3;
        end
    end
else
    error('Invalid modulation order');
end
end

function demod_bit_data = my_inverse_gray_map_real_M4(rx_data)
N = length(rx_data);
demod_bit_data = zeros(1,2*N);
for n = 1:N
    current_level = rx_data(n);
    if current_level < -2
       demod_bit_data(2*n-1:2*n) = [0, 0];
    elseif current_level < 0
        demod_bit_data(2*n-1:2*n) = [0, 1];
    elseif current_level < 2
        demod_bit_data(2*n-1:2*n) = [1, 1];
    else
        demod_bit_data(2*n-1:2*n) = [1, 0];
    end
end
end

function y_conv = conv_no_delay(y, h, delta_t)
    y = y(:).';
    h = h(:).';
    Ny = length(y);
    Nh = length(h);
    y_conv = zeros(1, Ny);
    for n = 1:Ny
        k_min = max(1, n-Nh+1);
        k_max = n;
        h_start = Nh - (k_max - k_min);
        h_end = Nh;
        y_conv(n) = sum(y(k_min:k_max) .* h(h_start:h_end)) * delta_t;
    end
end