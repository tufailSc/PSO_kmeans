clear;
close all;

delimiterIn = '\t'; %遇到以空白間隔時要換成' '
headerlinesIn = 0;
fileName = ['test_data.txt'];
data = importdata(fileName,delimiterIn,headerlinesIn);

K = 5;
observations = data(:,1);
dataSetName = 'testdata';

indices = crossvalind('Kfold',observations ,K);

fprintf('Total data has %d data\n', size(observations,1));

for foldCount = 1:K
    test = (indices == foldCount);
    fprintf('Fold %d has %d data\n',foldCount, nnz(test));
    
    baseFilename = [dataSetName '_' num2str(foldCount) '.base'];
    testFileName = [dataSetName '_' num2str(foldCount) '.test'];

    trainingData = data(~test,:);
    printKfoldFile( baseFilename, trainingData );
    
    testingData = data(test,:);
    printKfoldFile( testFileName, testingData );
end
fprintf('Data processing has done\n');

