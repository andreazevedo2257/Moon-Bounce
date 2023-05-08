close all;
clear;

fs = 125000;                  % sampling rate
t = 0:1/fs:1; %-1/fs);           % time vector
fo = -5000;                  % starting frequency
f1 = 5000;                   % ending frequency
y = chirp(t, fo, t(125000), f1, 'linear', 0, 'complex');   % generate complex chirp signal
% y = y(1:125000); % TEMOS 1s DE SINAL

% Define the Kaiser window parameters
beta = 5;  % beta parameter of the Kaiser window
win_len = length(y);  % length of the Kaiser window

% Generate the Kaiser window
kaiser_win = kaiser(win_len, beta);

% Apply the Kaiser window to the signal
y = y .* kaiser_win';

% y = [y, zeros(1, fs)];

% Sinal de Arranque 
f = 1000;            % frequency of the sine wave
t = 0:1/fs:0.25; %-1/fs;  % time vector
t = t(1:end-1);
sin_y = sin(2*pi*f*t);   % generate sinusoidal wave

% Zeros
t = 0:1/fs:0.25;
pad = zeros(1,length(t)-1) + 1j* zeros(1,length(t)-1);

% Criaçao do sinal
sinal = [sin_y, pad];
sinal = [sinal, y];

% Mais zeros
t = 0:1/fs:3.5;
pad = zeros(1,length(t)-1) + 1j* zeros(1,length(t)-1);

sinal = [sinal,pad];

disp(length(sinal));

% Escrita
fid = fopen('ficheiros_dinamicos/chirp_data.dat', 'wb');
fwrite(fid, [real(sinal); imag(sinal)], 'float32');
fclose(fid);
sound (abs(y),fs)

% Ignorar
% f = 1000;            % frequency of the sine wave
% t = 0:1/fs:1-1/fs;  % time vector
% sin_y = sin(2*pi*f*t);   % generate sinusoidal wave
% 
% % write the signal to a file
% fid = fopen('files/sine_wave.dat', 'wb');
% fwrite(fid, [real(y); imag(y)], 'float32');
% fclose(fid);
