%======================================================================
%  Fuel-pump queueing simulator  –  FreeMat edition
%======================================================================

clc; clear;

%% 1) Display Lookup Tables
% Fuel-type probabilities
[types, probs, cdfVals, ranges, prices] = fuelTypeProb;

% Refueling time distributions
fuelTime;

fuelRate = 60;          % litres per minute

% Fuels Price
r95Price   = 2.05;
r97Price   = 3.10;
dieselPrice = 2.80;

% Inter-arrival time distributions
fprintf('Interarrival Time For Non-Peak Hour\n');
interarrival(1.75);

fprintf('Interarrival Time For Peak Hour\n');
interarrival(2);

%% 2) RNG Selection
fprintf('\nSelect RNG type:\n');
fprintf(' 1 : Mixed Linear Congruential Generator (LCG)\n');
fprintf(' 2 : Uniform Random Variate Generator (GUV)\n');
fprintf(' 3 : Exponential Random Variate Generator (EXPV)\n');

rngChoice = input('Choose [1-3]: ');
switch rngChoice
    case 1
        fprintf('>> Using mixed LCG generator.\n');
    case 2
        fprintf('>> Using uniform variate generator (GUV).\n');
    case 3
        fprintf('>> Using exponential variate generator (EXPV).\n');
    otherwise
        error('Invalid RNG choice. Please select 1, 2, or 3.');
end

%% 3) Number of Vehicles
numVehicles = input('Enter number of vehicles to simulate: ');
fprintf('>> Simulating %d vehicles.\n', numVehicles);

%% 4) Peak Hour or Non-Peak Hour
fprintf('Select Time Of Simulation\n');
fprintf(' 1 : Non-Peak Hour\n');
fprintf(' 2 : Peak  Hour\n');

time = input('Choose [1-2]: ');

switch time
    case 1
        fprintf('>> Simulating Non-Peak Hour\n');
        [interTime, probPercentage, cdfPercentage, lowerBound, upperBound] = interarrival(1.75);
    case 2
        fprintf('>> Simulating Peak Hour\n');
        [interTime, probPercentage, cdfPercentage, lowerBound, upperBound] = interarrival(2.0);
    otherwise
        error('Invalid Time choice. Please select 1 or 2.');
end

%% 5) Main Simulation banner
fprintf('\nRunning main simulation with RNG type %d for %d vehicles...\n', ...
    rngChoice, numVehicles);
fprintf('\nSimulating fuel pump operations...\n');

%% Generate random numbers
numberOfRandomNumber = numVehicles * 3;   % 3 sets of random numbers

if     rngChoice == 1
    seed = lcg(rand(), numberOfRandomNumber);
elseif rngChoice == 2
    seed = guv(rand(), numberOfRandomNumber);
elseif rngChoice == 3
    seed = expv(rand(), numberOfRandomNumber);
else
    error('Invalid RNG choice');
end

%% Generate inter-arrival times for each vehicle
interArrivalTimes = zeros(1, numVehicles);

for i = 1:numVehicles
    val = seed(i);
    for j = 1:length(lowerBound)
        if val >= lowerBound(j) && val <= upperBound(j)
            interArrivalTimes(i) = interTime(j);
            break;
        end
    end
end

%% Generate fuel types for each vehicle
fuelTypes = cell(1, numVehicles);

for i = 1:numVehicles
    randNum = seed(numVehicles + i);  % second set

    for j = 1:length(ranges)
        bounds = sscanf(ranges{j}, '%d-%d');
        if randNum >= bounds(1) && randNum <= bounds(2)
            fuelTypes{i} = types{j};
            break;
        end
    end
end

%% Generate fuel times for each vehicle
fuelTimes = zeros(1, numVehicles);
randRefuelNums = zeros(1, numVehicles);

for i = 1:numVehicles
    randNum = seed(2 * numVehicles + i);  % third set
    randRefuelNums(i) = randNum;

    if strcmp(fuelTypes{i}, 'Dynamic Diesel')
        for j = 1:length(dsl_ranges)
            bounds = sscanf(dsl_ranges{j}, '%d-%d');
            if randNum >= bounds(1) && randNum <= bounds(2)
                fuelTimes(i) = dsl_times(j);
                break;
            end
        end
    else
        for j = 1:length(car_ranges)
            bounds = sscanf(car_ranges{j}, '%d-%d');
            if randNum >= bounds(1) && randNum <= bounds(2)
                fuelTimes(i) = car_times(j);
                break;
            end
        end
    end
end

%% ---------------- Simulation Engine ----------------
arrivalTimes  = cumsum(interArrivalTimes);
startTimes    = zeros(1, numVehicles);
endTimes      = zeros(1, numVehicles);
waitingTimes  = zeros(1, numVehicles);
serviceTimes  = fuelTimes;
assignedLane  = zeros(1, numVehicles);
assignedPump  = zeros(1, numVehicles);

pumpEnd       = zeros(1, 4);      % When each pump becomes free
lane1_pumps   = [1 2];
lane2_pumps   = [3 4];

% --- event logs for chronological printing ---
eventTimes    = [];   % numeric times
eventTypes    = [];   % 1 = arrival/begin-service, 2 = departure
eventMessages = {};   % cell array of strings

