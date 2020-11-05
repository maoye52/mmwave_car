clear all;close all;clc;

%������Ŀ������
TargNumMax = 64;

%�����ļ�������������ṹ��
addpath('SubFunction');

%% paramRadar

lightspeed                      = 299792458;                       %����
%mmwave_studio���ò���
txNum                           = int32(2);                            %��������
rxNum                           = int32(4);                            %��������
sampleRate                    = 10e6;                                %������
rangeSmpNum              = int32(128);                          %��������
chirpNum                      = int32(128);                         %chirp����
rangeSmpTime              = double(rangeSmpNum)/sampleRate;  %����ʱ��
centerFreq                     = 77e9;                              %����Ƶ��
freqSlope                      = 29.982e12;                         %��Ƶб�ʣ���λHz/s
idleTime                        = 30e-6;                            %����ʱ��
ADCstartTime                = 6e-6;                            %ADC��ʼʱ��
rampEndTime                = 40e-6;                           %��Ƶ����ʱ��
framePeriod                  = 40e-3;                           %פ������
FrameNum                    = 1000;                             %�ɼ�פ������

%ͨ�����ò�������õ�

Rx_n                         = rxNum * txNum;           %��Ч����������Ŀ

lamda                        = lightspeed/centerFreq;   %����
bandwidth                    = freqSlope*rampEndTime;	%����
chirpRepTime                 = double(txNum)*(idleTime + rampEndTime);	%һ��chirp��ʱ��
chirpRepFreq                 = 1/(chirpRepTime);	%FMCW����Ƶ��
chirpTime                    = double(chirpNum)*chirpRepTime;	%����chirpռ�õ�ʱ��
rangeRes                     = 299792458/2/freqSlope*sampleRate/double(rangeSmpNum);    %����ֱ��ʣ�c/2/miu*Fs/SampleN=c/2B
velocityRes                  = 299792458/centerFreq/2/chirpRepTime/double(chirpNum); %�ٶȷֱ��ʣ�c/fc/2/ChirpTime/ChirpN
maxRange                     = 299792458/2/freqSlope*sampleRate;		%������ֵ��c/2/miu*Fs
maxVelocity                  = 299792458/centerFreq/4*chirpRepFreq;    	%�������ֵc/fc/4/ChirpTime
fIFMax                       = freqSlope*2*maxRange/lightspeed;
WorkTime                     = framePeriod - chirpTime;     %chirp��ʣ��ʱ�䣬��������

%����1642���Ƕȷ�Χ120��������������߼��
distanceRX                   = lamda/2;     %�������߼��
distanceTX                   = distanceRX*4;     %�������߼��

SampleM = double(rangeSmpNum);
ChirpN = double(chirpNum);
RxP = double(rxNum);
dPerRx = distanceRX;
%3άFFT��������
RFFTNum =1* power(2,ceil(log2(SampleM)));       %����άFFT����
MTDFftNum =1* power(2,ceil(log2(ChirpN)));      %�����յ���
FFTNumdbf =128;                              %��ͬ����ͨ����FFT��������Ƕ�
%ÿ�����Ӧ����Ϣ            
rangeCell               = maxRange/RFFTNum;	%FFT��chirp��ÿ�������ľ���
velocityCell            = 2*maxVelocity/MTDFftNum;	%FFT��chirp��ÿ���������ٶ�,��λ��Χ[-1,1],��˼��㲽����ʱ��Ҫ*2
angleCell = 2*asin(lamda/(2*dPerRx)) *180/pi/FFTNumdbf;    %�Ƕ�����%��λ��Χ[-1,1],��˼��㲽����ʱ��Ҫ*2
%����
X_All = ( -RFFTNum/2 )*rangeCell:rangeCell:(RFFTNum/2-1)*rangeCell;    %X������,�и���
%���ھ���û�и�ֵ������X����
X_1 = 0:rangeCell:(RFFTNum/2-1)*rangeCell;
X_Half = fliplr(X_1);       %������ת
V = ( -MTDFftNum/2+1 )*velocityCell:velocityCell:(MTDFftNum/2*velocityCell);    %Y������
% Z = (-FFTNumdbf/2+1)*angleCell:angleCell:(FFTNumdbf/2)*angleCell;
%Z����ת����m��Ϊ�˹۲ⷽ��
% ZmCell = maxRange/FFTNumdbf;
% Zm = (-FFTNumdbf/2+1)*ZmCell:ZmCell:(FFTNumdbf/2)*ZmCell;
%         

