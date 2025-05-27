% interarrival.m

function interarrival_table(lambda)
    times = 0.5:0.5:3.0;  % Interarrival time steps
    n = length(times);

    prob = zeros(n, 1);

    % Calculate raw probabilities
    for i = 1:n
        if i == 1
            prob(i) = exp(-lambda * 0) - exp(-lambda * times(i));
        elseif i < n
            prob(i) = exp(-lambda * times(i-1)) - exp(-lambda * times(i));
        else
            % Last bin absorbs all remaining probability
            prob(i) = exp(-lambda * times(i-1));
        end
    end

    % Normalize (total should be close to 1)
    prob = prob / sum(prob);

    % Convert to whole-number percentages
    prob_percent = round(prob * 100);
    % Adjust the last probability to ensure total = 100
    prob_percent(end) = 100 - sum(prob_percent(1:end-1));

    % CDF (sum of percentages)
    cdf_percent = cumsum(prob_percent);

    % Random number ranges (0–99)
    lower_bound = [0; cdf_percent(1:end-1)];
    upper_bound = cdf_percent - 1;  % Inclusive range

    % Fix last upper bound exactly at 99
    upper_bound(end) = 99;

    % Print the formatted table
    printf('+------------+-----------+-----------+-----------------------+\n');
    printf('| Time (min) | Prob (%%)  | CDF (%%)   | Rand# Range (0 To 99)   |\n');
    printf('+------------+-----------+-----------+-----------------------+\n');

    for i = 1:n
        printf('|   %.1f      |   %3d%%    |   %3d%%    |   [%2d - %2d]           |\n', ...
            times(i), prob_percent(i), cdf_percent(i), lower_bound(i), upper_bound(i));
    end

    printf('+------------+-----------+-----------+-----------------------+\n');
end
