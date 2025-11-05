fs = 8000;
beattime = 0.5;

freq = [523.25, 523.25, 587.33, 392, 349.23, 349.23, 293.66, 392];
beatnum = [1, 0.5, 0.5, 2, 1, 0.5, 0.5, 2];
rhythm = [];

% 从Guitar.MAT分析得到的频率和振幅
freq_harm = [329.1, 658.4, 987.5, 1316.9, 1646.2, 1975.3, 2304.4, 2633.8, 2962.9, 3292.0];
amp = [0.0439076, 0.0791423, 0.0438014, 0.0594127, 0.00198038, 0.00587942, 0.0175337, 0.00655073, 0.00677967, 0.00188444];
amp = amp / max(amp); % 归一化

for i = 1:length(beatnum)
    t = beatnum(i) * beattime;
    t = linspace(0, t, t * fs);
    env = envel(t,3);
    
    % 初始化当前音符信号
    temp = zeros(size(t));
    r = freq(i) / freq_harm(1); % 计算基频与吉他基频的比例
    
    % 叠加所有谐波成分
    for i_harm = 1:length(freq_harm)
        freq_new = freq_harm(i_harm) * r; % 将吉他谐波频率按比例调整到目标音符频率
        temp = temp + amp(i_harm) * sin(2 * pi * freq_new * t); % 添加谐波成分
    end
    
    temp = temp .* env;
    rhythm = [rhythm, temp];
end

rhythm = rhythm / max(abs(rhythm));

sound(rhythm, fs);
audiowrite('1_10.wav', rhythm, fs);

%% 包络线函数定义
function env = envel(t,n)
    switch n
    case 1 % 分段折线式的原始ADSR包络
        env = zeros(1, length(t));
        env(1:0.2*end) = t(1:0.2*end); % Attack：20%时长
        env(1:0.2*end) = env(1:0.2*end)/env(0.2*end); % 归一化
        env(0.2*end+1:0.3*end) = -0.5*t(0.2*end+1:0.3*end) + 0.3; % Decay：10%时长
        env(0.2*end+1:0.3*end) = env(0.2*end+1:0.3*end)/env(0.2*end + 1); % 归一化
        env(0.3*end+1:0.65*end) = env(0.3*end); %Sustain：35%时长
        env(0.65*end+1:end) = t(0.65*end+1:end); % Release：35%时长
        env(0.65*end+1:end) = (env(0.65*end+1:end)-env(end))/(env(0.65*end+1)-env(end))* env(0.3*end); % 归一化
    case 2 % 指数函数
        env = zeros(1, length(t));
        env(1:end) = exp(-10*t(1:end));
    case 3 % 每一段是指数函数形式的ADSR包络
        env = zeros(1, length(t));
        env(1:0.2*end) = 1./exp(-t(1:0.2*end)) - 1; % Attack：20%时长
        env(1:0.2*end) = env(1:0.2*end)/env(0.2*end); % 归一化
        env(0.2*end+1:0.3*end) = exp(-10*t(0.2*end+1:0.3*end)) + 0.15; % Decay：10%时长
        env(0.2*end+1:0.3*end) = env(0.2*end+1:0.3*end)/env(0.2*end + 1); % 归一化
        env(0.3*end+1:0.65*end) = env(0.3*end); % Sustain：35%时长
        env(0.65*end+1:end) = exp(-6*t(0.65*end+1:end)); % Release：35%时长
        env(0.65*end+1:end) = (env(0.65*end+1:end)-env(end))/(env(0.65*end+1)-env(end))* env(0.3*end); % 归一化
    end
end