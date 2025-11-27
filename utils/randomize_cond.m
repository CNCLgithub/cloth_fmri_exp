function [nItems_rand, randomorder] = randomize_cond(cond_list)

% N = 4; 
% K = 2;
% P = nchoosek(1:N,K);
% P = reshape(P(:,perms(1:K)),[],K); 
% cond_list = [P; P; P];

j = 1;
for i = 1:size(cond_list,1)
    elements = cond_list(i,:,:);
    nItems(j,:)   = [elements(1),elements(2)];
    j= j+1;
end

nTrials = length(nItems);
% Randomize the trials and then seperate them into blocks
randomorder=randperm(nTrials);  
for kk = 1:nTrials
    nItems_rand(kk,:) = nItems(randomorder(kk),:);
end