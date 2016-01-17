
clear

h = figure('visible','off');
hold on


fprintf('Ploting file, please wait!\n');

%�]�w�s���Ƨ�
dirpath = ['.'];
if(~exist([dirpath '\exp_result' ],'dir'));
    mkdir([dirpath '\exp_result']);
end

%Ū��result��excel�ɮ�
[expResult, clusterAlgorithmList] = xlsread([dirpath '\exp_result' '\result.xls'], 'expResult');

%�]�w�Ϥ����D�BX�b���D�BY�b���D�B�ɮצW��
titleName = ['MAE������G'];
xLabelText = '�F�~�ƥ�';
yLabelText = 'MAE';
title(titleName);
xlabel(xLabelText);
ylabel(yLabelText);

fileName = [dirpath '\exp_result\' 'MAE������G'];
axis([0, 60, 0, 8]);

plot(expResult(:,1), expResult(:,2),'b-square');
plot(expResult(:,3), expResult(:,4),'r-diamond');


print(h,'-djpeg','-r800', fileName);
close(h);

fprintf('Done!\n');

