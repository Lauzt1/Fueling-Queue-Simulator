function r = lcg(seed, n)
    a = 1664525;
    c = 1013904223;
    m = 2^32;
    r = zeros(1, n);
    x = seed;
    for i = 1:n
        x = mod(a * x + c, m);
        r(i) = floor((x / m) * 100);  % Scale to [0,99] and round down
    end
end
