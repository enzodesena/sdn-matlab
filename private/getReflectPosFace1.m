%   Copyright (c) 2010, Enzo De Sena
function pos = getReflectPosFace1(sourcePos, observPos)
    % Solve the same problem, but only for the surface 1
    
    pos = Position;
    pos.y = double(0);
    
    % For the following conversions, see Enzo's notes.
    pos.x = getReflectPosOneDim(sourcePos.x, sourcePos.y, observPos.x, observPos.y);
    pos.z = getReflectPosOneDim(sourcePos.z, sourcePos.y, observPos.z, observPos.y);
end
