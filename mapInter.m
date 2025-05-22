% mapInter.m
function t = mapInter(r)
    if      r < 10;  t = 1;
    elseif  r < 22;  t = 2;
    elseif  r < 37;  t = 3;
    elseif  r < 50;  t = 4;
    elseif  r < 60;  t = 5;
    elseif  r < 70;  t = 6;
    elseif  r < 78;  t = 7;
    elseif  r < 85;  t = 8;
    elseif  r < 93;  t = 9;
    else             t = 10;
    end
end