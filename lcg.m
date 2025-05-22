% lcg.m
function rnd = lcg(a, c, m, seed, n)
% Generates n uniform integers 0-99 via LCG
    rnd = zeros(n,1);
    x = seed;
    for k = 1:n
        x = mod(a*x + c, m);
        rnd(k) = mod(x, 100);
    end
end