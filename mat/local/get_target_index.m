
%%%%%%%%%%%%%%
%       ��ȡĿ��������
%%%%%%%%%%%%%%
[P_h,P_w]=size(PlaneGT);
target_index=zeros(57,2);   %����֮ǰ�Ľ����֪��һ����57�����ص�
index=1;
for i=1:P_h
    for j=1:P_w
        if PlaneGT(i,j)==1
            target_index(index,1)=i;
            target_index(index,2)=j;
            index=index+1;
        end;
    end;
end;
target_sum=index-1;