function finalAverage(wt, st)
    % Calculate averages and statistics
    avgWaiting = mean(wt);
    avgService = mean(st);
    avgTotal = mean(wt + st);

    % Probability that a customer had to wait (waiting time > 0)
    probWait = sum(wt > 0) / length(wt);

    % Display results
    disp(['Average Waiting Time: ', num2str(avgWaiting)]);
    disp(['Average Service Time: ', num2str(avgService)]);
    disp(['Average Time in System: ', num2str(avgTotal)]);
    disp(['Probability a customer has to wait: ', num2str(probWait)]);
end
