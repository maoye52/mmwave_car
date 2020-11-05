function  [TotalTgtNum,Tinfo2]=D1correlation2(VlgRes,pcresult,cfar_win,SigMags,SpeedNum,RangeNum,MaxRangeCorLen)

%��VlgRes��SigMags���󻯷��ں����⴦��?
%����Ҫ��:VlgRes,SigMags��Ϊ SpeedNum*RangeNum
%MaxRangeCorLenΪ������������ĳ���
%Ҫ������֮ǰ����������ת�õȲ���

%����V*R����,��ͬһ���ٶ����¸��������ŵ����

%struct Tinfo2
%{
%	VTargetFlag;RTargetNum;tinfo_002[]
%}
%VTargetFlag:��ǰ�ٶ�����Ŀ�����ޱ�־,0:��;1:��
%RTargetNum:ͬһ���ٶ����¸�����������Ŀ�����
%tinfo_002[]:��ǰ�������ϵĸ���Ŀ�����Ϣ

%struct tinfo_002
%(
%	RWeight;ACCSigmags;MaxSigmags;VMax;RMax;RStart;REnd
%}
%ͬһ���������ϵĸ���Ŀ���е�һ��
%RWeight:��Ŀ��ľ�������
%ACCSigmags:��Ŀ��ķ����ۼ�
%MaxSigmags:��Ŀ���Ӧ����ѹ����е����ֵ
%VMax:���ٶ��ź�
%RMax:��Ŀ���Ӧ����������
%RStart:������ʼ��Ԫ
%REnd:���������Ԫ

%Tinfo2[]
MAXTGTPERNUM=20;
%��ʼ��Tinfo2[]
for kk1=1:SpeedNum
	Tinfo2(kk1).VTargetFlag=0;
	Tinfo2(kk1).RTargetNum=0;
	for kk2=1:MAXTGTPERNUM
		Tinfo2(kk1).tinfo_002(kk2).RWeight=0;
		Tinfo2(kk1).tinfo_002(kk2).ACCSigmags=0;
		Tinfo2(kk1).tinfo_002(kk2).MaxSigmags=0;
		Tinfo2(kk1).tinfo_002(kk2).VMax=0;
		Tinfo2(kk1).tinfo_002(kk2).RMax=0;
		Tinfo2(kk1).tinfo_002(kk2).RStart=0;
		Tinfo2(kk1).tinfo_002(kk2).REnd=0;
        Tinfo2(kk1).tinfo_002(kk2).snr=0;
	end
end% for kk1=1:RangeNum


debugCnt=0;

TotalTgtNum=0;

%����ͬһ���ٶ����µ����о�����;
VlgResThis=zeros(1,RangeNum);
SigMagsThis=zeros(1,RangeNum);

for kkV=1:SpeedNum
	TgtNum=0;
	SigMagsThis=SigMags(kkV,:);
	VlgResThis=VlgRes(kkV,:);
	
	% [TgtNum,TgtStart,TgtEnd]=sigdetect_m_n(VlgRes,Threshold,SigLen)
	%��ǰ�ٶ��������о����ŵļ��
	[TgtNum,TgtStart,TgtEnd] = sigdetect_m_n(VlgResThis,0.5,RangeNum);
	%Ŀ���������
    if(TgtNum > MAXTGTPERNUM)
        TgtNum = MAXTGTPERNUM;
    end
    
	if TgtNum>0
		%fvar1:���ȼ�Ȩ�ۼ�ֵ
		%fvar2:����ֱ���ۼ�ֵ
		fvar1=0;
		fvar2=0;
        mmTgt=0;
		SigMaxValueArray=zeros(1,TgtNum);
		%Ŀ�����
		for kkTgt=1:TgtNum
			fvar1=0;fvar2=0;
			%ÿ��Ŀ����ռ�ľ�����		
			for kkTgtIndex=TgtStart(kkTgt):TgtEnd(kkTgt)
				fvar1=fvar1+kkTgtIndex*SigMagsThis(kkTgtIndex);
				fvar2=fvar2+SigMagsThis(kkTgtIndex);
            end

            %debugCnt=debugCnt+1
            [SigMaxValue,SigMaxIndex]=max(SigMagsThis(TgtStart(kkTgt):TgtEnd(kkTgt)));
			SigMaxValueArray(kkTgt)=SigMaxValue;
			
            if 1%(TgtEnd(kkTgt)-TgtStart(kkTgt))<=MaxRangeCorLen
                mmTgt = mmTgt+1;
                Tinfo2(kkV).tinfo_002(mmTgt).RWeight=fvar1/fvar2;
                Tinfo2(kkV).tinfo_002(mmTgt).ACCSigmags=fvar2;
                Tinfo2(kkV).tinfo_002(mmTgt).MaxSigmags=SigMaxValue;
                Tinfo2(kkV).tinfo_002(mmTgt).VMax=kkV;
                Tinfo2(kkV).tinfo_002(mmTgt).RMax=TgtStart(kkTgt)+SigMaxIndex-1;
                Tinfo2(kkV).tinfo_002(mmTgt).snr=SigMags(kkV,(TgtStart(kkTgt)+SigMaxIndex-1))/pcresult(kkV,(TgtStart(kkTgt)+SigMaxIndex-1))*cfar_win;
                Tinfo2(kkV).tinfo_002(mmTgt).RStart=TgtStart(kkTgt);
                Tinfo2(kkV).tinfo_002(mmTgt).REnd=TgtEnd(kkTgt);
            end;
