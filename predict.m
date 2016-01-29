function [ score ] = predict( userData, user, targetItem, neighborItems)
%PREDICTION Summary of this function goes here
%   Detailed explanation goes here

targetItemData = userData(:,targetItem);
targetItemAverageScore = mean(targetItemData);

numerator = 0; %分子
denominator  = 0;%分母


for neighborItemCount = 1:size(neighborItems,2)
    neighborItem = neighborItems(neighborItemCount);
    neighborItemData = userData(:,neighborItem);
    
    userNeighborItemScore = neighborItemData(user);
    neighborItemAverageScore = mean(neighborItemData);
    similarity = corr(targetItemData, neighborItemData, 'type', 'Pearson');
    
    %分子
    numerator = numerator + (similarity*(userNeighborItemScore-neighborItemAverageScore));
    
    %分母
    denominator= denominator + abs(similarity);
    
end

if denominator == 0
    score = targetItemAverageScore;
else
    score = targetItemAverageScore + (numerator/denominator);
end


end

