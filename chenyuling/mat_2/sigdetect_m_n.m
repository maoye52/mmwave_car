function [ TgtNum,TgtStart,TgtEnd ] = sigdetect_m_n( Module,T1,DataLen )
%sigdetect_m_n Summary of this function goes here
%   Detailed explanation goes here
    StartNum = 0;%Ŀ����Ŀ
    TgtStart = [];%zeros(size(Module));
    TgtEnd = [];%zeros(size(Module));
    EndNum  =0;
    QT = zeros(1,DataLen+2);%�����������β��0,�������λ�����ƫ��1
    QT(2:DataLen+1) = (Module > T1);
    for i = 1:DataLen+1
        if((QT(i) == 0)&&(QT(i+1) == 1))
            StartNum = StartNum+1;
            TgtStart(StartNum) = i;
        elseif((QT(i) == 1)&&(QT(i+1) == 0))
            EndNum = EndNum+1;
            TgtEnd(EndNum) = i-1;
        end
    end
    TgtNum = min(StartNum,EndNum);
end
