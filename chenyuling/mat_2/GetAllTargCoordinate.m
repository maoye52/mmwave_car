function [Rbuf,Vbuf,Ampbuf]=GetAllTargCoordinate(flag,Plot)
%ȡ����ά��غ��Ŀ��������Ϣ
%flag=1ʹ�����ֵ,=0 ʹ������
%struct Plot
		%{
		%	V;VStart;VEnd;
		%	Sigmags;RMax;VMax;
		%	R;RStart;REnd;
		%	Azimuth;Time;Flag
		%}
%ȡ�����е��������
if flag == 1
    %ʹ�����ֵ
    celltemp1 = {Plot(:).RMax};
    datatemp1 = cell2mat(celltemp1);
else
    %ʹ������
    celltemp0 = {Plot(:).R};
    %ע�⣺���ļ���õ�����С�����ں�����������Ҫ�õ��㼣���꣬�����Ҫ��С��ת��������ѡ�������Ϊ����
    datatemp1 = floor(cell2mat(celltemp0));

end
Rbuf = datatemp1;

%ȡ����ά��غ��Ŀ���ٶ�����
celltemp2 = {Plot(:).VMax};
datatemp2 = cell2mat(celltemp2);
Vbuf = datatemp2;

%����Ŀ�����
celltemp3 = {Plot(:).Sigmags};
Ampbuf = cell2mat(celltemp3);
