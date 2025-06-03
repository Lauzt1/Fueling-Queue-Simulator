function r = expv(seed, n)
%EXPV   Exponential-based generator ? integers 0–99 (truncated)
%   r = expv(seed, n) does the following:
%     1) Uses lcg(seed, n) to get n uniform ints in [0…99].
%     2) Converts each int into a U ? (0,1) by (int + 0.5)/100.
%     3) Forms an Exp(?=1) variate T = –log(1 – U).
%     4) Scales T × 10 (or ×100 if you want finer granularity), floors,
%        and then truncates at 99.
%
%   Output:
%     r ? 1×n row vector, each entry ? {0, 1, 2, …, 99}

    % 1) Get n uniform “0–99” integers
    u_int = lcg(seed, n);            % 1×n from 0…99

    % 2) Map to U in (0,1).  By adding 0.5 we avoid exact 0 or 1.
    U = (double(u_int) + 0.5) / 100;  % each U ? {0.005, 0.015, …, 0.995}

    % 3) Exponential variate with ? = 1:
    T = -log(1 - U);                 % T ? [˜0, ˜5.3] mostly

    % 4) Convert to an integer “score” in [0…99].
    %    Here we multiply by 10 so that T ~ Exp(1) with mean=1 ? mean˜10;
    %    you can change the scale factor if you prefer finer/coarser buckets.
    r_raw = floor(T * 10);           % integer from 0 up to maybe ~50 or so

    % 5) Truncate any r_raw > 99 down to 99
    r = r_raw;
    r(r > 99) = 99;

    % 6) Ensure row vector of doubles
    r = double(r);
end
