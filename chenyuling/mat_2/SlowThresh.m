function[threshOut, reflag] = SlowThresh(dataIn, sampleN, Coeff, threshN)

%dataIn  ��������
%sampleN  �������鳤��
%threshN  ���������������ݳ���


%�����С��������
if sampleN<0 || threshN <0
    reflag = 0;
else 
    reflag = 1;
end

DataTemp = sort(dataIn(1:sampleN));

ftemp = sum(DataTemp(1:threshN))/threshN + 100;

threshOut = ftemp*Coeff*ones(1,sampleN);