function [Plot,CurrentTarNum]=D2correlation2_dsp(Tinfo2,SpeedNum,MaxPlotNum,varVCONDITION)
%����ά���;TinfoΪ��Ӧ��һά��صĽ��;SpeedNum*RangeNum

%struct Plot
%{
%	V;VStart;VEnd;
%	Sigmags;RMax;VMax;
%	R;RStart;REnd;
%	Azimuth;Time;Flag
%}
%V:�ٶ�����;VStart:�ٶ���ʼ��Ԫ;VEnd:�ٶȽ�����Ԫ;
%Sigmags:�źŷ������ֵ;RMax:�źŷ������ֵ���ڵľ�����;VMax:�źŷ������ֵ���ڵ��ٶ���;
%R:��������;RStart:������ʼ��Ԫ;REnd:���������Ԫ;
%Azimuth:��ǰ֡�ķ�λ��;Time:��ǰ֡��ʱ��;Flag:��ر�־
%varVCONDITION:Ϊ����ٶ�������ĳ���

%��Ҫ����ע�����:���ǵ��������Ѿ���һά��صĽ����,�Ѿ������˵�ĸ���,��������ǰ����һ������Ŀ��


%MaxPlotNum:�����Լ������ٸ�Ŀ��(input)
varMAXPLOTNUM=MaxPlotNum;

%��ʼ�������
for kk1=1:MaxPlotNum
	Plot(kk1).V=0;
	Plot(kk1).VStart=0;
	Plot(kk1).VEnd=0;
	
    Plot(kk1).snr=0;
	Plot(kk1).Sigmags=0;
	Plot(kk1).RMax=0;
	Plot(kk1).VMax=0;
	
	Plot(kk1).R=0;
	Plot(kk1).RStart=0;
	Plot(kk1).REnd=0;
	
    Plot(kk1).ACCSigmags = 0;
% 	Plot(kk1).Azimuth=0;
	Plot(kk1).Time=0;
	Plot(kk1).Flag=0;
end
CurrentTarNum=0;
%��Tinfo2�ṹ���е�Ŀ���������ȡ������������ֵ��������
cellTemp = {Tinfo2.RTargetNum};
Index_1D = cell2mat(cellTemp);
%�ҳ�����Ŀ���
Index_R = find(Index_1D > 0);
%�ܼ�⵽Ŀ����ٶ��˲�������
ftemp1 = length(Index_R);


%--------Plot�а��յ�һ����Ŀ����ٶ��˲����������
if ftemp1 == 0
    %һά���û�м�⵽Ŀ��
    CurrentTarNum =0;
