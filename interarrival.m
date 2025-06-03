function [times, prob_percent, cdf_percent, lower_bound, upper_bound] = interarrival(lambda)
    times = 0.5:0.5:3.0;  % Interarrival time steps
    n = length(times);

    prob = zeros(n, 1);

    % Calculate raw probabilities using exponential CDF differences
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

    % Normalize the probabilities to sum to 1
    prob = prob / sum(prob);

    % Convert to integer percentages
    prob_percent = round(prob * 100);

    % For the 3rd minute range just do:
    % 100 - sum of all previous bins
    prob_percent(end) = 100 - sum(prob_percent(1:end-1));

    % Compute cumulative percentages (CDF)
    cdf_percent = cumsum(prob_percent);

    % Define random number range bins (0 to 99)
    lower_bound = [0; cdf_percent(1:end-1)];
    upper_bound = cdf_percent - 1;
    upper_bound(end) = 99;  % Ensure final bin ends at 99

    % Print formatted lookup table
    fprintf('+------------+-----------+-----------+-----------------------+\n');
    fprintf('| Time (min) | Prob (%%)  | CDF (%%)   | Random Range (0 To 99)|\n');
    fprintf('+------------+-----------+-----------+-----------------------+\n');

    for i = 1:n
        fprintf('|   %.1f      |   %3d%%    |   %3d%%    |   [%2d - %2d]           |\n', ...
            times(i), prob_percent(i), cdf_percent(i), lower_bound(i), upper_bound(i));
    end

    fprintf('+------------+-----------+-----------+-----------------------+\n');
end
