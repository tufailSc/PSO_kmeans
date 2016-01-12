%Kmeans Cluster Algorithm Based on Particle Optimization Algorithm
clc;clear all;
format long;
%%
%------��l��------------�D�̤p��
%%��ơA�w�g�k�@��
sam=[1.0000    1.0000    0.7476    0.6267    0.1696    0.0710    0.2532    0.8110
    0.3188    0.3656    0.8707    0.7704    0.5559    0.5153    0.9213    0.7017
    0.5548    0.7423    1.0000    0.5910    1.0000    1.0000    0.8976    1.0000
    0.7800    0.7181    0.6875    1.0000    0.2115    0.0214    0.1573    0.8938
    0.2680    0.3238    0.9036    0.8210    0.5874    0.3840    0.7037    0.5142
    0.6928    0.6630    0.7368    0.8787    0.1818    0.0786    0.2295    0.3820
    0.4256    0.4978    0.8429    0.9161    0.7133    0.3130    1.0000    0.7809];
%%
N=50;%�ɤl��
c1=1.2;
c2=1.2;
wmax=0.9;
wmin=0.4;
M=200;%�N��
K=4;%���O�ơA�ھڻݭn�ק�%%%%%%%%%%%%%%%%%%%%%%%%
[S D]=size(sam);%%�˥��ƩM�S�x����
v=rand(N,K*D);%��l�t��
%%
%��l�Ƥ����x�}
for i=1:N
clmat(i,:)=randperm(S);
clmat(i,clmat(i,:)>K)=ceil(rand(1,sum(clmat(i,:)>K))*K);
end
fitt=inf*ones(1,N);%��l�ƭ�����u�A����
fg=inf;%��l�Ƹs����u�A����
fljg=clmat(1,:);%��e���u����
x=zeros(N,K*D);%��l�Ʋɤl�s��m
y=x;%��l�ƭ�����u��
pg=x(1,:);%��l�Ƹs����u��
cen=zeros(K,D);%���O���ߤ��t�Ŷ�
fitt2=fitt;%�s�@�N�ɤl�s�A���פ��t�Ŷ�
%------�j���u�ƶ}�l------------
for t=1:M
for i=1:N
   ww = zeros(S,K);%
   for ii = 1:S
       ww(ii,clmat(i,ii)) = 1;%�[�v�x�}�A�����D0�Y1
   end
   ccc=[];tmp=0;
   for j = 1:K
        sumcs = sum(ww(:,j)*ones(1,D).*sam);
        countcs = sum(ww(:,j));       
       if countcs==0
          cen(j,:) =zeros(1,D);
       else
         cen(j,:) = sumcs/countcs;  %�D�E������
       end
       ccc=[ccc,cen(j,:)];%���p�E�����ߦ����Ҥl�s
       aa=find(ww(:,j)==1);
       if length(aa)~=0
            for k=1:length(aa)
              tmp=tmp+(sum((sam(aa(k),:)-cen(j,:)).^2));%�˥��P�����E�����߶Z���[�`
            end
       end
   end
   x(i,:)=ccc;
   fitt2(i) = tmp; %Fitness value  
end
%��s�s��M������u��
for i=1:N
        if fitt2(i)<fitt(i) 
            fitt(i)=fitt2(i);
            y(i,:)=x(i,:);%������u
            if fitt2(i)<fg
            pg=x(i,:);%�s����u
            fg=fitt2(i);%�s����u�A����
            fljg=clmat(i,:);%��e���u�E��
            end
        end
   end
 bfit(t)=fg;%���u�A���װO��
 w = wmax - t*(wmax-wmin)/M;%��s�v��
       for i=1:N  
           %��s�ɤl�t�שM��m
%            v(i,:)=w*v(i,:)+c1*rand(1,K*D).*(y(i,:)-x(i,:))+c2*rand(1,K*D).*(pg-x(i,:));
             v(i,:)=w*v(i,:)+c1*rand.*(y(i,:)-x(i,:))+c2*rand.*(pg-x(i,:));
            x(i,:)=x(i,:)+v(i,:);
            for k=1:K
            cen(k,:)=x(i,(k-1)*D+1:k*D);%����ɤl��m�A��oK�Ӥ���
            end
            %���s�k��
            for j=1:S
                    tmp1=zeros(1,K);
                    for k=1:K
                    tmp1(k)=sum((sam(j,:)-cen(k,:)).^2);%�C�Ӽ˥�����U�����Z��
                    end
                    [tmp2 clmat(i,j)]=min(tmp1);%�̪�Z���k��
            end
      end
end
%------�j�鵲��------------
fljg  %���u�E����X
fg    %���u�A���׿�X
plot(bfit);%ø�s���u�A���׭y��