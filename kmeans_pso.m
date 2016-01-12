%Kmeans Cluster Algorithm Based on Particle Optimization Algorithm
clc;clear all;
format long;
%%
%------初始化------------求最小值
%%資料，已經歸一化
sam=[1.0000    1.0000    0.7476    0.6267    0.1696    0.0710    0.2532    0.8110
    0.3188    0.3656    0.8707    0.7704    0.5559    0.5153    0.9213    0.7017
    0.5548    0.7423    1.0000    0.5910    1.0000    1.0000    0.8976    1.0000
    0.7800    0.7181    0.6875    1.0000    0.2115    0.0214    0.1573    0.8938
    0.2680    0.3238    0.9036    0.8210    0.5874    0.3840    0.7037    0.5142
    0.6928    0.6630    0.7368    0.8787    0.1818    0.0786    0.2295    0.3820
    0.4256    0.4978    0.8429    0.9161    0.7133    0.3130    1.0000    0.7809];
%%
N=50;%粒子數
c1=1.2;
c2=1.2;
wmax=0.9;
wmin=0.4;
M=200;%代數
K=4;%類別數，根據需要修改%%%%%%%%%%%%%%%%%%%%%%%%
[S D]=size(sam);%%樣本數和特徵維數
v=rand(N,K*D);%初始速度
%%
%初始化分類矩陣
for i=1:N
clmat(i,:)=randperm(S);
clmat(i,clmat(i,:)>K)=ceil(rand(1,sum(clmat(i,:)>K))*K);
end
fitt=inf*ones(1,N);%初始化個體最優適應度
fg=inf;%初始化群體最優適應度
fljg=clmat(1,:);%當前最優分類
x=zeros(N,K*D);%初始化粒子群位置
y=x;%初始化個體最優解
pg=x(1,:);%初始化群體最優解
cen=zeros(K,D);%類別中心分配空間
fitt2=fitt;%新一代粒子群適應度分配空間
%------迴圈優化開始------------
for t=1:M
for i=1:N
   ww = zeros(S,K);%
   for ii = 1:S
       ww(ii,clmat(i,ii)) = 1;%加權矩陣，元素非0即1
   end
   ccc=[];tmp=0;
   for j = 1:K
        sumcs = sum(ww(:,j)*ones(1,D).*sam);
        countcs = sum(ww(:,j));       
       if countcs==0
          cen(j,:) =zeros(1,D);
       else
         cen(j,:) = sumcs/countcs;  %求聚類中心
       end
       ccc=[ccc,cen(j,:)];%串聯聚類中心成為例子群
       aa=find(ww(:,j)==1);
       if length(aa)~=0
            for k=1:length(aa)
              tmp=tmp+(sum((sam(aa(k),:)-cen(j,:)).^2));%樣本與對應聚類中心距離加總
            end
       end
   end
   x(i,:)=ccc;
   fitt2(i) = tmp; %Fitness value  
end
%更新群體和個體最優解
for i=1:N
        if fitt2(i)<fitt(i) 
            fitt(i)=fitt2(i);
            y(i,:)=x(i,:);%個體最優
            if fitt2(i)<fg
            pg=x(i,:);%群體最優
            fg=fitt2(i);%群體最優適應度
            fljg=clmat(i,:);%當前最優聚類
            end
        end
   end
 bfit(t)=fg;%最優適應度記錄
 w = wmax - t*(wmax-wmin)/M;%更新權重
       for i=1:N  
           %更新粒子速度和位置
%            v(i,:)=w*v(i,:)+c1*rand(1,K*D).*(y(i,:)-x(i,:))+c2*rand(1,K*D).*(pg-x(i,:));
             v(i,:)=w*v(i,:)+c1*rand.*(y(i,:)-x(i,:))+c2*rand.*(pg-x(i,:));
            x(i,:)=x(i,:)+v(i,:);
            for k=1:K
            cen(k,:)=x(i,(k-1)*D+1:k*D);%拆分粒子位置，獲得K個中心
            end
            %重新歸類
            for j=1:S
                    tmp1=zeros(1,K);
                    for k=1:K
                    tmp1(k)=sum((sam(j,:)-cen(k,:)).^2);%每個樣本關於各類的距離
                    end
                    [tmp2 clmat(i,j)]=min(tmp1);%最近距離歸類
            end
      end
end
%------迴圈結束------------
fljg  %最優聚類輸出
fg    %最優適應度輸出
plot(bfit);%繪製最優適應度軌跡