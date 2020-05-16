%GETREFLECTPOSNOBJ The same as GETREFLECTPOS but with non-object as inputs
%   This function serves as a interface to GETREFLECTPOS, if you don't want
%   to define objects.
%
%   See also getReflectPos
%
%   Copyright (c) 2010, Enzo De Sena

function [x,y,z] = getReflectPosNObj(xRoom, yRoom, zRoom, faceIndex, xSource, ySource, zSource, xObserv, yObserv, zObserv)
    room = Room();
    room.shape = Cuboid(xRoom, yRoom, zRoom);
    sourcePos = Position(xSource, ySource, zSource);
    observPos = Position(xObserv, yObserv, zObserv);
    
    pos = getReflectPos(room, faceIndex, sourcePos, observPos);
    
    x = pos.x;
    y = pos.y;
    z = pos.z;
end
