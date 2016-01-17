
clear

h = figure('visible','off');
hold on


fprintf('Ploting file, please wait!\n');

%設定存放資料夾
dirpath = ['.'];
if(~exist([dirpath '\exp_result' ],'dir'));
    mkdir([dirpath '\exp_result']);
end

%讀取result的excel檔案
[expResult, clusterAlgorithmList] = xlsread([dirpath '\exp_result' '\result.xls'], 'expResult');

%設定圖片標題、X軸標題、Y軸標題、檔案名稱
titleName = ['MAE比較結果'];
xLabelText = '鄰居數目';
yLabelText = 'MAE';
title(titleName);
xlabel(xLabelText);
ylabel(yLabelText);

fileName = [dirpath '\exp_result\' 'MAE比較結果'];
axis([0, 60, 0, 8]);

plot(expResult(:,1), expResult(:,2),'b-square');
plot(expResult(:,3), expResult(:,4),'r-diamond');


print(h,'-djpeg','-r800', fileName);
close(h);

fprintf('Done!\n');

