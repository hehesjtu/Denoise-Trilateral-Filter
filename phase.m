function angle = phase(y,x)

if y > 0
    angle = (180/pi)*atan2(y,x);
elseif y < 0
    angle = 360 + (180/pi)*atan2(y,x);
else
    if x >= 0     
        angle = 0;
    else
        angle = 180;
    end
end 
    
end