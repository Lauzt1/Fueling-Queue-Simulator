% main.m – Simulation Driver
clc; clear;

%% 1) Display Lookup Tables
% Fuel-type probabilities
fuelTypeProb;

% Refueling time distributions
fuelTime;

%% 2) RNG Selection
fprintf('\nSelect RNG type:\n');
fprintf(' 1 : Mixed Linear Congruential Generator (LCG)\n');
fprintf(' 2 : Uniform Random Variate Generator (GUV)\n');
fprintf(' 3 : Exponential Random Variate Generator (EXPV)\n');

rngChoice = input('Choice [1-3]: ');
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

% 4) Seed + preview
seed = input('Enter RNG seed (integer): ');
switch rngChoice
    case 1, rngSequence = lcg(seed, numVehicles);
    case 2, rngSequence = guv(seed, numVehicles);
    case 3, rngSequence = expv(seed, numVehicles);
end

fprintf('\nFirst 20 generated numbers (0-99):\n');
disp(rngSequence(1:min(20, numVehicles)));

%% 4) Placeholder for Main Simulation
fprintf('\n[Placeholder] Running main simulation with RNG type %d for %d vehicles...\n', ...
    rngChoice, numVehicles);

% TODO: Implement the simulation logic here.
%       - Use rngChoice and numVehicles to generate inter-arrival and service times.
%       - Display customer arrivals, departures, and events.
%       - Show final tables of refueling times, petrol types, inter-arrival times.

fprintf('Simulation complete. (Placeholder)\n');
