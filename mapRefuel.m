% mapRefuel.m
function t = mapRefuel(r)
    if      r < 15; t = 3;
    elseif  r < 40; t = 4;
    elseif  r < 70; t = 5;
    elseif  r < 90; t = 6;
    else            t = 7;
    end
end