wave2proc_r = repmat(wave2proc,100,1); % 将时域信号重复100次

%% 进行傅里叶变换
fs = 8000;
L = length(wave2proc_r);
t = (0:L-1)/fs;
N = 2^nextpow2(L); % 寻找最接近的2的幂次，因为FFT在N=2^n时计算速度最快，优化计算效率
wave_f = fft(wave2proc_r,N)/L; % 执行FFT并归一化
f = fs/2*linspace(0,1,N/2+1); % 频率：0~fs/2
amp = 2*abs(wave_f(1:N/2+1)); % 幅度：单边

plot(f,amp) % 绘制幅频图像
title("fft图像");
xlabel("frequncy/Hz");
ylabel("amplitude");

%% 求基频和谐波分量
[pk,loc] = findpeaks(amp,'minpeakheight',0.002,'minpeakdistance',50); % 寻找峰值
freq_p = f(loc)