else
    Valid1st = Index_R(1); 
    % Valid1stΪ��ǰ���ٶ��˲�����
    for kk2 = 1:Index_1D(Valid1st)
        if CurrentTarNum >= varMAXPLOTNUM
            break;
        end	
        CurrentTarNum = CurrentTarNum + 1;
        Plot(CurrentTarNum).V         = Tinfo2(Valid1st).tinfo_002(kk2).VMax;
        Plot(CurrentTarNum).VStart    = Tinfo2(Valid1st).tinfo_002(kk2).VMax;
        Plot(CurrentTarNum).VEnd      = Tinfo2(Valid1st).tinfo_002(kk2).VMax;

        Plot(CurrentTarNum).snr       = Tinfo2(Valid1st).tinfo_002(kk2).snr;
        Plot(CurrentTarNum).Sigmags   = Tinfo2(Valid1st).tinfo_002(kk2).MaxSigmags;
        Plot(CurrentTarNum).RMax      = Tinfo2(Valid1st).tinfo_002(kk2).RMax;
        Plot(CurrentTarNum).VMax      = Tinfo2(Valid1st).tinfo_002(kk2).VMax;

        Plot(CurrentTarNum).R         = Tinfo2(Valid1st).tinfo_002(kk2).RWeight;
        Plot(CurrentTarNum).RStart    = Tinfo2(Valid1st).tinfo_002(kk2).RStart;
        Plot(CurrentTarNum).REnd      = Tinfo2(Valid1st).tinfo_002(kk2).REnd;

        Plot(CurrentTarNum).ACCSigmags= Tinfo2(Valid1st).tinfo_002(kk2).ACCSigmags;
    end


    for ii1=2:ftemp1
        kk1 = Index_R(ii1); 
        % kk1Ϊ��ǰ���ٶ��˲�����
        % �����ά�㼣��Ϊ�㣬����һά�㼣��ʼ��

        %��ÿһ��һά�㼣�����Ѵ��ڵĶ�ά�㼣������أ���ز��ϵĽ����µĶ�ά�㼣
        flagA = ones(1,varMAXPLOTNUM);%�㼣����ϱ�־
        for kk2=1:Tinfo2(kk1).RTargetNum    % kk2Ϊ���ٶ��˲�����һά�㼣���
            flg = 0;
            a2 = Tinfo2(kk1).tinfo_002(kk2).RStart;
            b2 = Tinfo2(kk1).tinfo_002(kk2).REnd;
            for kk3 = 1:CurrentTarNum       % CurrentTarNumΪ��ǰ��ά�㼣
                a1 = Plot(kk3).RStart;
                b1 = Plot(kk3).REnd;
                if flagA(kk3) == 0
                    continue;
                end
                % �ж��ٶ��˲����Ƿ�����
                if (kk1-Plot(kk3).VEnd) == 1
                    % ���뽻���ж�
                    if ((a2>=a1)&&(a2<=b1)) || ((a1>=a2)&&(a1<=b2))
                        % ��سɹ�
                        flg = 1; 
                        Plot(kk3).RStart    = min(a1, a2);
                        Plot(kk3).REnd      = max(b1, b2);
                        if Plot(kk3).Sigmags < Tinfo2(kk1).tinfo_002(kk2).MaxSigmags
                            Plot(kk3).Sigmags = Tinfo2(kk1).tinfo_002(kk2).MaxSigmags;
                            Plot(kk3).RMax    = Tinfo2(kk1).tinfo_002(kk2).RMax;
                            Plot(kk3).VMax    = kk1; 
                        end
                        RAcc                 = Plot(kk3).R*Plot(kk3).ACCSigmags + Tinfo2(kk1).tinfo_002(kk2).RWeight*Tinfo2(kk1).tinfo_002(kk2).ACCSigmags;
                        VAcc                  = Plot(kk3).V*Plot(kk3).ACCSigmags + Tinfo2(kk1).tinfo_002(kk2).ACCSigmags*kk1;
                        Plot(kk3).ACCSigmags  = Plot(kk3).ACCSigmags + Tinfo2(kk1).tinfo_002(kk2).ACCSigmags;
                        Plot(kk3).R           = RAcc / Plot(kk3).ACCSigmags;
                        Plot(kk3).V           = VAcc / Plot(kk3).ACCSigmags;
                        Plot(kk3).VEnd        = kk1;
                        Plot(kk3).snr = max(Plot(kk3).snr,Tinfo2(kk1).tinfo_002(kk2).snr);
                        break;
                    end
                else
                    flagA(kk3) = 0;          % �������ڣ��򽫸ö�ά�㼣��ر�־λ���㣬�������ڵ�ǰ�˲����ϵ�����һά�㼣����������˶�ά�㼣�����
                end
            end
            % ��û������ϣ������µ㼣
            if flg == 0
                if CurrentTarNum >= varMAXPLOTNUM
                    break;
                end	
                CurrentTarNum = CurrentTarNum + 1;
                Plot(CurrentTarNum).V         = Tinfo2(kk1).tinfo_002(kk2).VMax;
                Plot(CurrentTarNum).VStart    = Tinfo2(kk1).tinfo_002(kk2).VMax;
                Plot(CurrentTarNum).VEnd      = Tinfo2(kk1).tinfo_002(kk2).VMax;

                Plot(CurrentTarNum).snr   = Tinfo2(kk1).tinfo_002(kk2).snr;
                Plot(CurrentTarNum).Sigmags   = Tinfo2(kk1).tinfo_002(kk2).MaxSigmags;
                Plot(CurrentTarNum).RMax      = Tinfo2(kk1).tinfo_002(kk2).RMax;
                Plot(CurrentTarNum).VMax      = Tinfo2(kk1).tinfo_002(kk2).VMax;

                Plot(CurrentTarNum).R         = Tinfo2(kk1).tinfo_002(kk2).RWeight;
                Plot(CurrentTarNum).RStart    = Tinfo2(kk1).tinfo_002(kk2).RStart;
                Plot(CurrentTarNum).REnd      = Tinfo2(kk1).tinfo_002(kk2).REnd;

                Plot(CurrentTarNum).ACCSigmags= Tinfo2(kk1).tinfo_002(kk2).ACCSigmags;
            end
        end
    end
    % for ii = 1:CurrentTarNum
    %         aq(ii) = Plot(ii).Sigmags;
    %     end
    %     [ak,nk] = sort(aq,'descend');
    %     Plot1 = Plot(nk);
    %%%%%%%%%%%%%%�ٶȱ߽紦��%%%%%%%%%%%%%%%
    %ǰ��������ĵ㼣��������ά��С��������
    flagB = ones(1,varMAXPLOTNUM);%�㼣��Ч��־
    for kki=1:CurrentTarNum-1
        if (flagB(kki) == 1)&&(Plot(kki).VStart == 1)%�õ㼣��Ч
            for kkj=(kki+1):CurrentTarNum
                if (flagB(kkj) == 1)&&(Plot(kkj).VEnd == SpeedNum)&&...
                   (((Plot(kki).RStart>= Plot(kkj).RStart)&&(Plot(kki).RStart<=Plot(kkj).REnd))||(( Plot(kkj).RStart>=Plot(kki).RStart)&&( Plot(kkj).RStart<=Plot(kki).REnd)))  
                        %����������Ŀ����һ���µľ�������
                        fweigth0=Plot(kki).R*Plot(kki).ACCSigmags;
                        fweigth1=Plot(kkj).R*Plot(kkj).ACCSigmags;
                        Plot(kki).R=(fweigth0+fweigth1)/(Plot(kki).ACCSigmags+Plot(kkj).ACCSigmags);
                        %���ά������ľ���ά����Сֵ�����ֵ
                        if Plot(kkj).RStart<Plot(kki).RStart
                            Plot(kki).RStart=Plot(kkj).RStart;
                        end
                        if Plot(kkj).REnd>Plot(kki).REnd
                            Plot(kki).REnd=Plot(kkj).REnd;
                        end
                        %�õ��������ֵ�����ꡢȡ���Χ�õ��ٶ���ʼ�ͽ�������
                        if Plot(kkj).Sigmags>=Plot(kki).Sigmags
                            Plot(kki).Sigmags = Plot(kkj).Sigmags;
                            Plot(kki).RMax = Plot(kkj).RMax;
                            Plot(kki).VMax = Plot(kkj).VMax;                               
                        end
                        %kki����,kkj����
                        %����������Ŀ����һ���µ��ٶ�����
                        fweigth0=Plot(kki).V*Plot(kki).ACCSigmags;
                        fweigth1=( Plot(kkj).V-SpeedNum )*Plot(kkj).ACCSigmags;
                        Plot(kki).V=(fweigth0+fweigth1)/(Plot(kki).ACCSigmags+Plot(kkj).ACCSigmags);
                        Plot(kki).V = mod((Plot(kki).V+SpeedNum),SpeedNum);
                        %���ά��������ٶ�ά����Сֵ�����ֵ
                        Plot(kki).VStart = Plot(kkj).VStart;
                        Plot(kki).VEnd = Plot(kki).VEnd;
                        %����������Ŀ����һ���µķ����ۼӺ�,�ڼ��������ĺ�,��������
                        Plot(kki).ACCSigmags = Plot(kki).ACCSigmags + Plot(kkj).ACCSigmags;
                        Plot(kki).snr = max(Plot(kki).snr,Plot(kkj).snr);
                        flagB(kkj)=0;%���ںϵ㼣���ñ�־��Ч
                end
            end%for kkj=(kki+1):SpeedNum
        end%(flagB(kki) == 1)&&(Plot(kki).VStart == 1)%�õ㼣��Ч
    end%for kki=1:SpeedNum-1

    kksave = 0;
    for kki=1:CurrentTarNum
        if (Plot(kki).VStart <= Plot(kki).VEnd)
            vlen = abs(Plot(kki).VEnd-Plot(kki).VStart+1);
        else
            vlen = abs(Plot(kki).VEnd-Plot(kki).VStart+SpeedNum+1);
        end
        if (flagB(kki) == 1)&&(vlen<=varVCONDITION)
            kksave = kksave+1;%��Ч�㼣��
            Plot(kksave) = Plot(kki);
        end
    end
    for kki=kksave+1:CurrentTarNum
        Plot(kki).V=0;
        Plot(kki).VStart=0;
        Plot(kki).VEnd=0;

        Plot(kki).snr=0;
        Plot(kki).Sigmags=0;
        Plot(kki).RMax=0;
        Plot(kki).VMax=0;

        Plot(kki).R=0;
        Plot(kki).RStart=0;
        Plot(kki).REnd=0;

        Plot(kki).ACCSigmags = 0;
    % 	Plot(kki).Azimuth=0;
        Plot(kki).Time=0;
    end
    CurrentTarNum = kksave;

end  %if ftemp1 > 0
end