clear all
clc
cd D:\MATLABsave\Hyper\ʥ���Ǹ��������
load PlaneGT.mat
load Sandiego.mat
P=PlaneGT;
[P_h,P_w]=size(P);
S=Sandiego(1:P_h,1:P_w,10:79); %�ü�ԭʼͼ��Ϊ100*100,�����۲���������10~79������Ϣ��Ϊ����
[S_h,S_w,S_b]=size(S);
sum=0;
sum_t_ignore=0;   %��¼�����Ե�Ŀ�����ص�
sum_b_ignore=0;
for i=1:P_h
    for j=1:P_w
        S(i,j,:)=S(i,j,:)*0.0001;      %��һ������
        if P(i,j)==1
            sum=sum+1;
            temp=rand(1);
            if temp<0.667         %��ȡĿ�����ص�1/3��Ϊ�ֵ�
                P(i,j)=2;
                sum_t_ignore=sum_t_ignore+1;
            end;
        else
            temp=rand(1);
            if temp<0.667         %��ȡ�������ص�1/3��Ϊ�ֵ�
                P(i,j)=2;               %���б��Ϊ2�����ص㶼���ᱻ��Ϊ�ֵ�
                sum_b_ignore=sum_b_ignore+1;
            end;
        end;
    end;
end;
Dict_t=zeros(S_b,sum-sum_t_ignore);  %Ŀ���ֵ�
Dict_b=zeros(S_b,P_h*P_w-sum-sum_b_ignore);  %�����ֵ�
index_t=1;
index_b=1;
%%%%%%%%%%%%%%%
%  ����Ŀ��ͱ����ֵ�%
%%%%%%%%%%%%%%%
for i=1:P_h
    for j=1:P_w
        if P(i,j)==1
            Dict_t(:,index_t)=S(i,j,:);
            index_t=index_t+1;
        elseif P(i,j)==0
            Dict_b(:,index_b)=S(i,j,:);
            index_b=index_b+1;
        end;
    end;
end;
Dict=zeros(S_b,P_h*P_w-sum_b_ignore-sum_t_ignore);  %ȫ���ֵ�
Dict(:,1:sum-sum_t_ignore)=Dict_t(:,:);
Dict(:,sum-sum_t_ignore+1:P_h*P_w-sum_b_ignore-sum_t_ignore)=Dict_b(:,:);  %����





















