clear all;
close all;
clc;
rng(2025);  %固定随机种子，保证结果可复现

%% 参数
V_max = 10;
sigma_x=sqrt(2);  %拉普拉斯分布的系数
% sigma_x=1;  %拉普拉斯分布的系数
% sigma_x=2;  %拉普拉斯分布的系数
N = 1000000;  %拉普拉斯分布下采样点数
A = randlap(N, sigma_x);  %拉普拉斯分布下的采样
mu = 255; %μ取值
x_max = 10;

%% 画出幅度分布
bins = 1000; %选取合理的直方图格点数
histogram(A, bins,'Normalization','probability');
title("点列A的幅度分布");

%% A均匀量化，注意对信号截断到[-10,10]区间内
A_hat = zeros(size(A));
% L = 2^8; %参考代码给出：量化区间
L = 2^9; %实验指导书给出：量化区间
interval = 2*V_max/L; %量化间隔
x = -V_max:interval:V_max; %分层电平
y = -V_max+interval/2:interval:V_max-interval/2; %重建电平
for i = 1:N  %循环点列
    for j = 1:L  %循环区间
        % 完成均匀量化，得到量化后的采样A_hat
        if (A(i) >= x(j)) && (A(i) < x(j+1))
            A_hat(i) = y(j);
            break;
        end
    end
    % 边界情况
    if A(i) >= V_max
        A_hat(i) = y(L);
    elseif A(i) <= -V_max
        A_hat(i) = y(1);
    end
end
ex = A - A_hat; %均匀量化的量化误差e(x)
power_exp = sum(A.^2,"all")/N;  %信号功率
noise_exp = sum(ex.^2,"all")/N; %量化噪声功率
snr_exp = power_exp/noise_exp;
snrdb_exp = 10*log10(snr_exp);

figure;
nbins = 1000; % 选取合理的直方图格点数
histogram(ex,nbins,'Normalization','probability');
title("均匀量化的量化误差分布")
xlabel("e")
ylabel("p(e)")
fprintf("均匀量化下，量化噪声方差%fdB,点列A信号功率%fdB,量化信噪比%fdB\n",10*log10(noise_exp),10*log10(power_exp),snrdb_exp);


%% μ律压缩
B = x_max * log(1+mu*abs(A)/x_max) / log(1+mu) .* sign(A);
figure;
nbins_B = 1000; % 选取合理的直方图格点数
histogram(B,nbins_B,'Normalization','probability');
title("μ律压缩后的样本分布")
xlabel("x")
ylabel("p(x)")

%% BC均匀量化，注意对信号截断到[-10,10]区间内
C = zeros(size(B));
% L = 2^8; %参考代码给出：量化区间
L = 2^9; %实验指导书给出：量化区间
interval = 2*V_max/L; %量化间隔
x = -x_max:interval:x_max; %分层电平
y = -x_max+interval/2:interval:x_max-interval/2; %重建电平
for i = 1:N  %循环点列
    for j = 1:L  %循环区间
        % 完成均匀量化，得到量化后的采样C
        if (B(i) >= x(j)) && (B(i) < x(j+1))
            C(i) = y(j);
            break;
        end
    end
    % 边界情况
    if B(i) >= x_max
        C(i) = y(L);
    elseif B(i) <= -x_max
        C(i) = y(1);
    end
end
ex1 = B - C; %BC间的量化误差e(x)
powerBC_exp = sum(B.^2,"all")/N;  %信号功率
noiseBC_exp = sum(ex1.^2,"all")/N; %量化噪声方差
snrBC_exp = powerBC_exp/noiseBC_exp;
snrBCdb_exp = 10*log10(snrBC_exp);
figure;
nbins_ex1 = 1000; % 选取合理的直方图格点数
histogram(ex1,nbins_ex1,'Normalization','probability');
title("BC间的量化误差分布")
xlabel("e")
ylabel("p(e)")
fprintf("BC间,量化噪声方差%fdB,点列B信号功率%fdB,量化信噪比%fdB\n",10*log10(noiseBC_exp),10*log10(powerBC_exp),snrBCdb_exp);


%% μ律扩张
D = sign(C) .* (x_max / mu .* ((1+mu) .^ (abs(C)/x_max) - 1));
ex2 = A - D; %AD间的量化误差e(x)
powerAD_exp = sum(A.^2,"all")/N;  %信号功率
noiseAD_exp = sum(ex2.^2,"all")/N;; %量化噪声方差
snrAD_exp = powerAD_exp/noiseAD_exp;
snrADdb_exp = 10*log10(snrAD_exp);
figure;
nbins_ex2 = 1000; % 选取合理的直方图格点数
histogram(ex2,nbins_ex2,'Normalization','probability');
title("AD间的量化误差分布")
xlabel("e")
ylabel("p(e)")
fprintf("AD间,量化噪声方差%fdB,点列A信号功率%fdB,量化信噪比%fdB\n",10*log10(noiseAD_exp),10*log10(powerAD_exp),snrADdb_exp);


%% 采用逆累积分布函数生成零均值拉普拉斯采样
function x = randlap(siz, sigma_x)
x = (log(rand(siz,1)).*(2*floor(rand(siz,1)*2)-1))*sigma_x/sqrt(2);
end
