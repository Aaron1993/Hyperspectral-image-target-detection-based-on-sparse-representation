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
        end;
    end;
end;
for i=1:P_h
    for j=1:P_w
        if P(i,j)==1
            sum_t_ignore=sum_t_ignore+1;
           if sum_t_ignore>floor(sum*1/3)
               P(i,j)=2;
           end;
       elseif P(i,j)==0
             sum_b_ignore=sum_b_ignore+1;
           if sum_b_ignore>floor((P_h*P_w-sum)*1/3)
              P(i,j)=2;
           end;
        
        end;
      
    end;
end;
Dict_t=zeros(S_b,floor(sum*1/3));  %Ŀ���ֵ�
Dict_b=zeros(S_b,floor((P_h*P_w-sum)*1/3));  %�����ֵ�
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
Dict=zeros(S_b,floor((P_h*P_w-sum)*1/3)+floor(sum*1/3));  %ȫ���ֵ�
Dict(:,1:floor(sum*1/3))=Dict_t(:,:);
Dict(:,floor(sum*1/3)+1:end)=Dict_b(:,:);  %����
disp('�Զ����ֵ乹�����')





















