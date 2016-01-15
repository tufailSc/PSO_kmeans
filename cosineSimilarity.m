function [ similarity ] = cosineSimilarity(a, b)
similarity = dot(a, b)/(norm(a)*norm(b));
end

