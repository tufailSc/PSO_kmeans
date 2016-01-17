clear;
close all;

load fisheriris
[speciesGroup, groupNames] = grp2idx(species);

filename = 'iris_data.txt';
fid = fopen(filename,'wt');

for rowCount = 1:size(meas,1)
    group = speciesGroup(rowCount);
    
    for colCount = 1: size(meas,2)
        fprintf(fid,'%d\t%d\t%.1f\n', group, colCount, meas(rowCount, colCount));
    end
end

fclose(fid);
