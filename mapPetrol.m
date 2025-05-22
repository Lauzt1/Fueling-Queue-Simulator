% mapPetrol.m
function [type, price] = mapPetrol(r)
    if      r < 40
        type = 'Primax95';    price = 2.05;
    elseif  r < 75
        type = 'Primax97';    price = 2.15;
    else
        type = 'Dynamic Diesel'; price = 2.25;
    end
end