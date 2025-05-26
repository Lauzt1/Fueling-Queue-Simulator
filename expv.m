function X = expv(lambda,n)
U = rand(n,1);
X = floor(-(1/lambda)*log(1 - U)*100);
end