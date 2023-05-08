close all;
clear;

fid = fopen('chirpV3.dat','rb');
chunk_size = 5000;   
bufferSize = 250000;
data = zeros(1, 125000, 1) +1j*zeros(1, 125000, 1); % Para o chirp

i = 0;
while true
    i  =i+1;
    % read a chunk of data from the FIFO file
    chunk = fread(fid, chunk_size ,'float');
    if i == 1
        disp(length(chunk));
       % disp(chunk);
    end
    if isempty(chunk)
        % exit the loop if the FIFO file is empty
        str = sprintf("No sample at %d", i);
        disp(str)
        fid = fopen('chirpV3.dat', 'rb');
        break;
    end

    sigoriginal = chunk(1:2:end) + 1j*chunk(2:2:end);

    sigoriginalresample = resample(sigoriginal,1,5); 

    % append the chunk to the data vector
    data = circshift(data, -length(sigoriginalresample));

    % appending
    data(end-length(sigoriginalresample)+1:end) = sigoriginalresample;
end
length(data);
figure(1);
plot(real(data));
hold on;
plot(imag(data));
drawnow;