%�ɼ����������Ͳ�ͬ��ͬһפ��ȡ���ĳ��Ȳ�ͬ��complex2x
sizeofData = 2;
dxstart = 1;

%��¼Ŀ��켣�仯
gfvRmax = zeros(1,FrameNum);
%����ṹ��
TARGETPARA = struct(...
                    'Rr',                0.0, ...        % Ŀ����룬��
                    'Vr',               0.0, ...        % Ŀ���ٶȣ�m/s
                    'Angle',            0.0, ...        % ��λ�Ƕ�,��
                    'Rx',               0.0, ...        %ת����ֱ�������X�����
                    'Raz',              0.0, ...        % Ŀ�귽λ����루�Ƕ�ת���룩����
                    'Amp',              0.0  ...        % �źŷ���
                    );
%��¼����֡���е㼣
TARGOUT = struct(... 
                'ValidFlag',        0.0, ...            %����Ƿ���Ч��0��û��Ŀ�꣬1���쵽Ŀ��
                'TargetNum',        0.0, ...            %��⵽��Ŀ�����
                'TargetPara',       repmat(TARGETPARA, 1, TargNumMax) ...
);
gsvTargAll  = repmat(TARGOUT, 1, FrameNum);

%% ����·��

%����·���ķ�ʽ 0������ļ��Զ����룬1��ѡ��Ҫ����bin�ļ�
datapathctl = 0;    


if datapathctl == 1     %ֻ��һ��bin�ļ�
%     fname='E:\data_dca\1022_2floor\adc_data_2��_ǰ��.bin';
        fname='E:\data_dca\1022_2floor\center\adc_data_2��_ǰ��.bin';
%     fname='E:\data_dca\AWR1642_0925\adc_data_22.bin';
    datafileNum = 3;       %���ڶ�ȡ�ļ�����bin�ļ�����Ŵ�3��ʼ��Ϊ�˷��������forѭ����ֻ��һ���ļ���ʱ�����������3
    fileCtl = 0;
else
    % �ж��bin�ļ�����Ҫ�ֱ����
