function [types,probs,cdfVals,ranges,prices] = fuelTypeProb()
    % fuelTypeProb.m – Fuel-Type Probability Table (2-dp, bordered)
    
    % --- Assumptions ---------------------------------------------------------
    % Vehicle arrival mix: 76% cars (petrol), 24% lorries (diesel)
    P_car   = 0.76;
    P_lorry = 0.24;
    
    % Petrol split: 80 % Primax95, 20 % Primax97
    split95 = 0.80;
    split97 = 0.20;
    
    % --- Compute probabilities (rounded to two decimals) ---------------------
    P95   = round(P_car * split95 * 100) / 100;
    P97   = round(P_car * split97 * 100) / 100;
    Pdies = round(P_lorry        * 100) / 100;
    
    % Adjust diesel for rounding error so sum = 1.00
    err = 1.00 - (P95 + P97 + Pdies);
    Pdies = round((Pdies + err) * 100) / 100;
    
    % Fuel types, probabilities, and prices
    types  = {'Primax95','Primax97','Dynamic Diesel'};
    probs  = [P95, P97, Pdies];
    prices = [2.05, 3.10, 2.80];
    
    % --- Compute CDF values (rounded) ----------------------------------------
    cdfVals = round(cumsum(probs) * 100) / 100;
    
    % --- Determine random-number ranges (00–99) ------------------------------
    ranges = cell(3,1);
    low = 0;
    for i = 1:3
        if i < 3
            count = probs(i) * 100;       % number of integers for this category
            high  = low + count - 1;
        else
            high = 99;                    % last category fills to 99
        end
        ranges{i} = sprintf('%02d-%02d', low, high);
        low = high + 1;
    end
    
    % --- Print bordered table ------------------------------------------------
    line = '+---------------+------------+------+--------------------+-------------+';
    head = '| Type          | Probability | CDF  | Random Number Rng  | Price (RM/L) |';
    
    fprintf('%s\n', line);
    fprintf('%s\n', head);
    fprintf('%s\n', line);
    for i = 1:3
        fprintf('| %-13s | %10.2f | %4.2f | %-18s | %11.2f |\n', ...
            types{i}, probs(i), cdfVals(i), ranges{i}, prices(i));
    end
    fprintf('%s\n', line);
end