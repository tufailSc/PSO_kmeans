clear;
close all;

delimiterIn = ','; %遇到以空白間隔時要換成' '
headerlinesIn = 0;
baseFileName = ['BX-Book-Ratings.csv'];
[baseData] = importdata(baseFileName,delimiterIn,headerlinesIn);

tempData = baseData.textdata(:,1);
userIdData = zeros(size(tempData,1),1);
for rowCount = 1:size(baseData.textdata,1)
    num = str2double(cell2mat(tempData(rowCount,1)));
    userIdData(rowCount,1) = num;
    if size(num,2) == 0
        fprintf('It is a string, row %d\n',rowCount);
    end
end


isbnData = baseData.textdata(:,3);
bookRatingData = baseData.data(:,2);

fprintf('Data processing start\n');


mapObj = containers.Map;

isbnIdCount = 0;
isbnIdData = zeros(size(isbnData,1),1);
for rowCount = 1:size(isbnData,1)
    isbn = cell2mat(isbnData(rowCount,1));
   try
       isbnId = cell2mat(values(mapObj,{isbn}));
   catch
       isbnIdCount = isbnIdCount + 1;
       mapObj(isbn) = isbnIdCount;
       isbnId = isbnIdCount;
       fprintf('Now at row %d\n',rowCount);
   end
   isbnIdData(rowCount,1) = isbnId;
end


resultFileName = 'bookRatings.data';

fid = fopen(resultFileName,'wt');

for rowCount = 1:size(userIdData,1)
    fprintf(fid,'%d\t%d\t%d\n', userIdData(rowCount,1),  isbnIdData(rowCount,1),  bookRatingData(rowCount,1));
end
fclose(fid);

fprintf('Data processing has done\n');