clear;
close all;

delimiterIn = '\t'; %遇到以空白間隔時要換成' '
headerlinesIn = 0;
baseFileName = ['ydata.base'];
baseData = importdata(baseFileName,delimiterIn,headerlinesIn);

testFileName = ['ydata.test'];
testData = importdata(testFileName,delimiterIn,headerlinesIn);

resultFileName = ['ydata.data'];
resultData = [baseData];

fprintf('Data processing start\n');


for testRowCount = 1:size(testData,1)
    isDuplicated = 0;
    
    row1 = baseData(:,1) == testData(testRowCount,1);
    row2 = baseData(:,2) == testData(testRowCount,2);
    
    if nnz(row1 & row2) >0
        isDuplicated == 1;
        fprintf('Test data row %d is duplicated\n',testRowCount);
    end
    
    if isDuplicated == 0
        resultData = [resultData; testData(testRowCount,:)];
    end
    
    fprintf('Test data row %d is done\n',testRowCount);
end


fid = fopen(resultFileName,'wt');

for rowCount = 1:size(resultData,1)
    dataRow = resultData(rowCount,:);
    fprintf(fid,'%d\t%d\t%d\t%d\n', dataRow(:,1),  dataRow(:,2),  dataRow(:,3),  dataRow(:,4));
end
fclose(fid);

fprintf('Data processing has done\n');