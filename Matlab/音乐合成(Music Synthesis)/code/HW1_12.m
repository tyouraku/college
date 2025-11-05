function HW1_12()
    % 创建主窗口
    fig = figure('Name', '音乐合成器', 'Position', [100 100 800 600], 'NumberTitle', 'off');
    
    % 输入文件选择
    uicontrol('Style', 'text', 'Position', [20 550 150 20], 'String', '选择乐器音频文件:');
    file_path = uicontrol('Style', 'edit', 'Position', [180 550 400 20], 'String', 'fmt.wav');
    uicontrol('Style', 'pushbutton', 'Position', [590 550 80 20], 'String', '浏览...',...
              'Callback', @browse_file);
    
    % 乐谱输入区
    uicontrol('Style', 'text', 'Position', [20 480 150 20], 'String', '输入音符序列:');
    notes_input = uicontrol('Style', 'edit', 'Position', [180 480 400 60],...
                           'String', 'C5 C5 D5 G4 | F4 F4 D4 G4', 'Max', 3);
    
    uicontrol('Style', 'text', 'Position', [20 420 150 20], 'String', '输入节拍序列:');
    beats_input = uicontrol('Style', 'edit', 'Position', [180 420 400 20],...
                           'String', '1 0.5 0.5 2 | 1 0.5 0.5 2');
    
    % 参数设置
    uicontrol('Style', 'text', 'Position', [20 380 150 20], 'String', '速度(BPM):');
    tempo_input = uicontrol('Style', 'edit', 'Position', [180 380 100 20], 'String', '100');
    
    uicontrol('Style', 'text', 'Position', [300 380 100 20], 'String', '采样率(Hz):');
    fs_input = uicontrol('Style', 'edit', 'Position', [400 380 100 20], 'String', '8000');
    
    % 控制按钮
    uicontrol('Style', 'pushbutton', 'Position', [180 320 120 30], 'String', '分析乐器音色',...
              'Callback', @analyze_instrument);
    uicontrol('Style', 'pushbutton', 'Position', [320 320 120 30], 'String', '试听合成结果',...
              'Callback', @synthesize_music);
    uicontrol('Style', 'pushbutton', 'Position', [460 320 120 30], 'String', '保存为WAV文件',...
              'Callback', @save_audio);
    
    % 结果显示区
    panel = uicontrol('Style', 'text', 'Position', [20 100 760 200],...
                          'String', '准备就绪...', 'HorizontalAlignment', 'left');
    
    % 音频分析结果存储
    feature = struct();
    rhythm = [];
    
    %% 回调函数
    function browse_file(~,~)
        [file, path] = uigetfile('*.wav', '选择乐器音频文件');
        if file ~= 0
            set(file_path, 'String', fullfile(path, file));
        end
    end

    %% 音色分析函数
    function analyze_instrument(~,~)
        audio_file = get(file_path, 'String');
        try
            [y, fs] = audioread(audio_file);
            set(panel, 'String', '正在分析乐器音色特征...');
            drawnow;
            
            result = HW1_9();  % 调用任务(9)的分析音色代码
            
            % 提取特征
            feature.freqs = result(:,3);
            feature.durations = result(:,2);
            
            % 计算谐波特征
            harm_data = cell(length(feature.freqs),1);
            for i = 1:length(feature.freqs)
                if feature.freqs(i) > 0
                    harm_data{i} = feature.freqs(i) * [1, 2.1, 3.2];
                end
            end
            feature.harmonics = harm_data;
            
            set(panel, 'String',...
                sprintf('分析完成！\n共提取%d个有效音符特征\n平均频率：%.2f Hz',...
                sum(feature.freqs>0),...
                mean(feature.freqs(feature.freqs>0))));
        catch e
            set(panel, 'String', ['分析失败：' e.message]);
        end
    end

    %% 音乐合成函数
    function synthesize_music(~,~)
        if isempty(fieldnames(feature))
            set(panel, 'String', '请先分析乐器音色！');
            return;
        end
        
        try
            % 解析输入
            notes = strsplit(strrep(get(notes_input, 'String'), '|', '')); % 移除小节线
            beats = strsplit(strrep(get(beats_input, 'String'), '|', ''));
            tempo = str2double(get(tempo_input, 'String'));
            fs = str2double(get(fs_input, 'String'));
            
            % 验证输入
            if length(notes) ~= length(beats)
                set(panel, 'String', '错误：音符和节拍数量不匹配！');
                return;
            end
            
            set(panel, 'String', '正在合成音乐...');
            drawnow;
            
            % 合成参数
            beat_duration = 60/tempo;
            rhythm = [];
            
            % 合成每个音符
            for i = 1:length(notes)
                note = strtrim(notes{i});
                t = str2double(beats{i}) * beat_duration;
                
                target_freq = note2freq(note); % 获取目标频率
                [~, idx] = min(abs(feature.freqs - target_freq)); % 查找最接近的音色特征
                t = linspace(0, t, round(t*fs)); % 合成音符
                
                if feature.freqs(idx) > 0
                    % 使用分析得到的谐波特征
                    harm_ratios = feature.harmonics{idx} / feature.harmonics{idx}(1);
                    harm_amps = [1.0, 0.6, 0.3];
                else
                    % 默认值
                    harm_ratios = [1, 2, 3];
                    harm_amps = [1.0, 0.5, 0.3];
                end
                
                % 合成音色
                note_signal = zeros(size(t));
                for h = 1:length(harm_ratios)
                    freq = target_freq * harm_ratios(h);
                    note_signal = note_signal + harm_amps(h) * sin(2*pi*freq*t);
                end

                env = envel(t); % 使用ADSR包络
                note_signal = note_signal .* env;
                rhythm = [rhythm, note_signal];
            end
            
            rhythm = rhythm / max(abs(rhythm)); % 归一化
            
            % 播放音频
            sound(rhythm, fs);
            set(panel, 'String', '合成完成！点击"保存为WAV文件"可保存音频');
        catch e
            set(panel, 'String', ['合成失败：' e.message]);
        end
    end

    function save_audio(~,~)
        if isempty(rhythm)
            set(panel, 'String', '没有可保存的音频数据！');
            return;
        end
        
        [file, path] = uiputfile('*.wav', '保存合成音频');
        if file ~= 0
            fs = str2double(get(fs_input, 'String'));
            audiowrite(fullfile(path, file), rhythm, fs);
            set(panel, 'String', ['音频已保存至：' fullfile(path, file)]);
        end
    end

    % 辅助函数
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

    function env = envel(t)
        len = length(t);
        env = zeros(size(t));
        attack_end = round(0.2*len);
        decay_end = round(0.3*len);
        sustain_end = round(0.65*len);

        if attack_end > 0 % Attack
            env(1:attack_end) = linspace(0,1,attack_end);
        end
        if decay_end > attack_end % Decay
            env(attack_end+1:decay_end) = linspace(1,0.3,decay_end-attack_end);
        end
        if sustain_end > decay_end % Sustain
            env(decay_end+1:sustain_end) = 0.3;
        end
        if len > sustain_end % Release
            env(sustain_end+1:end) = linspace(0.3,0,len-sustain_end);
        end
    end
end