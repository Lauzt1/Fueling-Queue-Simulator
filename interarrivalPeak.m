% look at interarrival.m to understand how are these values calculated
function [times, prob_percent, cdf_percent, lower_bound, upper_bound] = interarrival_time_peak()
    times = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0];
    prob_percent = [63, 23, 9, 3, 1, 1];
    cdf_percent = cumsum(prob_percent);
    lower_bound = [0, 63, 86, 95, 98, 99];
    upper_bound = [62, 85, 94, 97, 98, 99];

    fprintf('+------------+-----------+-----------+-----------------------+\n');
    fprintf('| Time (min) | Prob (%%)  | CDF (%%)   | Random Range (0 To 99)|\n');
    fprintf('+------------+-----------+-----------+-----------------------+\n');

    for i = 1:length(times)
        fprintf('|   %.1f      |   %3d%%    |   %3d%%    |   [%2d - %2d]           |\n', ...
            times(i), prob_percent(i), cdf_percent(i), lower_bound(i), upper_bound(i));
    end

    fprintf('+------------+-----------+-----------+-----------------------+\n');
end

