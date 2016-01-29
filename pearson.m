function [ similarity ] = pearson( x, y )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
C = cov(x,y);
std_x = std(x);
std_y = std(y);
if (std_x ~= 0) && (std_y ~= 0)
    similarity = C(2)/(std_x*std_y);
else
    similarity = 0;
end
end

