function r = guv(seed, n)
%GUV   Uniform “0–99” generator via LCG
%   r = guv(seed,n) simply invokes lcg(seed,n) to produce n integers
%   in the 0…99 range, uniformly.  This avoids any calls to rng or
%   rand('state',…), so it works identically under FreeMAT.
%
%   OUTPUT:
%     r  ? 1×n row vector of uniform ints in [0…99].
    % Delegate directly to our LCG:
    r = lcg(seed, n);
end
