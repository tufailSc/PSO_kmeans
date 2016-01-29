clear;
close all;

delimiterIn = '\t'; %遇到以空白間隔時要換成' '
headerlinesIn = 0;
baseFileName = ['ydata.base'];
baseData = importdata(baseFileName,delimiterIn,headerlinesIn);

testFileName = ['ydata.test'];
testData = importdata(testFileName,delimiterIn,headerlinesIn);

resultFileName = ['ydata.data'];
resultData = zeros(size(baseData,1)+size(testData,1),4);

fprintf('Data processing start\n');


resultDataRowCount = 1;
for testRowCount = 1:size(testData,1)
    isDuplicated = 0;
    
    row1 = baseData(:,1) == testData(testRowCount,1);
    row2 = baseData(:,2) == testData(testRowCount,2);
    
    if nnz(row1 & row2) >0
        isDuplicated = 1;
        fprintf('Test data row %d is duplicated\n',testRowCount);
    end
    
    if isDuplicated == 0
        resultData(resultDataRowCount,:) =  testData(testRowCount,:);
        resultDataRowCount = resultDataRowCount + 1;
    end

%     fprintf('Test data row %d is done\n',testRowCount);
end


for baseRowCount = 1:size(baseData,1)
    resultData(resultDataRowCount,:) =  baseData(baseRowCount,:);
    resultDataRowCount = resultDataRowCount + 1;
%     fprintf('Base data row %d is done\n',baseRowCount);
end

resultData = resultData(resultData(:,1)~=0,:);

%% Map item id
fprintf('Map item id\n');
mapObj = containers.Map;

itemData = resultData(:,2);
itemIdCount = 0;
itemIdData = zeros(size(itemData,1),1);
for rowCount = 1:size(itemData,1)
    item = int2str(itemData(rowCount,1));
   try
       itemId = cell2mat(values(mapObj,{item}));
   catch
       itemIdCount = itemIdCount + 1;
       mapObj(item) = itemIdCount;
       itemId = itemIdCount;
       fprintf('Now at row %d\n',rowCount);
   end
   itemIdData(rowCount,1) = itemId;
end

resultData(:,2) = itemIdData;



%% Write file
fid = fopen(resultFileName,'wt');

for rowCount = 1:size(resultData,1)
    dataRow = resultData(rowCount,:);
    fprintf(fid,'%d\t%d\t%d\n', dataRow(1,1),  dataRow(1,2), dataRow(1,4));
end
fclose(fid);

fprintf('Data processing has done\n');