fs = 8000;
beattime = 0.5; % 一拍约为0.5s

freq = [523.25, 523.25, 587.33, 392, 349.23, 349.23, 293.66, 392]; % 对应旋律中每个音的频率
beatnum = [1, 0.5, 0.5, 2, 1, 0.5, 0.5, 2]; % 对应旋律中每个音的节拍
rhythm = [];

for i = 1 : length(beatnum)
    t = beatnum(i) * beattime; % 音符持续时间  
    t = linspace(0, t, t * fs); % 采样点
    rhythm = [rhythm, sin(2 * pi * freq(i) * t)];
end

sound(rhythm, fs);
audiowrite('1_1.wav', rhythm, fs);