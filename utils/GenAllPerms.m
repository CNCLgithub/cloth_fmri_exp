function perm_ls = GenAllPerms(N, K)
    % N=2; K=2;
    % perm_ls = [2,1; 1,2]
    P = nchoosek(1:N,K);
    perm_ls = reshape(P(:,perms(1:K)),[],K);
end
