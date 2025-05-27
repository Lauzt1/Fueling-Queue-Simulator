function output = guv(row_num)
    a = 1;
    b = 100;

    % Generate uniform random numbers in [0,1)
    R = rand(row_num, 1);  % row_num x 1 vector

    % Scale to range [a, b]
    X = a + R * (b - a);

    % Round up to nearest integer in [1,100]
    output = ceil(X);
end
