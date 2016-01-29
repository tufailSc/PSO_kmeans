
clear;
close all;

%% �]�w����Ѽ�

dataSetName = 'testdata';
foldNum = 5;
filledScore = 0; %���ǽפ��ĳ���������ض�J�����϶���������
userNum = 20;
itemNum = 10;

% (1) ���ػE��(Item-based clustering)
% �E���Ӽ� s�A�ɤl�ƥ� k
s = 2;
k = 10;
% (2) �̪�F�j�� �̪�F�ƥ� N
N = 4;
similarity_threshold = 0.1;

%����]�w
fprintf('��ܤ��s�t��k:\n');
fprintf('1) pso_kmeans\n');
fprintf('2) kmeans\n');
selectExperimentType = input('��J���s�t��k����: ');
switch selectExperimentType
    case 1 %1) pso_kmeans
        fprintf('��ܤ��s�t��k: pso_kmeans\n');
        experimentName = 'pso_kmeans';
    case 2 %2) kmeans
        fprintf('��ܤ��s�t��k: kmeans\n');
        experimentName = 'kmeans';
    otherwise
        error('selectFeatureListType error!');
end

%�إߦs����絲�G������Ƨ�
dirpath = ['.'];
if(~exist([dirpath '\exp_result' ],'dir'));
    mkdir([dirpath '\exp_result' ]);
end
resultFileName = [dirpath '\exp_result\' dataSetName '_' experimentName '_result.csv'];
resultData = [];

foldMaeSum = 0;
for foldCount = 1:foldNum
    
    %% 1. �Φ��Τ�-���دx�}�A�o�O�Ӻ�k�̮ڥ����ƾڵ��c
    
    % LOAD DEFAULT CLUSTER (IRIS DATASET); USE WITH CARE!
    
    fprintf('Load training and testing data\n');
    
    baseFilename = [dataSetName '_' num2str(foldCount) '.base'];
    testFileName = [dataSetName '_' num2str(foldCount) '.test'];
    
    delimiterIn = '\t'; %�J��H�ťն��j�ɭn����' '
    headerlinesIn = 0;
    
    rowBaseData = importdata(baseFilename,delimiterIn,headerlinesIn);
    rowBaseData = rowBaseData(:,1:3);
    
    userData = repmat(filledScore,[userNum itemNum]);
    
    for rowCount = 1:size(rowBaseData,1)
        userData(rowBaseData(rowCount,1), rowBaseData(rowCount,2)) = rowBaseData(rowCount,3);
    end
    
    % LOAD DEFAULT TESTING CLUSTER (IRIS DATASET); USE WITH CARE!
    testData = importdata(testFileName,delimiterIn,headerlinesIn);
    testData = testData(:,1:3);
    
    foldResultData = zeros(size(testData,1),6);
    
    
    %% 2. �׶q�ۦ���
    % use pearson correlation coefficient
    
    %% 3. �ھ�PSO-kmeans ��k���ͻE���A�p��F�~���X
    
    fprintf('Start item-based clustering\n');
    
    % (1) ���ػE��(Item-based clustering)
    % ��J�G �Τ�����x�} userData(m, n) (m users, n items)�A�E���Ӽ� s�A�ɤl�ƥ� k
    % ��X�G s �ӻE���Ψ䤤��
    
    switch selectExperimentType
        case 1 %1) pso_kmeans
            [overall_c, swarm_overall_pose] = pso_kmeans(userData', s, k);
        case 2 %2) kmeans
            [overall_c, swarm_overall_pose]  = kmeans(userData',s);
        otherwise
            error('selectFeatureListType error!');
    end

    fprintf('Start generate specific item prediction score\n');
    
    % (2) �̪�F�j��
    
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
            similarity = pearson(targetItemData, clusterCentroid);
            
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
            similarityRec(neighborItemCount) = pearson(targetItemData, neighborItemData);
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
        
        foldResultData(testDataRowCount,:) = [foldCount user targetItem targetItemScore targetItemPredictionScore absoluteError];
        
        fprintf('Fold %d testing data row %d has predicted completely, prediction score %.3f, score %.3f, absolute error %.3f\n',foldCount, testDataRowCount, targetItemPredictionScore, targetItemScore, absoluteError);
    end
    
    foldMae = absoluteErrorSum/size(testData,1);
    fprintf('Fold %d MAE is %.3f\n',foldCount,foldMae);
    
    foldMaeSum = foldMaeSum + foldMae;
    
    resultData = [resultData; foldResultData];
    
end

mae = foldMaeSum/foldNum;

fprintf('Writing file, please wait!\n');

printResultCsv( resultFileName, mae, resultData );

fprintf('Done!\n');

