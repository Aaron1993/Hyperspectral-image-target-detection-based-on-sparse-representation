function Dict=get_dict_b(i,j,S_expand,Inner,Outer)
%i,j��ʾ��ǰ��������
%S_expand��ʾ����ľ���
%Outer=(Outer window's height-1)/2
%����һ�������ֵ�
b_num=(Outer*2+1)*(Outer*2+1)-Inner*Inner;
Dict=zeros(70,b_num);
    bg_index=1;
       for p=i-Outer:i+Outer
           for q=j-Outer:j+Outer
               if abs(p-i)>floor(Inner/2) || abs(q-j)>floor(Inner/2)
                   Dict(:,bg_index)=S_expand(p,q,:);    %����ÿһ������outer window���챳���ֵ�
                   bg_index=bg_index+1;
               end;
           end;
       end;
end