function [  ] = printResultCsv( resultFileName, mae, resultData )

maeLabel = {'MAE'};
txtLabel = {'fold', 'user', 'target item', 'item score', 'prediction score', 'absolute error'};

fid = fopen(resultFileName,'wt');

fprintf(fid,'%s,%d\n', cell2mat(maeLabel), mae);
fprintf(fid,'fold,user,target item,item score,prediction score,absolute error\n');

for rowCount = 1:size(resultData,1)
    dataRow = resultData(rowCount,:);
    fprintf(fid,'%d,%d,%d,%.5f,%.5f,%.5f\n', dataRow(:,1),  dataRow(:,2),  dataRow(:,3), dataRow(:,4), dataRow(:,5), dataRow(:,6));
end

fclose(fid);

end

