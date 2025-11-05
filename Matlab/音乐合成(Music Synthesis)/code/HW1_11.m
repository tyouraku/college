function HW1_11()
    if ~exist('guitar_features.mat', 'file')
        result = HW1_9();  % 运行原始分析代码获取吉他音色特征
        
        % 提取谐波特征
        analyzed_freqs = result(:,3);
        harm_data = cell(size(analyzed_freqs));
        
        for i = 1:length(analyzed_freqs)
            if analyzed_freqs(i) > 0
                harm_data{i} = analyzed_freqs(i) * [1, 2.05, 3.1, 4.2, 5.3]; % 吉他谐波特征：基频 + 非整数倍谐波 + 高频衰减
            end
        end
        save('guitar_features.mat', 'analyzed_freqs', 'harm_data');
    else
        load('guitar_features.mat');
    end

    note = {'C5', 'C5', 'D5', 'G4', 'F4', 'F4', 'D4', 'G4'};
    beatnum = [1, 0.5, 0.5, 2, 1, 0.5, 0.5, 2];
    
    fs = 8000;
    beattime = 0.5;
    rhythm = [];
    
    % 吉他音色合成
    for i = 1:length(note)
        target_note = note{i};
        t = beatnum(i) * beattime;
        t = linspace(0, t, round(t*fs));
        
        target_freq = note2freq(target_note); % 获取目标频率
        [~, idx] = min(abs(analyzed_freqs - target_freq)); % 选择最接近的吉他音色特征
        
        if analyzed_freqs(idx) > 0
            % 使用分析得到的谐波特征
            harm_ratios = harm_data{idx}(2:end)/harm_data{idx}(1); % 相对基频的比率
            harm_amps = [1.0, 0.6, 0.3, 0.15, 0.07]; % 谐波幅度
        else
            % 默认值
            harm_ratios = [2.05, 3.1, 4.2];
            harm_amps = [0.6, 0.3, 0.1];
        end
        
        % 合成吉他音色
        note_signal = sin(2*pi*target_freq*t); % 基频
        
        % 添加谐波成分
        for h = 1:min(3, length(harm_ratios)) % 最多使用3个谐波
            freq_var = 0.005 * randn(); % 轻微随机失谐
            note_signal = note_signal + ...
                harm_amps(h) * sin(2*pi*target_freq*harm_ratios(h)*(1+freq_var)*t);
        end
        
        % 应用吉他包络
        env = envel(t);
        note_signal = note_signal .* env;
        
        % 添加拨弦噪声
        noise_env = min(1, 3*env); % 噪声包络更短促
        note_signal = note_signal + 0.03*noise_env.*randn(size(t));
        
        rhythm = [rhythm, note_signal];
    end
    
    % 后期处理
    rhythm = rhythm / max(abs(rhythm));
    rhythm = effect(rhythm, fs);
    
    % 播放和保存
    sound(rhythm, fs);
    audiowrite('1_11.wav', rhythm, fs);
end

%% 吉他包络
function env = envel(t)
    % 更快速的ADSR包络，适配吉他特性
    attack = min(0.02, t*0.15); % 非常快速的起音
    decay = min(0.05, t*0.2); % 快速衰减
    sustain = 0.4; % 持续电平
    release = min(0.15, t*0.3); % 中等释音
    
    env = zeros(size(t));
    n = length(t);
    
    % 计算各阶段分界点
    a_end = round(attack * n / t);
    d_end = round((attack + decay) * n / t);
    r_start = round((t - release) * n / t);
        
    if a_end > 0 % Attack
        env(1:a_end) = 1 - exp(-8*(0:a_end-1)/a_end);
    end
    
    if d_end > a_end % Decay
        decay_curve = exp(-5*(0:d_end-a_end-1)/(d_end-a_end));
        env(a_end+1:d_end) = env(a_end) * (sustain + (1-sustain)*decay_curve); 
    end
    
    if r_start > d_end % Sustain
        env(d_end+1:r_start) = sustain;
    end
    
    if n > r_start % Release
        env(r_start+1:end) = sustain * exp(-4*(0:n-r_start-1)/(n-r_start));
    end
end

%% 吉他效果
function y = effect(x, fs)
    % 1. 轻度过载
    y = tanh(1.5*x);
    
    % 2. 箱体模拟 (调整频响范围)
    [b,a] = butter(2, [100, 3500]/(fs/2)); % 8kHz采样率下限制高频范围
    y = filter(b,a,y);
    
    % 3. 简化的混响效果
    impulse_len = round(0.05*fs); % 更短的脉冲响应
    impulse_response = exp(-(1:impulse_len)/(0.01*fs));
    y = y + 0.1*conv(y, impulse_response, 'same');
    
    % 归一化
    y = y / max(abs(y));
end

%% 辅助函数
function freq = note2freq(note)
    note_names = {'C','C#','D','D#','E','F','F#','G','G#','A','A#','B'};
    if contains(note, '#')
        note_str = note(1:2);
        octave = str2double(note(3:end));
    else
        note_str = note(1);
        octave = str2double(note(2:end));
    end
    note_num = find(strcmp(note_names, note_str));
    freq = 440 * 2^((note_num + (octave-4)*12 - 9)/12);
end