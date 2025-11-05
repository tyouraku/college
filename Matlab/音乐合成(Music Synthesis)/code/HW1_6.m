load("Guitar.MAT");

[rhythm, fs] = audioread('fmt.wav');
sound(rhythm,fs);
audiowrite('1_6.wav', rhythm, fs);