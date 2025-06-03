function r = guv(seed, n)
% GUV  Uniform Random Variate Generator  ->  integers 0–99
%      r = guv(seed,n) returns a 1-by-n row vector of uniformly
%      distributed integers in the set {0,1,...,99}.
%
%      The generator uses its own 32-bit linear-congruential formula
%      X_{k+1} = (a*X_k + c) mod m   with the classic glibc constants.

    % Constants (avoid uint / exotic chars – keep everything double)
    a = 1103515245;
    c = 12345;
    m = 2^31;          % 2147483648

    % Initial state
    x = double(seed);

    % Pre-allocate output
    r = zeros(1, n);

    for k = 1:n
        % Next LCG state
        x = mod(a * x + c, m);

        % Uniform U in [0,1)
        U = x / m;

        % Scale to [0,100) and floor  ->  0…99
        r(k) = floor(U * 100);
    end
end
