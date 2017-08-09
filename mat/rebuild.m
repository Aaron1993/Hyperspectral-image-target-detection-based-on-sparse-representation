Dict_build
K=3;
x=S(18,50,:);
x=x(:);
tic
theta1=omp_norm(x,Dict,K);
x_r_1=Dict*theta1;
toc
tic
theta2=omp_norm(x,Dict_t,K);
x_r_2=Dict_t*theta2;
toc
tic
theta3=omp_norm(x,Dict_b,K);
x_r_3=Dict_b*theta3;
toc
%% ��ͼ
figure(1);
subplot(1,3,1);
plot(x_r_1,'r');%���x�Ļָ��ź�
hold on;
plot(x,'k.-');%���ԭ�ź�x
hold off;
legend('Recovery','Original')
fprintf('\nDict�ָ��в');
norm(x_r_1-x)%�ָ��в�

subplot(1,3,2);
plot(x_r_2,'r');%���x�Ļָ��ź�
hold on;
plot(x,'k.-');%���ԭ�ź�x
hold off;
legend('Recovery','Original')
fprintf('\nDict_t�ָ��в');
norm(x_r_2-x)%�ָ��в�

subplot(1,3,3);
plot(x_r_3,'r');%���x�Ļָ��ź�
hold on;
plot(x,'k.-');%���ԭ�ź�x
hold off;
legend('Recovery','Original')
fprintf('\nDict_b�ָ��в');
norm(x_r_3-x)%�ָ��в