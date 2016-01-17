clear;
close all;

delimiterIn = ','; %遇到以空白間隔時要換成' '
headerlinesIn = 0;
fileName = ['testdata.csv'];
data = importdata(fileName,delimiterIn,headerlinesIn);
users = 1:20;

filename = 'test_data.txt';
fid = fopen(filename,'wt');

for rowCount = 1:size(data,1)
    user = users(rowCount);
    
    for colCount = 1: size(data,2)
        fprintf(fid,'%d\t%d\t%.1f\n', user, colCount, data(rowCount, colCount));
    end
end

fclose(fid);
