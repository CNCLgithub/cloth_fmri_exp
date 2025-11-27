function r_val = RandomVal(l, h, N)
    if nargin < 3, N = 1; end
    r_val = l + (h-l) .* rand(N,1);
end 
