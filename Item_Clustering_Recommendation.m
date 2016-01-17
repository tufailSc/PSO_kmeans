
clear;
close all;

%% 1. �Φ��Τ�-���دx�}�A�o�O�Ӻ�k�̮ڥ����ƾڵ��c

% LOAD DEFAULT CLUSTER (IRIS DATASET); USE WITH CARE!

fprintf('Load training and testing data\n');

dataSetName = 'testdata';
foldCount = 1;
baseFilename = [dataSetName '_' num2str(foldCount) '.base'];
testFileName = [dataSetName '_' num2str(foldCount) '.test'];

delimiterIn = '\t'; %�J��H�ťն��j�ɭn����' '
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


%% 2. �׶q�ۦ���
% use pearson correlation coefficient

%% 3. �ھ�PSO-kmeans ��k���ͻE���A�p��F�~���X

fprintf('Start item-based clustering\n');

% (1) ���ػE��(Item-based clustering)
% ��J�G �Τ�����x�} userData(m, n) (m users, n items)�A�E���Ӽ� s�A�ɤl�ƥ� k
% ��X�G s �ӻE���Ψ䤤��
s = 2;
k = 10;
[overall_c, swarm_overall_pose] = pso_kmeans(userData', s, k);

fprintf('Start generate specific item prediction score\n');

% (2) �̪�F�j��
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
    
    % a. �p��ؼж��P�C�ӻE�����ߪ��ۦ���
    targetItemData = userData(:,targetItem);
    for clusterCount = 1:size(swarm_overall_pose,1)
        clusterCentroid = swarm_overall_pose(clusterCount,:)';
        similarity = corr(targetItemData, clusterCentroid, 'type', 'Pearson');
        
        % b.1 ��ܤp��ۦ����H�Ȫ��E�����ߩҦb���E��
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
    % b.2 ��p��ۦ����H�Ȫ��E�����ߩҦb���E���i��j���A�p��E�������ػP�ؼж��ت��ۦ���
    for neighborItemCount = 1:size(clusterDataCollection,2)
        neighborItemData = clusterDataCollection(:, neighborItemCount);
        similarityRec(neighborItemCount) = corr(targetItemData, neighborItemData, 'type', 'Pearson');
    end
    
    % c. ��X�P�ؼж��س̬۪񪺫e N �ӾF�~�@���ؼж��ت��̪�F�~�C
    [sortedSimilarityRec,sortedSimilarityRecIndex] = sort(similarityRec,'descend');
    if size(similarityRec,1)<= N
        neighborItems = clusterItemsCollection;
    else
        neighborItems = clusterItemsCollection(sortedSimilarityRecIndex(1:N));
    end
    
    
    %% 4. ��ܹw�������A���͹w��
    targetItemPredictionScore = predict( userData, user, targetItem, neighborItems);
    
    %% 5. �p��absolute error
    absoluteError = abs(targetItemPredictionScore - targetItemScore);
    absoluteErrorSum = absoluteErrorSum + absoluteError;
    
    fprintf('Testing data row %d has predicted completely, prediction score %.3f, score %.3f, absolute error %.3f\n', testDataRowCount, targetItemPredictionScore, targetItemScore, absoluteError);
end

mae = absoluteErrorSum/size(testData,1);
fprintf('MAE is %.3f\n',mae);


