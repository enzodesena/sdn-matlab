%   Copyright (c) 2010, Enzo De Sena
function x = getReflectPosOneDim(x1,y1,x2,y2)
    if x1 == x2
        x = x1;
    else
        x = (x1.*y2 + x2.*y1)/(y1+y2);
    end
end


    