for i = 1:numVehicles
    t_arrival   = arrivalTimes(i);

    % Choose lane (shorter queue / earlier release)
    lane1_next  = min(pumpEnd(lane1_pumps));
    lane2_next  = min(pumpEnd(lane2_pumps));

    if lane1_next <= lane2_next
        assignedLane(i) = 1;
        temp           = pumpEnd(lane1_pumps);
        [minimum, idx] = min(temp);          % FreeMat requires both outputs
        pump           = lane1_pumps(idx);
    else
        assignedLane(i) = 2;
        temp           = pumpEnd(lane2_pumps);
        [minimum, idx] = min(temp);
        pump           = lane2_pumps(idx);
    end

    assignedPump(i) = pump;
    start_time      = max(t_arrival, pumpEnd(pump));
    end_time        = start_time + serviceTimes(i);
    startTimes(i)   = start_time;
    endTimes(i)     = end_time;
    waitingTimes(i) = start_time - t_arrival;
    pumpEnd(pump) = end_time;
    fuel = fuelTypes{i};

    % Log arrival/begin-service event
    msg1 = sprintf('Vehicle %2d arrived at minute %.1f and began refueling with %s at Pump Island %d.', ...
                   i, t_arrival, fuel, pump);
    eventTimes    = [eventTimes, t_arrival];
    eventTypes    = [eventTypes, 1];
    eventMessages = [eventMessages, msg1];

    % Log departure event
    msg2 = sprintf('Vehicle %2d finished refueling and departed at minute %.1f.', ...
                   i, end_time);
    eventTimes    = [eventTimes, end_time];
    eventTypes    = [eventTypes, 2];
    eventMessages = [eventMessages, msg2];
end

%% --------- Chronological console output ------------
% arrivals first if simultaneous, courtesy of small epsilon
timeKey = eventTimes + eventTypes * 1e-4;      % arrivals slightly earlier
[dummy, ord] = sort(timeKey);

fprintf('\n');   % spacing
for k = 1:length(ord)
    fprintf('%s\n', eventMessages{ord(k)});
end
fprintf('\n');

%% ----------------- Summary table -------------------
VehicleID = (1:numVehicles)';
Arrival = arrivalTimes';
Start = startTimes';
End = endTimes';
Wait = waitingTimes';
Service = serviceTimes';
Lane = assignedLane';
Pump = assignedPump';
Fuel = fuelTypes;



% Main Table Header
disp('+-----+----------------+---------------+-------------------+---------------------------+---------------------+----------------+--------+-------------------------+------------------+--------+----------+----------+');
disp('| No  | Petrol         | Quantity (L)  | Total Price (RM)  | RNG Interarrival Time     | Interarrival Time   | Arrival Time   | Line   | RNG Refuel Time         | Refuel Time      | Pump   | Begin    | End      |');
disp('+-----+----------------+---------------+-------------------+---------------------------+---------------------+----------------+--------+-------------------------+------------------+--------+----------+----------+');

for i = 1:numVehicles
    % Calculate quantity and price
    quantity = round(serviceTimes(i) * fuelRate / 60);
    
    if strcmp(fuelTypes{i}, 'Primax95')
        pricePerLitre = r95Price;
    elseif strcmp(fuelTypes{i}, 'Primax97')
        pricePerLitre = r97Price;
    else
        pricePerLitre = dieselPrice;
    end
    
    totalPrice = quantity * pricePerLitre;

    % Print aligned row
    fprintf('| %-3d | %-14s | %13.2f | %17.2f | %25.2f | %19.2f | %14.2f | %-6d | %23.2f | %16.2f | %-6d | %8.2f | %8.2f |\n', ...
        i, fuelTypes{i}, quantity, totalPrice, ...
        0, interArrivalTimes(i), arrivalTimes(i), assignedLane(i), ...
        0, serviceTimes(i), assignedPump(i), startTimes(i), endTimes(i));
end
disp('+-----+----------------+---------------+-------------------+---------------------------+---------------------+----------------+--------+-------------------------+------------------+--------+----------+----------+');



% Pump-wise Time Table Header
disp('+----------------------+-------------------------------+-------------------------------+-------------------------------+-------------------------------+------------------+----------------+');
disp('| Vehicle No.          | Pump 1                        | Pump 2                        | Pump 3                        | Pump 4                        | Waiting Time     | Time Spent     |');
disp('|                      | Refuel Time | Begin  | End    | Refuel Time | Begin  | End    | Refuel Time | Begin  | End    | Refuel Time | Begin  | End    |                  |                |');
disp('+----------------------+-------------+--------+--------+-------------+--------+--------+-------------+--------+--------+-------------+--------+--------+------------------+----------------+');

for i = 1:numVehicles
    p1 = '|             |        |        ';
    p2 = '|             |        |        ';
    p3 = '|             |        |        ';
    p4 = '|             |        |        ';

    waitingTime = startTimes(i) - arrivalTimes(i);
    timeSpent = endTimes(i) - arrivalTimes(i);

    % Assign values based on pump
    switch assignedPump(i)
        case 1
            p1 = sprintf('| %11.2f | %6.2f | %6.2f ', serviceTimes(i), startTimes(i), endTimes(i));
        case 2
            p2 = sprintf('| %11.2f | %6.2f | %6.2f ', serviceTimes(i), startTimes(i), endTimes(i));
        case 3
            p3 = sprintf('| %11.2f | %6.2f | %6.2f ', serviceTimes(i), startTimes(i), endTimes(i));
        case 4
            p4 = sprintf('| %11.2f | %6.2f | %6.2f ', serviceTimes(i), startTimes(i), endTimes(i));
    end

    fprintf('| %20d %s%s%s%s| %16.2f | %14.2f |\n', ...
        i, p1, p2, p3, p4, waitingTime, timeSpent);
end




% Bottom border
disp('--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');

%% ----------------- Averages ------------------------
finalAverage(waitingTimes, serviceTimes);   % user-supplied helper

fprintf('Simulation complete.\n');
