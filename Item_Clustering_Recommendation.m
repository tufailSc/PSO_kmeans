%% 1. �Φ��Τ�-���دx�}�A�o�O�Ӻ�k�̮ڥ����ƾڵ��c

% LOAD DEFAULT CLUSTER (IRIS DATASET); USE WITH CARE!
filename = 'u1.base';
delimiterIn = '\t';
headerlinesIn = 0;
rawData = importdata(filename,delimiterIn,headerlinesIn);
rawData = rawData(:,1:3);

medianScore = 3;
userNum = 943;
itemNum = 1682;
userData = repmat(medianScore,[userNum itemNum]);

for rawCount = 1:size(rawData,1)
    userData(rawData(rawCount,1), rawData(rawCount,2)) = rawData(rawCount,3);
end

%% 2. �׶q�ۦ���
% code is at cosineSimilarity

%% 3. �ھ�PSO-kmeans ��k���ͻE���A�p��F�~���X

% (1) ���ػE��
% ��J�G�Τ�����x�} userData(m, n)�A�E���Ӽ� s�A�ɤl�ƥ� k
% ��X�G s �ӻE���Ψ䤤��
s = 40;
k = 100;
[c, swarm_pos] = pso_kmeans(userData, s, k);


for user = 1:userNum
    % (2) �̪�F�j��
    N = 50;
    
    % a. �p��ؼж��P�C�ӻE�����ߪ��ۦ���
    
    
    % b. ��ܤp��ۦ����H�Ȫ��E�����ߩҦb���E���i��j���A�p��E�������ػP�ؼж��ت��ۦ���
    
    
    % c. ��X�P�ؼж��س̬۪񪺫e N �ӾF�~�@���ؼж��ت��̪�F�~�C
    
    
    
    
    
    
    %% 4. ��ܹw�������A���͹w��
    
    
    %% 5. �Φ�����
end



