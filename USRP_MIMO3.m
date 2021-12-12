%% 범용 직렬 버스 장치 -> erllc_uhd_b200 이거 드라이브 설치

% findsdru()

Platform = 'B210'; % USRP N210
 Address = '30CEE83';
% Address = '30CEEA6';

% MasterClockRate = `40e6;  %Hz
% MasterClockRate = 30e6;  %Hz
% Fs = 10e6; % Sample rate


testing 

 MasterClockRate = 30e6;  %Hz
 Fs = 10e6; % Sample rate


%SDRu receiver parameters
USRPCenterFrequency = 2.4765e9; 
% 2466

USRPDecimationFactor = MasterClockRate/Fs;

%% burst radio

samples = 1e5;


radio = comm.SDRuReceiver(...
    'Platform',             Platform, ...
    'SerialNum',            Address, ...
    'MasterClockRate',      MasterClockRate, ...
    'CenterFrequency',      USRPCenterFrequency, ...
    'DecimationFactor',     USRPDecimationFactor, ...
    'SamplesPerFrame',      samples, ...
    'EnableBurstMode',      true,...
    'NumFramesInBurst',     1e3,...
    'Gain',                70,...
    'ChannelMapping',       [1 2] ,...
    'TransportDataType',  'int16');

   
%% 268435455 최대 sample 수
%% 365000 

% % Initialize variables
currentTime = 0;
rx = 0;

numFrames = 1e3;
burstCaptures = zeros(samples,2,numFrames);
len=0;
count=0;
delay1 = 0;

% 
% numFrames = 1000;
% burstCaptures = zeros(samples,2,numFrames);
% len=0;
% count=0;
% delay1 = 0;

% release(radio);    
%     
%     
% for frame = 1:numFrames
%     while len == 0
%         [data,len,lostSamples] = step(radio);
%         burstCaptures(:,:,frame) = data;
%     end
%     len = 0;
% end
release(radio);    
    
    
    
    
    for frame = 1:numFrames
        while len == 0
            [data,len,overrun] = radio();
            burstCaptures(:,:,frame) = data;
          if (overrun)
             msg = ['Receiver overrun indicated in frame # ',...
                 int2str(frame),', verify if data has been lost.'];
                disp(msg)
         end
        end
        len = 0;

    end
    
    release(radio)

rx1 = [];
for i = 1:50
    rx1 = [rx1; burstCaptures(:,1,i)]; 
end

figure
t = (1 : length(rx1));
plot(t,abs(rx1))


rx1 = [];
for i = 51:100
    rx1 = [rx1; burstCaptures(:,2,i)]; 
end

figure
t = (1 : length(rx1));
plot(t,abs(rx1))


w_size = 1000;

s_size = 200;



k = 1;



    for Window = 1:1:w_size

        Freq1(k) = Window*(2*10^7/w_size);

        k = k+1;

    end

T_Ft_sig = [];

    

k =1;
list = 1;

for index = transpose(list)

     waveform = transpose(rx1);

    Len_win = length(waveform);

    
    Sam_rate = 10e6;

    time =  (1:w_size:Len_win)/10e6;

    

    Freq = [];



    % FT_sig = zeros(Len_win,Len_win);

    Ft_sig = [];

    ind_w = 1;

    buffer = [];

    Ft_win = [];

    

    

    ind_s = 1;

    
    for Sam_ind = 1:s_size:Len_win - w_size+1

        

        waveform_win = transpose(waveform(1,Sam_ind:Sam_ind+w_size - 1));

        

        buffer = fft(waveform_win);

        Ft_win = fftshift(buffer);

        

        Ft_sig(:,ind_s) = Ft_win;        



        ind_s = ind_s +1;

    end

    

    

    figure

    imagesc(time,Freq1, transpose(round(abs(transpose(Ft_sig)))))

    colorbar



    k = k+1;

    
% 
%     figure 
% 
%     t = (1:length(waveform))/2e7;
% 
%     plot(t,waveform)
% 
      

end