% 			Tinfo2(kkV).tinfo_002(kkTgt).RWeight=fvar1/fvar2;
% 			Tinfo2(kkV).tinfo_002(kkTgt).ACCSigmags=fvar2;
% 			Tinfo2(kkV).tinfo_002(kkTgt).MaxSigmags=SigMaxValue;
% 			Tinfo2(kkV).tinfo_002(kkTgt).VMax=kkV;
% 			%Tinfo2(kkV).tinfo_002(kkTgt).RMax=SigMaxIndex;
%             Tinfo2(kkV).tinfo_002(kkTgt).RMax=TgtStart(kkTgt)+SigMaxIndex-1;
% 			Tinfo2(kkV).tinfo_002(kkTgt).RStart=TgtStart(kkTgt);
% 			Tinfo2(kkV).tinfo_002(kkTgt).REnd=TgtEnd(kkTgt);
        end
		
        if mmTgt>0
            Tinfo2(kkV).VTargetFlag=1;
        else
            Tinfo2(kkV).VTargetFlag=0;
        end
		Tinfo2(kkV).RTargetNum=mmTgt;
		TotalTgtNum=TotalTgtNum+mmTgt;
		
        %%%%%%%%%%%%%%%%%����ά����Ҫ������β�ϳɴ��� �ּҺ� 20190731%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 		%������FFT�������β�ķ��Ѻϳ�(liu);��β�߽紦��
% 		%ͬһ���ٶ����ϲ�ֹһ��Ŀ��
% 		%�Ե�һ�������һ��Ŀ��������⴦��
% 		if mmTgt>1
% 			TempTgtStart=Tinfo2(kkV).tinfo_002(1).RStart;
% 			TempTgtEnd=Tinfo2(kkV).tinfo_002(mmTgt).REnd;
% 			
% 			%������β���ѵ����
% 			if TempTgtStart==1 && TempTgtEnd==RangeNum
% 				%bandfvar1:���ȼ�Ȩ�ۼ�ֵ
% 				%bandfvar2:����ֱ���ۼ�ֵ
% 				bandfvar1=0;
% 				bandfvar2=0; 
% 				SigMaxValue=0;
% 				SigMaxIndex=0;
% 				TempNewTgtStart=Tinfo2(kkV).tinfo_002(mmTgt).RStart-RangeNum;
% 				TempNewTgtEnd=Tinfo2(kkV).tinfo_002(1).REnd;
% 				
% 				for kkTgtIndex=TempNewTgtStart:TempNewTgtEnd
% 					NewIndex=mod(kkTgtIndex+RangeNum,RangeNum);
% 					bandfvar1=bandfvar1+kkTgtIndex*SigMagsThis(NewIndex);
% 					bandfvar2=SigMagsThis(NewIndex);
% 					if SigMagsThis(NewIndex)>SigMaxValue
% 						SigMaxValue=SigMagsThis(NewIndex);
% 						SigMaxIndex=kkTgtIndex;
% 					end 	
% 				end
% 				%for
% 				
% 				SigMaxValueArray(1)=SigMaxValue;
% 				%��Ŀ�������
% 				TempRWeight=bandfvar1/bandfvar2;
% 				
% 				if TempRWeight<0
% 					Tinfo2(kkV).tinfo_002(1).RWeight=TempRWeight+RangeNum;
% 				else
% 					Tinfo2(kkV).tinfo_002(1).RWeight=TempRWeight;
% 				end
% 				
% 				Tinfo2(kkV).tinfo_002(1).ACCSigmags=bandfvar2;
% 				Tinfo2(kkV).tinfo_002(1).MaxSigmags=SigMaxValue;
% 				Tinfo2(kkV).tinfo_002(1).VMax=kkV;
% 				Tinfo2(kkV).tinfo_002(1).RMax=mod(SigMaxIndex+RangeNum,RangeNum);
% 				Tinfo2(kkV).tinfo_002(1).RStart=mod(TempNewTgtStart+RangeNum,RangeNum);
% 				Tinfo2(kkV).tinfo_002(1).REnd=TempNewTgtEnd;
% 				Tinfo2(kkV).VTargetFlag=1;
% 				%�ϲ���һ��Ŀ��
% 				Tinfo2(kkV).RTargetNum=mmTgt-1;
% 				mmTgt=mmTgt-1;
% 				TotalTgtNum=TotalTgtNum-1;
% 
% 			end
% 			%TempTgtStart==1 && TempTgtEnd==RangeNum	
% 		end
		%TgtNum>1
	else
		%û����Ŀ��
		Tinfo2(kkV).VTargetFlag=0;
		
	end
	%TgtNum>0
	if 0 
	%----------------------------
	%�޳��˲����԰���������Ŀ��
	% if Tinfo2(kkV).RTargetNum>0
	if TgtNum>0
		SigMaxValueThis=max(SigMaxValueArray);
		%���԰�߶���Ϊ���ֵ��0.1%20*LOG0.1=-20dB
		SigSideMag=0.1*SigMaxValueThis;
		
		NewIndex = 1;
		NewIndexRef=0;
		
		for kkTgt=1:Tinfo2(kkV).RTargetNum
			%ȥ��С�԰�
			if Tinfo2(kkV).tinfo_002(kkTgt).MaxSigmags>SigSideMag
				Tinfo2(kkV).tinfo_002(NewIndex)=Tinfo2(kkV).tinfo_002(kkTgt);
				NewIndex=NewIndex+1;
				NewIndexRef=NewIndexRef+1;
			end
		end
		%�����ܵ�Ŀ����
		TotalTgtNum=TotalTgtNum-Tinfo2(kkV).RTargetNum+NewIndexRef;
		%���±������ŵ�Ŀ�����
		Tinfo2(kkV).RTargetNum=NewIndexRef;
	end
	%Tinfo2(kkV).RTargetNum>0
    end
end
%kkV=1:SpeedNum

end