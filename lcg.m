function r = lcg(seed, n)
%LCG   Mixed Linear Congruential Generator ? integers 0–99
%   r = lcg(seed,n) generates 1×n pseudo-random integers in [0…99] using
%   the 32-bit LCG:
%       X_{k+1} = (a·X_k + c) mod m
%   with a=1664525, c=1013904223, m=2^32.
%
%   Outputs are floor((X / m) * 100), yielding values 0 through 99.

    % Constants (all as doubles)
    a = 1664525; 
    c = 1013904223;
    m = 2^32;
    
    % Initialize state
    x = double(seed);
    
    % Preallocate output
    r = zeros(1, n);
    
    for k = 1:n
        x = mod(a * x + c, m);
        r(i) = floor((x / m) * 100);  % Scale to [0,99] and round down
    end
    
    % Ensure output is double row vector
    r = double(r);
end
