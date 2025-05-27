% fuelTime.m – Refueling-Time Lookup Tables (bordered output)

%% --- Petrol cars ---------------------------------------------------------
car_times   = [2 3 4 5 6 7]';
car_probs   = [0.05 0.20 0.40 0.25 0.07 0.03]';
car_cdf     = round(cumsum(car_probs)*100)/100;
car_ranges  = {'00-04';'05-24';'25-64';'65-89';'90-96';'97-99'};

%% --- Diesel lorries ------------------------------------------------------
dsl_times   = [8 10 12 15 18 20]';
dsl_probs   = [0.10 0.20 0.30 0.25 0.10 0.05]';
dsl_cdf     = round(cumsum(dsl_probs)*100)/100;
dsl_ranges  = {'00-09';'10-29';'30-59';'60-84';'85-94';'95-99'};

%% --- Print Petrol Cars Table --------------------------------------------
line = '+-------------------+------------+------+--------------------+';
head = '| Refuel Time (min) | Probability | CDF  | Random Number Rng |';
fprintf('\nPetrol Cars\n');
fprintf('%s\n%s\n%s\n', line, head, line);
for i = 1:length(car_times)
    fprintf('| %17d | %10.2f | %4.2f | %-18s |\n', ...
        car_times(i), car_probs(i), car_cdf(i), car_ranges{i});
end
fprintf('%s\n', line);

%% --- Print Diesel Lorries Table -----------------------------------------
fprintf('\nDiesel Lorries\n');
fprintf('%s\n%s\n%s\n', line, head, line);
for i = 1:length(dsl_times)
    fprintf('| %17d | %10.2f | %4.2f | %-18s |\n', ...
        dsl_times(i), dsl_probs(i), dsl_cdf(i), dsl_ranges{i});
end
fprintf('%s\n', line);