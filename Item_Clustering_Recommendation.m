
clear;
close all;

%% 1. 形成用戶-項目矩陣，這是該算法最根本的數據結構

% LOAD DEFAULT CLUSTER (IRIS DATASET); USE WITH CARE!

fprintf('Load training and testing data\n');

dataSetName = 'testdata';
foldCount = 1;
baseFilename = [dataSetName '_' num2str(foldCount) '.base'];
testFileName = [dataSetName '_' num2str(foldCount) '.test'];

delimiterIn = '\t'; %遇到以空白間隔時要換成' '
headerlinesIn = 0;

rowBaseData = importdata(baseFilename,delimiterIn,headerlinesIn);
rowBaseData = rowBaseData(:,1:3);

filledScore = 0;
userNum = 20;
itemNum = 10;
userData = repmat(filledScore,[userNum itemNum]);

for rowCount = 1:size(rowBaseData,1)
    userData(rowBaseData(rowCount,1), rowBaseData(rowCount,2)) = rowBaseData(rowCount,3);
end

% LOAD DEFAULT TESTING CLUSTER (IRIS DATASET); USE WITH CARE!
testData = importdata(testFileName,delimiterIn,headerlinesIn);
testData = testData(:,1:3);


%% 2. 度量相似性
% use pearson correlation coefficient

%% 3. 根據PSO-kmeans 算法產生聚類，計算鄰居集合

fprintf('Start item-based clustering\n');

% (1) 項目聚類(Item-based clustering)
% 輸入： 用戶評分矩陣 userData(m, n) (m users, n items)，聚類個數 s，粒子數目 k
% 輸出： s 個聚類及其中心
s = 2;
k = 10;
[overall_c, swarm_overall_pose] = pso_kmeans(userData', s, k);

fprintf('Start generate specific item prediction score\n');

% (2) 最近鄰搜索
N = 4;
similarity_threshold = 0.1;

absoluteErrorSum = 0;
allItems = 1:size(userData,2);
for testDataRowCount = 1:size(testData,1)
    
    user = testData(testDataRowCount,1);
    targetItem =  testData(testDataRowCount,2);
    targetItemScore = testData(testDataRowCount,3);
    
    fprintf('Testing data row %d is predicting now, user %d, target item %d, score %d\n', testDataRowCount, user, targetItem, targetItemScore);
    
    clusterDataCollection = [];
    clusterItemsCollection = [];
    
    % a. 計算目標項與每個聚類中心的相似性
    targetItemData = userData(:,targetItem);
    for clusterCount = 1:size(swarm_overall_pose,1)
        clusterCentroid = swarm_overall_pose(clusterCount,:)';
        similarity = corr(targetItemData, clusterCentroid, 'type', 'Pearson');
        
        % b.1 選擇小於相似度閾值的聚類中心所在的聚類
        if similarity > similarity_threshold
            
            temp_overall_c = overall_c;
            temp_overall_c(targetItem) = 0;
            itemIndex = (temp_overall_c == clusterCount);
            
            clusterData = userData(:,itemIndex);
            clusterItems = allItems(itemIndex);
            
            clusterDataCollection = [clusterDataCollection clusterData];
            clusterItemsCollection = [clusterItemsCollection clusterItems];
        end
    end
    
    
    similarityRec = zeros(size(clusterDataCollection,2),1);
    % b.2 對小於相似度閾值的聚類中心所在的聚類進行搜索，計算聚類內項目與目標項目的相似性
    for neighborItemCount = 1:size(clusterDataCollection,2)
        neighborItemData = clusterDataCollection(:, neighborItemCount);
        similarityRec(neighborItemCount) = corr(targetItemData, neighborItemData, 'type', 'Pearson');
    end
    
    % c. 找出與目標項目最相近的前 N 個鄰居作為目標項目的最近鄰居。
    [sortedSimilarityRec,sortedSimilarityRecIndex] = sort(similarityRec,'descend');
    if size(similarityRec,1)<= N
        neighborItems = clusterItemsCollection;
    else
        neighborItems = clusterItemsCollection(sortedSimilarityRecIndex(1:N));
    end
    
    
    %% 4. 選擇預測公式，產生預測
    targetItemPredictionScore = predict( userData, user, targetItem, neighborItems);
    
    %% 5. 計算absolute error
    absoluteError = abs(targetItemPredictionScore - targetItemScore);
    absoluteErrorSum = absoluteErrorSum + absoluteError;
    
    fprintf('Testing data row %d has predicted completely, prediction score %.3f, score %.3f, absolute error %.3f\n', testDataRowCount, targetItemPredictionScore, targetItemScore, absoluteError);
end

mae = absoluteErrorSum/size(testData,1);
fprintf('MAE is %.3f\n',mae);


