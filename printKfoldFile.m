function [  ] = printKfoldFile( fileName, data )

fid = fopen(fileName,'wt');

for rowCount = 1:size(data,1)
    dataRow = data(rowCount,:);
    fprintf(fid,'%d\t%d\t%.1f\n', dataRow(:,1),  dataRow(:,2),  dataRow(:,3));
end
fclose(fid);


end

