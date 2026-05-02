clear all;
close all;
clc;
rng(2025);  %固定随机种子，保证结果可复现

% 参数
V_max = 1;  %量化范围[-V_max, V_max]
Q_bit = [1,2,3];  %量化比特数
V = 1;  %均匀分布的范围[-V, V]
N = 1000000;  %均匀分布下采样点数
s = -V+2*V*rand(1,N);  %均匀分布下的采样
s_hat = zeros(size(s));  %量化后的重建采样
p_x = @(x) 0.5 .* (abs(x) < 1);

% 画出幅度分布
bins = 1000; %选取合理的直方图格点数
histogram(s, bins,'Normalization','probability');
title("点列A的幅度分布");

% 实验
for B = Q_bit
    L = 2^B; %量化区间
    interval = 2*V_max/L; %量化间隔
    x = -V_max:interval:V_max; %分层电平[x_1,x_2,..,x_{L+1}]
    y = -V_max+interval/2:interval:V_max-interval/2; %重建电平[y_1,y_2,...,y_L]
    
    %% 理论计算
    power_th = func1(V_max, p_x); %信号功率
    noise_th = func2(x, y, p_x, L); %量化噪声功率
    snr_th = power_th/noise_th;
    snrdb_th = 10*log10(snr_th);
    
    %% 实验计算
    for i = 1:N  %循环点列
        for j = 1:L  %循环区间
            % 完成均匀量化，得到量化后的采样s_hat
            if (s(i) >= x(j)) && (s(i) < x(j+1))
                s_hat(i) = y(j);
                break;
            end
        end
        % 边界情况
        if s(i) >= V_max
            s_hat(i) = y(L);
        elseif s(i) <= -V_max
            s_hat(i) = y(1);
        end
    end
    ex = s - s_hat;  %量化误差e(x)
    power_exp = sum(s.^2,"all")/N;  %信号功率
    noise_exp = sum(ex.^2,"all")/N; %量化噪声方差
    snr_exp = power_exp/noise_exp;  %量化信噪比
    snrdb_exp = 10*log10(snr_exp);

    
    %% 输出
    figure;
    exbins = 1000; %选取合理的直方图格点数
    histogram(ex,exbins,'Normalization','probability'); %计算e(x)的分布
    title(num2str(B)+"bit下的量化误差分布")
    xlabel("e")
    ylabel("p(e)")
    fprintf("%dbit量化时,噪声方差理论值/实际值=%fdB/%fdB,信号功率理论值/实际值=%fdB/%fdB,量化信噪比理论值/实际值=%f/%fdB\n",B,10*log10(noise_th),10*log10(noise_exp),10*log10(power_th),10*log10(power_exp),snrdb_th,snrdb_exp);
end

%% 函数定义
function power = func1(x_max, p_x) %信号功率计算
    power = integral(@(x) (x.^2) .* p_x(x), -x_max, x_max); %积分
end

function noise = func2(x, y, p_x, L) %量化噪声功率计算
    noise = 0;
    for k = 1:L
        temp = integral(@(x) (x - y(k)).^2 .* p_x(x), x(k), x(k+1)); %积分
        noise = noise + temp; %累加
    end
end