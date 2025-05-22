% main.m
function main()
    clc; clear;
    fprintf('=== Petrol Station Queue Simulator ===\n');
    n = input('Enter number of vehicles: ');
    fprintf('Select RNG type:\n 1 - Linear Congruential Generator (LCG)\n');
    rngType = input('Choice: ');

    % Seed from uniform rand
    seed = floor(rand*10000);
    switch rngType
        case 1
            % LCG parameters
            a = 1103515245; c = 12345; m = 2^31;
            raw = lcg(a, c, m, seed, 4*n);  % column vector
        otherwise
            error('Selected RNG not implemented.');
    end

    % Split streams (column vectors)
    randIA  = raw(1:n);
    randPet = raw(n+1:2*n);
    randRef = raw(2*n+1:3*n);
    randQty = raw(3*n+1:4*n);

    % Preallocate
    inter      = zeros(n,1);
    arr        = zeros(n,1);
    line       = zeros(n,1);
    petertype  = cell(n,1);
    price      = zeros(n,1);
    quantity   = zeros(n,1);
    refuel     = zeros(n,1);
    pump       = zeros(n,1);
    startTime  = zeros(n,1);
    finishTime = zeros(n,1);
    finishTimes = zeros(4,1);

    % Run simulation
    for i = 1:n
        if i == 1
            inter(i) = 0; arr(i) = 0;
        else
            inter(i) = mapInter(randIA(i));
            arr(i)   = arr(i-1) + inter(i);
        end
        quantity(i) = floor(randQty(i)/10) + 1;
        [petertype{i}, price(i)] = mapPetrol(randPet(i));
        refuel(i) = mapRefuel(randRef(i));

        % Choose lane with shorter queue
        busy1 = sum(finishTimes(1:2) > arr(i));
        busy2 = sum(finishTimes(3:4) > arr(i));
        if busy1 <= busy2
            line(i) = 1; lanes = [1;2];
        else
            line(i) = 2; lanes = [3;4];
        end
        % Assign pump with earliest free time
        [~, idx] = min(finishTimes(lanes));
        pump(i) = lanes(idx);
        startTime(i) = max(arr(i), finishTimes(pump(i)));
        finishTime(i) = startTime(i) + refuel(i);
        finishTimes(pump(i)) = finishTime(i);

        fprintf('Vehicle %d arrived at minute %d and began refueling with %s at Pump %d.\n', ...
                i, arr(i), petertype{i}, pump(i));
    end

    % Departures
    for i = 1:n
        fprintf('Vehicle %d finished refueling and departed at minute %d.\n', ...
                i, finishTime(i));
    end

    % Build results table
    headers = {'Vehicle','Type','Quantity','TotalPrice','RndIA','Interarrival','Arrival','Line','RndRef', ...
               'P1_Time','P1_Start','P1_End','P2_Time','P2_Start','P2_End', ...
               'P3_Time','P3_Start','P3_End','P4_Time','P4_Start','P4_End','Waiting','TotalTime'};
    data = cell(n, numel(headers));
    for i = 1:n
        data{i,1} = i;
        data{i,2} = petertype{i};
        data{i,3} = quantity(i);
        data{i,4} = quantity(i) * price(i);
        data{i,5} = randIA(i);
        data{i,6} = inter(i);
        data{i,7} = arr(i);
        data{i,8} = line(i);
        data{i,9} = randRef(i);
        % Pump columns
        for p = 1:4
            base = 9 + (p-1)*3;
            if pump(i) == p
                data{i,base+1} = refuel(i);
                data{i,base+2} = startTime(i);
                data{i,base+3} = finishTime(i);
            else
                data{i,base+1} = '-';
                data{i,base+2} = '-';
                data{i,base+3} = '-';
            end
        end
        data{i,22} = startTime(i) - arr(i);       % Waiting
        data{i,23} = finishTime(i) - arr(i);     % Total time
    end
    T = cell2table(data, 'VariableNames', headers);
    disp(T);
end