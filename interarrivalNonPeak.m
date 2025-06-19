% look at interarrival.m to understand how are these values calculated
function [times, prob_percent, cdf_percent, lower_bound, upper_bound] = interarrival_time_non_peak()
    times = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0];
    prob_percent = [58, 24, 10, 4, 2, 2];
    cdf_percent = cumsum(prob_percent);
    lower_bound = [0, 58, 82, 92, 96, 98];
    upper_bound = [57, 81, 91, 95, 97, 99];

    fprintf('+------------+-----------+-----------+-----------------------+\n');
    fprintf('| Time (min) | Prob (%%)  | CDF (%%)   | Random Range (0 To 99)|\n');
    fprintf('+------------+-----------+-----------+-----------------------+\n');

    for i = 1:length(times)
        fprintf('|   %.1f      |   %3d%%    |   %3d%%    |   [%2d - %2d]           |\n', ...
            times(i), prob_percent(i), cdf_percent(i), lower_bound(i), upper_bound(i));
    end

    fprintf('+------------+-----------+-----------+-----------------------+\n');
end
