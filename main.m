clc; clear;

%% 1) Display Lookup Tables
% Fuel-type probabilities
[types,probs,cdfVals,ranges,prices] = fuelTypeProb;

% Refueling time distributions
fuelTime;

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

fprintf('\nVehicle\tInterarrival\tFuel Type\tFuel Time\n');
fprintf('----------------------------------------------------------\n');
for i = 1:numVehicles
    fprintf('%d\t%12.2f\t%-15s\t%3d min\n', ...
        i, interArrivalTimes(i), fuelTypes{i}, fuelTimes(i));
end


% TODO: Implement the simulation logic here.
%       - Use rngChoice and numVehicles to generate inter-arrival and service times.
%       - Display customer arrivals, departures, and events.
%       - Show final tables of refueling times, petrol types, inter-arrival times.    

fprintf('Simulation complete. (Placeholder)\n');