%     pathName = 'E:\data_dca\1013office_2\ceil\2T_rendong';
%         pathName = 'E:\data_dca\1013office_2\adc_1p8_2T_ren';
% pathName='E:\data_dca\1022_2floor\ceil\2renxianhou';
    pathName = 'E:\data_dca\1014Parking_2\2T_miu30_128_fu2';
    
    radarPathName = strcat(pathName,'\');
    radarfile = dir(radarPathName);
    datafileNum = length(radarfile);
    fileCtl = 1;
   
end

 for dataIdx = 3:datafileNum
     % read data
    if fileCtl == 0
        fid = fopen(fname,'rb'); 
    else
        fileName = radarfile(dataIdx).name;
        fid = fopen([radarPathName,fileName],'r');
    end

    MTIFlag = 1;    %�����Ƿ���MTI
    ThreshFlag  = 0;    %����ѡ��1�������ޣ�ȱʡ��cfar
    FigNum = 0;
    ValidNum = 0;
    TargNumTemp = 0;

    colorMatrix = [0 0 0 ; 1 0 0 ; 0 1 0 ; 0 0 1 ; 1 0 1 ; 0 1 1 ];%�� �� �� �� ��� ����

    [row_cl,col] = size(colorMatrix);

    for frameIdx = dxstart:FrameNum

        if mod(frameIdx ,100)==0
            pause(0.01);
        end

        
        if frameIdx == 120
            pause(0.01);
        end
        
        %% read data
        %�������� 
        sdata = fread(fid,rangeSmpNum*chirpNum*...
                rxNum*txNum * sizeofData,'int16');

        % 1642+DCA1000
        %�ļ�����
        fileSize = size(sdata, 1);
        %����¼ȡ��ʵ���鲿
        lvds_data = zeros(1, fileSize/2);
        M = rangeSmpNum;
        N = chirpNum;
        %����Data Capture.pdf�ϵ�matlab����������������
        %LVDSʹ������ͨ���������ݶ�ȡ
        lvds_Lanes = 2;
        Gn = lvds_Lanes * sizeofData;

        count = 1;

        for i=1:Gn:fileSize-5

           lvds_data(1,count) = sdata(i) + 1i*sdata(i+2); 

           lvds_data(1,count+1) = sdata(i+1)+1i*sdata(i+3); 

           count = count + 2;

        end
        %�ɼ�ʱ����ʱ����T1T2����ʱ���գ�����chirp��Ϊһ�飬loopsΪN
        %���� Tx1chirp1 Rx1 2 3 4 ,Tx2chirp1 Rx1 2 3 4 ,Tx1 chirp2Rx1 2 3 4 ,Tx2
        %chirp2 Rx1 2 3 4 ...
        num_chirps = txNum*N;

        lvds_data = reshape(lvds_data, M*rxNum, num_chirps);
        %ע����.'�����ֻ��'��ʾ����ת��
        lvds_data = lvds_data.';

        cdata = zeros(rxNum,num_chirps*M);

        for row = 1:rxNum

            for i = 1: num_chirps

                cdata(row,(i-1)*M+1:i*M) = lvds_data(i,(row-1)*M+1:row*M);

            end

            data_radar_Temp = reshape(cdata(row,:),M,num_chirps);   %RXn

            if txNum==1 %һ����������
                RxData(:,:,row) = data_radar_Temp;
            elseif txNum == 2
                %�ֱ�ȡ�������������߶�Ӧ�Ľ�������
                Tx1Data(:,:) = data_radar_Temp(:,1:2:num_chirps);
                Tx2Data(:,:) = data_radar_Temp(:,2:2:num_chirps);
                %��ɵ�Ч��������
                RxData(:,:,row) = Tx1Data;
                RxData(:,:,row+4) = Tx2Data;
            else
            end
        end

        %����Chirp1����
%         EchoTemp(:) = RxData(:,1,1);
%         figure(1);
%         plot(real(EchoTemp));hold on;
%         plot(imag(EchoTemp),'r'); hold off;
%         title('Chirp1����');
%         legend('Real','Imag');

            %-------------------  ����˲ʱƵ��  -------------------
    %         Tx1chirp1 = RxData(:,1,1);
    %         Tx2chirp1 = RxData(:,1,1);
    %         Tx1phi = phase(Tx1chirp1);
    %         Tx2phi = phase(Tx2chirp1);
    %         t_ins = 1/sampleRate*(1:SampleM);
    %         Tx1f_ins = Tx1phi./t_ins;
    %         Tx2f_ins = Tx2phi./t_ins;
    %         FigNum=FigNum+1;figure(FigNum);
    %         plot(Tx1f_ins);hold on; plot(Tx2f_ins,'r');
    %         legend('Tx1','Tx2');
    %         title('˲ʱƵ��');
    %        

        range_win = hamming(SampleM);   %�Ӻ�����
        %ע������forѭ���������forѭ����ͬ
        for ii = 1:Rx_n
             %����άFFT
            for jj=1:ChirpN
                ffttemp = RxData(:,jj,ii).*range_win;
                FFTOut(jj,:) = fft(ffttemp,RFFTNum);
            end
            shiftfft = fftshift(FFTOut);
            %����һ��chirp��һάdBͼ���۲�
    %         Tempfft = shiftfft(22,:);
    %         logFftOut = log2(abs(Tempfft)/max(abs(Tempfft)));
    %         FftOut = abs(Tempfft);
    %         figure(2);
    %         plot(X_All,logFftOut);
    %         titlename=['פ����',num2str(frameIdx),'��������',num2str(ii),'Chirp1��һάFFT'];
    %         title(titlename)
    %         xlabel('���루m/s��');
    %         ylabel('����dB')
    %         
            %FFT���һά����
            FFTAll = reshape(FFTOut,1,[]);

            %MTI,ȥ���̶�Ŀ��
            if MTIFlag == 1
                for jj=3:ChirpN
                    MTIOut(jj-2,:) = FFTOut(jj,:) + FFTOut(jj-2,:) -2*FFTOut(jj-1,:);
                end
                MTD_win = ChirpN - 2;
            else
                MTIOut = FFTOut;
                MTD_win = ChirpN;
            end

            vel_win = hamming(MTD_win);   %�Ӻ�����
            %MTD���ٶ�άFFT�����ڲ���
            for kk = 1:RFFTNum
                ffttemp1 = MTIOut(:,kk).*vel_win;
                MTDOutTemp(kk,:) = fft(ffttemp1,MTDFftNum);
            end
            ShiftMtd = fftshift(MTDOutTemp);

            %ע�⣬MTDOut��M*N����
            SampleMOut = RFFTNum;
            if SampleMOut == RFFTNum
                X1 = X_All;
            else
                X1 = X_Half;
            end
            MTDOut = ShiftMtd(1:SampleMOut,:);

            absMTDOut = abs(MTDOut)';
    %         figure(3);
    %         mesh(X1,Y,absMTDOut); 
    %         view(0,90);     %����ͼ
    %         titlename=['פ����',num2str(frameIdx),'��������',num2str(ii),'��MTD���'];
    %         title(titlename)
    %         
    %         xlabel('����m');
    %         ylabel('�ٶ�m/s');
    %         pause(0.01);

            absMTDOutAll(ii,:,:) = absMTDOut;
            FFT2D(ii,:,:) =MTDOut;
        end     %end of for ii = 1:Rx_n

        %ͨ���ۼӣ���ͬ�������ߵ���ͬ���ֵ�ۼ�  ,���ۼӺ�ķ�ֵ������cfar���
        AmpOutAll(:,:)= sum(absMTDOutAll,1)/double(Rx_n);

        figure(4);
        mesh(X1,V,AmpOutAll); 
    %     mesh(AmpOutAll); 
        view(0,90);     %����ͼ
        titlename=['פ����',num2str(frameIdx),'��ͨ���ۼӷ�ֵ����'];
        title(titlename)
        xlabel('����m');
        ylabel('�ٶ�m/s');
        pause(0.01);


            %------------------cfar ��������------------------
            %�ṹ�嶨��
            %caCfarParaIn = struct('gap', {1,6}, 'width', {1,6}, 'cfarType', {1,6}, 'factor', {1,6}, 'offset', {1,6}, 'boundary', {1,6});
            %cfar����
            CfarN = 2;          %������Ԫ����
            CfarM = 8;         %���뻬��������,���۴�����
            CfarFactor = 4;     %��������
            CfarOffset = 40;   %����ֱ��ƫ����
            %����һά������������ֵ��Ӧλ��������Rdet��������ʱ���Խ��ж�ά���
            Rdet = 5;
            %��Ϊ��һ��Ŀ����ٶ����������
            %Vdet = 4;

            %�ṹ�����
            caCfarParaIn.gap 		= CfarN;        %������Ԫ����
            caCfarParaIn.width 		= CfarM;        %���뻬��������
            caCfarParaIn.factor 	= CfarFactor;	%��������
            caCfarParaIn.offset		= CfarOffset;	%����ֱ��ƫ����
            caCfarParaIn.cfarType	= 0;            %���뻬��ƽ������ʽ0:����ƽ��;1:����ƽ��ѡ��; 2:����ƽ��ѡС,3:������
            caCfarParaIn.boundary	= 1;            %�߽紦��ʽ0:�̶�ֵ;1:��������ֵ

            %����chirpsÿ�����뵥Ԫ����cfar����
            Vlg = zeros(MTDFftNum,SampleMOut);
            for kk1 = 1:MTDFftNum
                %���ɻ���
                buffData=zeros(1,SampleMOut);
                if ThreshFlag == 1
                    %������
                    %�������޼�������ʹ�õľ��뵥Ԫ����Ϊ
                    ThreshCountNum = SampleMOut/4;
                    SlowCoeff = 120;
                    [Threshold(kk1,:),reFlag(kk1)] = SlowThresh(AmpOutAll(kk1,:), SampleMOut, SlowCoeff, ThreshCountNum);
                else
                    %����cfar����ֵ
                    [Threshold(kk1,:),reFlag(kk1)] = caCfar(caCfarParaIn, AmpOutAll(kk1,:), buffData, SampleMOut);
                end
                %����������1
                Vlg(kk1,:) = AmpOutAll(kk1,:) > Threshold(kk1,:);

            end
            aa = find(Vlg > 1e-3); %find���ҵ�ʱ�����к���
            %------------------���
            % һά��� ����ά����0-5
            [TotalTgtNum,Tinfo2]=D1correlation2(Vlg,Threshold,caCfarParaIn.factor,AmpOutAll,MTDFftNum,SampleMOut,Rdet);

            % ��ά��� �ٶ�ά����0-5
            %struct Plot
            %{
            %	V;VStart;VEnd;
            %	Sigmags;RMax;VMax;
            %	R;RStart;REnd;
            %	Azimuth;Time;Flag
            %}
            [Plot,CurrentTarNum]=D2correlation2_dsp(Tinfo2,MTDFftNum,TargNumMax,MTDFftNum);

            %ȡ����ά��غ��Ŀ�����
            if CurrentTarNum > 0
                %ȡ���ĵ㼣��Ϣ�������ֵ�����������ķ���0:���ģ�1:���ֵ
                Calflag = 1;
               [fvRIndex ,fvVIndex, AmpAll] = GetAllTargCoordinate(Calflag , Plot );

            end
            fvAmax = zeros(SampleMOut,MTDFftNum);

            for ii = 1:CurrentTarNum
                fvAmax(fvRIndex(ii),fvVIndex(ii)) = AmpAll(ii);
            end


    %         if CurrentTarNum > 0
    %             figure(8);
    %             mesh(fvAmax');
    %             title('Cfar���������غ�')
    %             xlabel('����ά�������㣩');
    %             ylabel('������ά�������㣩');
    %         end
    %         
            %����������ռ�⵽��Ŀ�����
            ivTargNum = CurrentTarNum;
            %-----------------����Ŀ�����

            pause(0.01);

        %��FFT2D��ȡ������Ŀ��ĸ���ֵ
        for ii = 1:ivTargNum

            %�ֱ�õ�����ά�ٶ�ά����
            RIndex = fvRIndex(ii);
            VIndex = fvVIndex(ii);
            %ȡ�������ն�Ӧ����Ϣ�����ں�����ͬ��������֮��FFT��Ƕ�
            for jj = 1:Rx_n
                cvTarg(jj,ii) = FFT2D(jj,RIndex,VIndex);
            end  

        end

        %��ͬͨ������ͬĿ�꣬��FFT����ЧDBF
        fvDBFAmax = zeros(1,SampleMOut);
        %���鶨�壬��ʼ��
        fvTargTheta = zeros(1,FFTNumdbf);
        fvTargR = zeros(1,TargNumMax); 
        Ymeter = zeros(1,TargNumMax); 
        TargInfo = zeros(SampleMOut,FFTNumdbf);

        TargNumOut = 0;
        for ii = 1:ivTargNum
            DBFOut = fftshift(fft(cvTarg(:,ii),FFTNumdbf));
    %         DBFOut = fft(cvTarg(:,ii),FFTNumdbf);

            [Amax,iChnNum] = max(abs(DBFOut));
            Rtemp= X1(fvRIndex(ii));

            %����Ϊ������Ч��ȥ����ֻ�����������Ŀ��
            if  Rtemp >= 0 
                %���Ŀ�����
                TargNumOut = TargNumOut +1;
                %Ŀ�귽λ��
                fw = (iChnNum-FFTNumdbf/2-1)/FFTNumdbf;
                fvTargTheta(TargNumOut) = asin(fw * lamda / dPerRx) * 180 / pi;
            
                %Ŀ�����
                fvTargR(TargNumOut) = Rtemp;
                %ת��Ϊֱ������
                Xmeter(TargNumOut) = cos(fvTargTheta(TargNumOut)*pi/180)*fvTargR(TargNumOut);
                %��λ����ľ���
                Ymeter(TargNumOut) = sin(fvTargTheta(TargNumOut)*pi/180)*fvTargR(TargNumOut);
                %Ŀ���ٶ�
                fvTargV(TargNumOut) = V(fvVIndex(ii));
                %����
                fvDBFAmax(TargNumOut) = Amax;
                TargInfo(fvRIndex(ii),iChnNum) = Amax;
                %����Ŀ��㼣����
                gsvTargAll(frameIdx).TargetPara(TargNumOut).Rr = X1(fvRIndex(ii));
                gsvTargAll(frameIdx).TargetPara(TargNumOut).Vr = V(fvVIndex(TargNumOut));
                gsvTargAll(frameIdx).TargetPara(TargNumOut).Angle = fvTargTheta(TargNumOut);
                gsvTargAll(frameIdx).TargetPara(TargNumOut).Rx = Xmeter(TargNumOut);
                gsvTargAll(frameIdx).TargetPara(TargNumOut).Raz = Ymeter(TargNumOut);
                gsvTargAll(frameIdx).TargetPara(TargNumOut).Amp = Amax;
            end

        end
        %���ͱ�־��Ŀ�����
         if TargNumOut>0
            gsvTargAll(frameIdx).ValidFlag = 1;
            gsvTargAll(frameIdx).TargetNum = TargNumOut;
         else
             gsvTargAll(frameIdx).ValidFlag = 0;
            gsvTargAll(frameIdx).TargetNum = 0;
         end

        %���Ŀ��
        [Ampmax,maxindex] = max(fvDBFAmax);
        gfvRmax(frameIdx) = fvTargR(maxindex);


        if SampleMOut == RFFTNum
            %��������Ч
            TargInfoOut = TargInfo(SampleMOut/2+1:SampleMOut,:);
    %         TargInfoOut = TargInfo(1:SampleMOut,:);
        else
            TargInfoOut = TargInfo;
        end
    %     figure(6);
    % %     subplot(2,1,1);
    %     handle = mesh(Z,X_1,TargInfoOut);
    % %     handle = mesh(TargInfoOut);
    %     view(0,90);
    %     title('Ŀ���˶���Ϣ');
    % %     text1 = text(fvTargTheta(1:TargNumOut),fvTargR(1:TargNumOut)+0.4,num2cell(fvTargV(1:TargNumOut)),'Color','red');
    %     xlabel('��λ�Ƕȣ��ȣ�')
    %     ylabel('Ŀ����루�ף�')
        if TargNumOut>0
                %��Ч���������ڻ�ͼ
                ValidNum = ValidNum + 1;
        end

        %���浱ǰ���ڼ����
        if TargNumOut>0
            TargNumTemp = TargNumOut;
            YOutTemp = Ymeter(1:TargNumOut);
            XOutTemp = Xmeter(1:TargNumOut);
        end
        if mod(frameIdx,1)==0
            if TargNumTemp > 0
                figure(7);
                %��ͼ��ɫ
                Cindex = floor(ValidNum/1);
                colorIndex = mod(Cindex,row_cl) + 1;

                h(ValidNum) = plot(YOutTemp(1:TargNumTemp),XOutTemp(1:TargNumTemp),'*','color',colorMatrix(colorIndex,:));
%                 h(ValidNum) = plot(YOutTemp(1:TargNumTemp),XOutTemp(1:TargNumTemp),'*b');
%                  text1 = text(YOutTemp(1:TargNumTemp),XOutTemp(1:TargNumTemp)+0.04,num2cell(fvTargV(1:TargNumTemp)),'Color','red');
                
                %�޶�����
%                 axis([-5 5 0 10]);
                title('Ŀ����Ϣ');
                xlabel('��λ����루�ף�')
                ylabel('Ŀ����루�ף�')
                hold on;
                pause(0.01);
               %��ʱ�䣬��ͼɾ����Ҳ������delete����
        %         if ValidNum > 40
        %             set(h(ValidNum - 40),'visible','off'); %����ʾ
        %         end
        %          
            end
            %��ͼ�������ʱ����
            TargNumTemp = 0;
        end
    %     mesh(Zm,X_1,TargInfoOut);
    %     view(0,90);
    %     title('Ŀ���˶���Ϣ');
    %     xlabel('��λ����루�ף�')
    %     ylabel('Ŀ����루�ף�')
    %     waitforbuttonpress;


    %20201010��ʱ��ӣ���ά������0.5m���ڵĵĵ���Ϊ��ͬһ��Ŀ��
        %�Ե㼣���кϲ�����ͬĿ����ͷ��Ƚϴ�ĵ�
    %    RZ0P5To1Targ;


        pause(0.01);

    end
    
 end
fclose(fid);
%��������֡�㼣�������˶��켣���ٴ���
% save 'TargInfoAll' gsvTargAll




