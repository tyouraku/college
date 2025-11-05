%% 载入样本
load('Guitar.MAT');

fs = 8000;

figure;
plot([1:length(realwave)]/fs, realwave);
xlabel("t(8kHz Sampled)");
ylabel("amplitude");
title("realwave");

figure;
plot([1:length(wave2proc)]/fs, wave2proc);
xlabel("t(8kHz Sampled)");
ylabel("amplitude");
title("wave2proc");

%% 预处理
wave = resample(realwave, fs*100, fs); % 重采样，将采样率增加100倍
wave = reshape(wave, length(realwave)*10, 10); % 将信号分成10段
averwave = mean(wave, 2); % 抑制噪声和非线性失真
mywave2proc = averwave - mean(averwave); % 去除直流分量
mywave2proc = repmat(mywave2proc, 10, 1); % 恢复原始信号长度
mywave2proc = resample(mywave2proc, fs, fs*100); % 恢复原始采样率

figure;
plot([1:length(mywave2proc)]/fs, mywave2proc);
xlabel("t(8kHz Sampled)");
ylabel("amplitude");
title("mywave2proc");