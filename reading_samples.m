close all;
clear;
% DECIMAÇAO DE 0.2 -> Freq de amostragem 25kHz

% Variaveis para buffer circular
chunk_size = 5000; %1024; % number of samples to read at a time
bufferSize = 125000;
data = zeros(1, bufferSize, 1) +1j*zeros(1, bufferSize, 1); % Para o chirp
data1 = zeros(1, bufferSize, 1)+1j*zeros(1, bufferSize, 1); % Para leitura dinamica 

% added for correlation
fid = fopen('ficheiros_dinamicos/chirp_data.dat','rb');
fid1 = fopen('ficheiros_dinamicos/samples_fifo', 'rb');

% Plot
% figure(1);
% subplot(1,3,1);
figure(1);
subplot(1,3,1);
hLine = plot(data1);
xlabel('Sample Index');
ylabel('Amplitude');
title('Sine Wave Plot Recebido');
subplot(1,3,3);
hLine2 = plot(data);
title('Sine Wave Plot Emitido');
drawnow;
subplot(1,3,2);
corr_sign_total = 0;
plot_corr = plot(corr_sign_total);
i = 0;
cycle = 0;
% ler de 2000 a 28500 -> sigoriginalresample
while true
    i = i+1;
    % read a chunk of data from the FIFO file
    chunk = fread(fid, chunk_size,'float');
    chunk1 = fread(fid1, chunk_size, 'float');

    if isempty(chunk)
        % exit the loop if the FIFO file is empty
        str = sprintf("No sample at %d", i);
        disp(str)
        fid = fopen('chirpV3.dat', 'rb');
        chunk = fread(fid, chunk_size ,'float');
        continue;
    end

    if isempty(chunk1)
        disp("runs out of data");
        break;
    end

    sigoriginal = chunk(1:2:end) + 1j*chunk(2:2:end);
    sigrecebido = chunk1(1:2:end) + 1j*chunk1(2:2:end);
    % disp(length(sigoriginal));
    % disp(length(sigrecebido));
    sigoriginalresample = resample(sigoriginal,1,5); 
    sigrecebidoresample = resample(sigrecebido,1,5);

    % append the chunk to the data vector
    data = circshift(data, -length(sigoriginalresample));
    data1 = circshift(data1, -length(sigrecebidoresample));

    % appending
    data(end-length(sigoriginalresample)+1:end) = sigoriginalresample;
    data1(end-length(sigrecebidoresample)+1:end) = sigrecebidoresample;
    if mod(i*(chunk_size/2),125000)==0
        [corr_sign, c] = xcorr(data(end-25000:end), data1(end-25000:end));
        cycle = cycle + 1;
        if cycle == 1
            corr_sign_total = corr_sign;
        else
            corr_sign_total = corr_sign_total + corr_sign;
            % corr_sign_total = corr_sign_total/(cycle+1);
        end
        disp("Atualizaçao");
        disp(cycle);
        disp(i);
        subplot(1,3,2);
        set(plot_corr, 'XData', c, 'YData', abs(corr_sign_total));
    end

    subplot(1,3,3);
    set(hLine2, 'YData',real(data));
    hold on;
    set(hLine2, 'YData',imag(data));

    subplot(1,3,1);
    set(hLine, 'YData', real(data1));
    hold on;
    set(hLine, 'YData', imag(data1));
    drawnow;
end

figure(2);
subplot(1,3,2);
plot(c, abs(corr_sign_total));

subplot(1,3,3);
set(hLine2, 'YData',real(data));
hold on;
set(hLine2, 'YData',imag(data));

subplot(1,3,1);
set(hLine, 'YData', real(data1));
hold on;
set(hLine, 'YData', imag(data1));
drawnow;

% [corr_sign, c] = xcorr(data, data1);
% disp(length(corr_sign));
% disp(exp(1j*12500*2*pi));
% t_corr = (0:length(corr_sign)-1)/(12.5e3); % Calculate the time axis for the correlation signal
% figure();
% subplot(1,3,1);
% plot(c, abs(corr_sign));
% title('Correlation Signal');
% xlabel('Time (s)');
% 
% % Display
% subplot(1,3,2);
% plot(real(data));
% hold on;
% plot(imag(data));
% xlabel('Sample Index');
% ylabel('Amplitude');
% title('Sine Wave Plot Original');
% 
% subplot(1,3,3);
% plot(real(data1));
% hold on;
% plot(imag(data1));
% xlabel('Sample Index');
% ylabel('Amplitude');
% title('Sine Wave Plot Recebido');
% drawnow;

fclose(fid);
