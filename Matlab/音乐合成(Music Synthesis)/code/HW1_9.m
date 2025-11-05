function result = HW1_9()
    [y, fs] = audioread('fmt.wav');
    
    % 参数设置
    t_min = 0.08; % 最小音符持续时间
    f_min = 60; % 最低检测频率
    f_max = 1200; % 最高检测频率
    threshold = 0.015; % 音符起始检测阈值
    tolerance = 0.05; % 谐波频率匹配容忍度

    t = (0:length(y)-1)/fs;
    
    %% 音符起始点检测
    % 计算信号包络
    w2 = abs(y);
    w3 = conv(w2, hanning(round(fs/10)))/sum(hanning(round(fs/10)));
    w4 = max(w3/max(w3), 0);
    
    % 检测音符起始点
    dynamic_threshold = max(threshold, 0.1*max(w4)); % 取固定阈值和动态阈值的较大者
    [~, locs] = findpeaks(w4, 'MinPeakDistance', round(0.1*fs), ...
                             'MinPeakHeight', dynamic_threshold, ...
                             'MinPeakProminence', 0.06);
    onset_samples = [1; locs; length(y)]; % 添加开始和结束点
    
    %% 音高检测
    num_notes = length(onset_samples)-1;
    pitches = zeros(num_notes, 1);
    durations = zeros(num_notes, 1);
    note_names = cell(num_notes, 1);
    
    % 创建结果矩阵
    result = zeros(num_notes, 4); % [起始时间, 持续时间, 音名, 频率]
    
    figure;
    
    for i = 1:num_notes
        start_idx = onset_samples(i);
        end_idx = onset_samples(i+1);
        durations(i) = (end_idx - start_idx)/fs;
        result(i,1) = t(start_idx); % 起始时间
        result(i,2) = durations(i); % 持续时间
        
        if durations(i) >= t_min
            note_seg = y(start_idx:end_idx);
            
            % 傅里叶变换分析
            note_rep = repmat(note_seg, 100, 1); % 重复信号以提高频率分辨率
            N = length(note_rep);
            
            % 加窗并计算FFT
            window = hann(N);
            note_fft = abs(fft(note_rep .* window));
            note_fft(1) = 0; % 去除直流分量
            note_fft = fftshift(note_fft);
            note_fft = note_fft(N/2+1:end); % 取正频率部分
            
            % 频率轴
            f = (0:N/2-1)*fs/N;
            
            % 绘制频谱图
            subplot(ceil(num_notes/4), 4, i);
            plot(f, note_fft);
            xlabel('frequency/Hz');
            ylabel('amp');
            title(sprintf('音符 %d 频谱', i));
            xlim([0, f_max]);
            grid on;
            
            % 寻找频谱峰值
            [peak_amps, peak_loc] = findpeaks(note_fft, ...
                'MinPeakDistance', round(N*0.05/fs), ...
                'MinPeakHeight', max(note_fft)*0.02, ...
                'MinPeakProminence', 0.04);
            
            if ~isempty(peak_loc)
                % 按幅度排序
                [~, sort_idx] = sort(peak_amps, 'descend');
                sorted_loc = peak_loc(sort_idx);
                sorted_freqs = f(sorted_loc);
                
                % 找出基频
                f0 = 0;
                for k = 1:length(sorted_freqs)
                    temp = sorted_freqs(k);
                    if temp < f_min || temp > f_max
                        continue;
                    end
                    
                    % 检查是否是其他频率的谐波
                    is_harmonic = false;
                    for m = 1:k-1
                        ratio = temp / sorted_freqs(m);
                        if abs(ratio - round(ratio)) < tolerance
                            is_harmonic = true;
                            break;
                        end
                    end
                    
                    if ~is_harmonic
                        f0 = temp;
                        break;
                    end
                end
                
                % 检查频率是否在合理范围内
                if f0 >= f_min && f0 <= f_max
                    pitches(i) = f0;
                    note_names{i} = freq_to_note(f0);
                else
                    note_names{i} = 'Rest';
                end
            else
                note_names{i} = 'Rest';
            end
            
            result(i,3) = pitches(i);
            if pitches(i) > 0
                result(i,4) = str2double(note_names{i}(2:end)); % 音高数字部分
            end
        else
            note_names{i} = 'Rest';
        end
    end
    
    %% 结果输出
    fprintf('%-7s %-8s %-8s %-10s\n', '起始时间', '持续时间/s', '音名', '频率/Hz');
    fprintf('----------------------------------------\n');
    
    for i = 1:num_notes
        if pitches(i) > 0
            fprintf('%-10.2f %-10.2f %-10s %-10.2f\n', ...
                   result(i,1), result(i,2), note_names{i}, result(i,3));
        else
            fprintf('%-10.2f %-10.2f %-10s\n', ...
                   result(i,1), result(i,2), 'Rest');
        end
    end
    
    %% 可视化
    figure;
    plot(t, y);
    hold on;
    for i = 1:length(onset_samples)
        xline(t(onset_samples(i)), 'r--', 'LineWidth', 1);
    end
    title('节拍划分');
    xlabel('t/s');
    ylabel('amplitude');
    
    %% 保存结果到文件
    save('ans.mat', 'result');
    
    %% 创建包含所有信息的结果表格
    final_result = table();
    final_result.StartTime = result(:,1);
    final_result.Duration = result(:,2);
    final_result.Frequency = result(:,3);
    final_result.NoteName = note_names;
    
    writetable(final_result, 'ans.csv');
end

function note_name = freq_to_note(freq)
    % 十二平均律音高转换
    note_names = {'C','C#','D','D#','E','F','F#','G','G#','A','A#','B'};
    if freq <= 0
        note_name = 'Rest';
        return;
    end
    
    semitone = round(12 * log2(freq / 440) + 69);
    octave = floor(semitone / 12) - 1;
    note_idx = mod(semitone-1, 12) + 1;
    note_name = [note_names{note_idx} num2str(octave)];
end