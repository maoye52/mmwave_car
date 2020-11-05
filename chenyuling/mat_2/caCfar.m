function[y, reflag] = caCfar(caCfarparaIn, x, buff, n) 

%��ʼ���������
k1=0;
reFlag=0;
width=0;gap=0;cfarType=0;offset=0;
factor=0;
y(1) = 0;

%����ƽ�����������ṹ���������ڲ�����
width=caCfarparaIn.width;
gap=caCfarparaIn.gap;
cfarType=caCfarparaIn.cfarType;
factor=caCfarparaIn.factor;
offset=caCfarparaIn.offset;
boundary=caCfarparaIn.boundary;
%����������ݳ��Ȳ�����Ҫ��
    
if (n<=(2*width+2*gap+1) || n<=1) || width<=0
    %�쳣����,�ú�������ֵΪ-1
    reflag=-1;
else
    %���л���ƽ������
    for k1=1:n-width+1
        buff(k1) = (factor/width) * sum(x(k1:(k1+width-1))) + offset;
    end  
    %����ƽ������ʽѡ��
    switch (cfarType)
        %����ƽ��
        case 0          
            %������Ϊk,������Ϊk+_win+2*_gap+1,��Ӧ��Ϊk+_win+_gap
            %��ͼ���
            for k1=1:n-2*width-2*gap
                y(width+gap+k1) = buff(k1) + buff(k1+width+2*gap+1);
            end
            %��ͽ����ƽ��
            y = y * 0.5; 
            %��־λ����
            reflag=0;
        %����ƽ��ѡС
        case 1          
            %������Ϊk,������Ϊk+_win+2*_gap+1,��Ӧ��Ϊk+_win+_gap
            %ȡС����
            for k1=1:n-2*width-2*gap
                y(width+gap+k1) = min(buff(k1),buff(k1+width+2*gap+1));
            end
            %��־λ����
            reflag=0;
        %����ƽ��ѡ��
        case 2          
            %������Ϊk,������Ϊk+_win+2*_gap+1,��Ӧ��Ϊk+_win+_gap
            %ȡС����
            for k1=1:n-2*width-2*gap
                y(width+gap+k1) = max(buff(k1),buff(k1+width+2*gap+1));
            end
            %��־λ����
            reflag=0; 
        %���ڴ���ʽ�ڵ�Ĭ�ϴ���Ϊ����ƽ������,��������ֵΪ-2
        otherwise            
            %������Ϊk,������Ϊk+_win+2*_gap+1,��Ӧ��Ϊk+_win+_gap
            %��ͼ���
            for k1=1:n-2*width-2*gap
                y(width+gap+k1) = buff(k1) + buff(k1+width+2*gap+1);
            end
            %��ͽ����ƽ��
            y = y * 0.5;            
            %��־λ����
            reflag=-2; 
    end %end switch (cfarType)
    
    %���ұ߽紦��
    if boundary %���ұ߽簴�յ��ߴ���
        for k1=1:width+gap
            y(k1) = buff(1+gap+k1);
            y(n-k1+1) = buff(n-width-gap-k1+1);  
        end
    else %���ұ߽簴�����һ����Ч�̶�ֵ����
        for k1=1:width+gap
            y(k1) = y(width+gap+1);
            y(n-k1+1) = y(n-width-gap);  
        end       
    end
end


