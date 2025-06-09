clc; clear;

%% 1) Display Lookup Tables
% Fuel-type probabilities
[types,probs,cdfVals,ranges,prices] = fuelTypeProb;

% Refueling time distributions
fuelTime;

fuelRate = 60 %liters per minute

%Fuels Price
r95Price = 2.05 
r97Price = 3.10
diselPrice = 2.80

% Interarrival time distributions
fprintf('Interarrival Time For Non Peak Hour \n')
interarrival(1.75);
%[interTimeNonPeak, probNonPeak] = interarrival(1.75);

fprintf('Interarrival Time For Peak Hour \n')
interarrival(2);
%[interTimePeak, probPeak] = interarrival(2.0);


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

%% 4) Peak Hour or Non Peak Hour
fprintf('Select Time Of Stimulation\n');
fprintf(' 1 : Non Peak Hour\n');
fprintf(' 2 : Peak Hour\n');

time = input('Choose [1-2]: ')

switch time
    case 1
        fprintf('>> Stimulating Non Peak Hour\n');
        [interTime, probPercentage, cdfPercentage, lowerBound, upperBound] = interarrival(1.75);
    case 2
        fprintf('>> Stimulating Peak Hour\n');
        [interTime, probPercentage, cdfPercentage, lowerBound, upperBound]= interarrival(2.0);
    otherwise
        error('Invalid Time choice. Please select 1 or 2.');
end

%% 5) Placeholder for Main Simulation
fprintf('\n[Placeholder] Running main simulation with RNG type %d for %d vehicles...\n', ...
    rngChoice, numVehicles);

    
%% Generate random number for each of the vehicles
numberOfRandomNumber = numVehicles * 3 %(3 set of random numbers)

if(rngChoice == 1)
    seed = lcg(rand(),numberOfRandomNumber)
elseif(rngChoice == 2)
    seed = guv(rand(),numberOfRandomNumber)
elseif(rngChoice == 3)
    seed = expv(rand(),numberOfRandomNumber)
else
    error('Invalid RNG Choice')
end

%% Generate interarrival time for each vehicle
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
%disp(interArrivalTimes);

%% Generate fuel types for each vehicle
fuelTypes = cell(1, numVehicles);

for i = 1:numVehicles
    % Generate a random number between 0 and 99
    randNum = seed(numVehicles+i);

    % Determine fuel type using random number ranges
    for j = 1:length(ranges)
        bounds = sscanf(ranges{j}, '%d-%d');
        if randNum >= bounds(1) && randNum <= bounds(2)
            fuelTypes{i} = types{j};
            break;
        end
    end
end

%% Generate fuel time for each vehicles ( car and lorry )
fuelTimes = zeros(1, numVehicles);

for i = 1:numVehicles
    randNum = seed(2 * numVehicles + i); % third set of random numbers

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

% Stimulate fuel pump
fprintf('\n[Placeholder] Simulating fuel pump operations...\n');

% TODO: Implement the simulation logic here.
%       - Use rngChoice and numVehicles to generate inter-arrival and service times.
%       - Display customer arrivals, departures, and events.
%       - Show final tables of refueling times, petrol types, inter-arrival times.   

% Initialize Simulation Variables
arrivalTimes = cumsum(interArrivalTimes);    
startTimes = zeros(1, numVehicles);          
endTimes = zeros(1, numVehicles);            
waitingTimes = zeros(1, numVehicles);        
serviceTimes = fuelTimes;                    
assignedLane = zeros(1, numVehicles);        
assignedPump = zeros(1, numVehicles);        

pumpEnd = zeros(1, 4);                        % Track when each pump is free
lane1_pumps = [1, 2];                        
lane2_pumps = [3, 4];                        

% Run the simulation
for i = 1:numVehicles
    t_arrival = arrivalTimes(i);

    lane1_next = min(pumpEnd(lane1_pumps));
    lane2_next = min(pumpEnd(lane2_pumps));

    if lane1_next <= lane2_next
        assignedLane(i) = 1;
        temp = pumpEnd(lane1_pumps);
        [minimum, idx] = min(temp);
        pump = lane1_pumps(idx);
    else
        assignedLane(i) = 2;
        temp = pumpEnd(lane2_pumps);
        [minimum, idx] = min(temp);
        pump = lane2_pumps(idx);
    end

    assignedPump(i) = pump;
    start_time = max(t_arrival, pumpEnd(pump));
    end_time = start_time + serviceTimes(i);
    startTimes(i) = start_time;
    endTimes(i) = end_time;
    waitingTimes(i) = start_time - t_arrival;
    pumpEnd(pump) = end_time;
    fuel = fuelTypes{i};

    fprintf('Vehicle %2d arrived at minute %.1f and began refueling with %s at Pump Island %d.\n', ...
        i, t_arrival, fuel, pump);

    fprintf('Vehicle %2d finished refueling and departed at minute %.1f.\n', ...
        i, end_time);

end



% Convert arrays to column format
VehicleID = (1:numVehicles)';
Arrival = arrivalTimes';
Start = startTimes';
End = endTimes';
Wait = waitingTimes';
Service = serviceTimes';
Lane = assignedLane';
Pump = assignedPump';
Fuel = fuelTypes;



% Create summary table
fprintf('\n+------------+-----------+-----------+-----------+-----------+-----------+--------+--------+-------------------+\n');
fprintf('| Vehicle ID | Arrival   | Start     | End       | Wait      | Service   | Lane   | Pump   | Fuel              |\n');
fprintf('+------------+-----------+-----------+-----------+-----------+-----------+--------+--------+-------------------+\n');

for i = 1:numVehicles
    fprintf('| %10d | %9.2f | %9.2f | %9.2f | %9.2f | %9.2f | %6d | %6d | %-17s|\n', ...
        i, arrivalTimes(i), startTimes(i), endTimes(i), ...
        waitingTimes(i), serviceTimes(i), ...
        assignedLane(i), assignedPump(i), fuelTypes{i});
end

fprintf('+------------+-----------+-----------+-----------+-----------+-----------+--------+--------+-------------------+\n');


% Show average wait and service times
finalAverage(waitingTimes, serviceTimes);  % This function should be defined elsewhere


fprintf('Simulation complete. (Placeholder)\n');
