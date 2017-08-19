clear ;
clc;
cd D:/MATLABsave/Hyper/ʥ���Ǹ��������/local
load Sandiego.mat
load PlaneGT.mat
P=PlaneGT;
S=Sandiego(1:100,1:100,10:79);  %S�����Ͻ�100*100�Ĳ��֣�ѡȡ10~79��70�����ν��з�����
[S_h,S_w]=size(P);
get_target_index

%��һ��
% S_=Sandiego(1:100,1:100,10:79);  %S�����Ͻ�100*100�Ĳ��֣�ѡȡ10~79��70�����ν��з�����
% S_temp=zeros(100,100,70);
% for i=1:100
%     for j=1:100
%         for k=1:70
%             S_temp(i,j,k)=S_temp(i,j,k)+S_(i,j,k);
%         end;
%     end;
% end;
% S_temp=S_temp/70;
% max_=max(max(S_temp));
% max_=max_(:);S
% min_=min(min(S_temp));
% min_=min_(:);
% S=zeros(100,100,70);
% for i=1:100
%     for j=1:100
%         for k=1:70
%           S(i,j,:)=(S_temp(i,j,:)-min_(k))/(max_(k)-min_(k))*255;
%         end;
%     end;
% end;
% S=floor(S);

%%%%%%%%%%%%%%%%%%%%%%%%
%ѡȡ��һ��Ŀ�깲14�����ص���ΪĿ���ֵ�

Dict_t=zeros(70,14);
for i=1:14
    Dict_t(:,i)=S(target_index(i,1),target_index(i,1),:);  
end;

%%%%%%%%%%%%%%%%%%
%DUAL WINDOW���
%inner window 5*5
%outer window 11*11
%      ����������������
%      |      outer             |
%      |           ����         |
%      |         | inner|        |
%      |         |         |       |
%      |           ����         |
%      ����������������
%%%%%%%%%%%%%%%%%%%

%�߽�����
S_expand=zeros(110,110,70);
for i=1:5
    S_expand(6:105,i,:)=S(:,1,:);
    S_expand(6:105,i+105,:)=S(:,100,:);
end;
for i=1:5
    S_expand(i,6:105,:)=S(1,:,:);
    S_expand(i,1:5,:)=S_expand(6,1:5,:);
    S_expand(i,106:110,:)=S_expand(6,106:110,:);
    S_expand(i+105,6:105,:)=S(100,:,:);
    S_expand(i+105,1:5,:)=S_expand(105,1:5,:);
    S_expand(i+105,106:110,:)=S_expand(105,106:110,:);
end;
S_expand(6:105,6:105,:)=S(:,:,:);

%��������ص�
K=3;
Dict_b=zeros(70,96);   %11*11-5*5
Dict=zeros(70,110);


Residual2=zeros(100,100);
for i=6:105
    for j=6:105
        bg_index=1;
       for p=i-5:i+5
           for q=j-5:j+5
               if abs(p-i)>2 || abs(q-j)>2
                   Dict_b(:,bg_index)=S_expand(p,q,:);    %����ÿһ������outer window���챳���ֵ�
                   bg_index=bg_index+1;
               end;
           end;
       end;
       Dict(:,1:96)=Dict_b(:,:);
       Dict(:,97:110)=Dict_t(:,:);   %�������ֵ�A
       y=S_expand(i,j,:);
       y=y(:);
       gamma=OMP(y,Dict,K);
       gamma_b=gamma(1:96);
       gamma_t=gamma(97:110);
       y_b=Dict_b*gamma_b;
      % r_b=norm(y_b-y);%�ָ��в�
      r_b=y'*y_b;
       y_t=Dict_t*gamma_t;
      % r_t=norm(y_t-y);%�ָ��в�
      r_t=y'*y;
       Dx=r_b*(1/r_t);
       Residual2(i-5,j-5)=Dx;
    end;
end;
    start_=-3;step=0.1;end_=2;   %ȡֵ��Χ
    num=floor((end_-start_)/step)+1;
    coord=zeros(num,2);
    coord_index=1;
    MIN_DISTENCE=1000000;    %��¼���ŵ���ֵ
for threshold=start_:step:end_
    P_compare=zeros(P_h,P_w);
    for i=1:S_h
        for j=1:S_w
            if Residual2(i,j)>threshold
                 P_compare(i,j)=1;
            end;
        end;
    end;
    sum_TP=0;    %������
    sum_FP=0;    %α����
    sum_FN=0;    %α����
    sum_TN=0;    %������
    for i=1:P_h
     for j=1:P_w
            if P_compare(i,j)==1&&PlaneGT(i,j)==1
             sum_TP=sum_TP+1;
            elseif P_compare(i,j)==0&&PlaneGT(i,j)==1
             sum_FN=sum_FN+1;
            elseif P_compare(i,j)==0&&PlaneGT(i,j)==0
             sum_TN=sum_TN+1;
            elseif P_compare(i,j)==1&&PlaneGT(i,j)==0
             sum_FP=sum_FP+1;
           end;
     end;
    end;
    FPR=sum_FP/(sum_FP+sum_TN);    %α������
    TPR=sum_TP/(sum_TP+sum_FN);    %��������
    distence=(FPR)^2+(1-TPR)^2;
    if distence<MIN_DISTENCE
        MIN_DISTENCE=distence;
        BEST_THRESHOLD=threshold;
    end;
    coord(coord_index,1)=FPR;
    coord(coord_index,2)=TPR;
    coord_index=coord_index+1;
end;
%ROC����
X=coord(:,1);
Y=coord(:,2);
figure;
plot(X,Y),xlabel('FPR'),ylabel('TPR');%���ROC����

  P_compare=zeros(S_h,S_w);
    for i=1:S_h
        for j=1:S_w
            if Residual2(i,j)>BEST_THRESHOLD
                 P_compare(i,j)=1;
            end;
        end;
    end;
    
%%��ͼ
figure
subplot(1,2,1);
imshow(PlaneGT),title('��׼ͼ��');
subplot(1,2,2);
imshow(P_compare),title('�����');

