%% 1. 形成用戶-項目矩陣，這是該算法最根本的數據結構

% LOAD DEFAULT CLUSTER (IRIS DATASET); USE WITH CARE!
filename = 'u1.base';
delimiterIn = '\t';
headerlinesIn = 0;
rawData = importdata(filename,delimiterIn,headerlinesIn);
rawData = rawData(:,1:3);

medianScore = 3;
userNum = 943;
itemNum = 1682;
userData = repmat(medianScore,[userNum itemNum]);

for rawCount = 1:size(rawData,1)
    userData(rawData(rawCount,1), rawData(rawCount,2)) = rawData(rawCount,3);
end

%% 2. 度量相似性
% code is at cosineSimilarity

%% 3. 根據PSO-kmeans 算法產生聚類，計算鄰居集合

% (1) 項目聚類
% 輸入：用戶評分矩陣 userData(m, n)，聚類個數 s，粒子數目 k
% 輸出： s 個聚類及其中心
s = 40;
k = 100;
[c, swarm_pos] = pso_kmeans(userData, s, k);


for user = 1:userNum
    % (2) 最近鄰搜索
    N = 50;
    
    % a. 計算目標項與每個聚類中心的相似性
    
    
    % b. 選擇小於相似度閾值的聚類中心所在的聚類進行搜索，計算聚類內項目與目標項目的相似性
    
    
    % c. 找出與目標項目最相近的前 N 個鄰居作為目標項目的最近鄰居。
    
    
    
    
    
    
    %% 4. 選擇預測公式，產生預測
    
    
    %% 5. 形成推薦
end



