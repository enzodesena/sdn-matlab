%GETREFLECTPOS  Outputs the position of a reflection in a cube
%   This function gives back the position in cartesian coordinates of the
%   reflection on the face of a cube for a source in a certain position, 
%   and observed at a certain point.
%   The output is an instance of Position in cartesian coordinates.
%   
%   POS = GETREFLECTPOS(ROOM, FACEINDEX, SOURCEPOS, OBSERVPOS)
%   
%   FACEINDEX is equal to 1 for the reflection on the y=0 face of the
%   cube; FACEINDEX is 2 for the plane x = ROOM.shape.x etc.. FACEINDEX is
%   5 for the face at the top of the cube (z = ROOM.shape.z).
%
%   When the source and observation point are on the same plane, the 
%   function outputs a position with some NaNs.
%
%   See also Position, Room, Shape
%
%   Copyright (c) 2010, Enzo De Sena
function pos = getReflectPos(room, faceIndex, sourcePos, observPos)
    assert(isa(room, 'Room'), 'Room is not an istance of the class Room');
    assert(isa(room.shape, 'Cuboid'), 'This function has been implemented only for cuboid rooms');
    assert(room.shape.x > 0 & room.shape.y > 0 & room.shape.z > 0, 'Invalid room dimensions');
    assert(isa(sourcePos, 'Position'), 'sourcePos is not an istance of the class Position');
    assert(isa(observPos, 'Position'), 'observPos is not an istance of the class Position');
    assert(sourcePos.x >= 0 & sourcePos.y >= 0 & sourcePos.z >= 0, 'Invalid source position');
    assert(sourcePos.x <= room.shape.x & sourcePos.y <= room.shape.y & sourcePos.z <= room.shape.z, 'Source is outside the room');
    assert(observPos.x <= room.shape.x & observPos.y <= room.shape.y & observPos.z <= room.shape.z, 'Observation point is outside the room');
    assert(observPos.x >= 0 & observPos.y >= 0 & observPos.z >= 0, 'Invalid observation position');
    assert((mod(faceIndex,1)==0)& faceIndex >=1 & faceIndex <= 6, 'Invalid face index');
    
    
    % Convert the problem with face index given by faceIndex to the single
    % and simpler case of faceIndex=1
    
    switch faceIndex
        case 1
            pos = getReflectPosFace1(sourcePos, observPos);
        case 2
            % x'=y, y'=xr-x, z'=z
            sourcePosT = Position(sourcePos.y, room.shape.x-sourcePos.x, sourcePos.z);
            observPosT = Position(observPos.y, room.shape.x-observPos.x, observPos.z);
            posT = getReflectPosFace1(sourcePosT, observPosT);
            
            % y=x',x=xr-y', z=z'
            pos = Position(room.shape.x-posT.y, posT.x, posT.z);
        case 3
            % x'=xr-x,y'=yr-y,z'=z
            sourcePosT = Position(room.shape.x-sourcePos.x, room.shape.y-sourcePos.y, sourcePos.z);
            observPosT = Position(room.shape.x-observPos.x, room.shape.y-observPos.y, observPos.z);
            posT = getReflectPosFace1(sourcePosT, observPosT);
            
            % x=xr-x',y=yr-y',z=z'
            pos = Position(room.shape.x-posT.x, room.shape.y-posT.y, posT.z);
        case 4
            % x'=yr-y, y'=x, z'=z
            sourcePosT = Position(room.shape.y-sourcePos.y, sourcePos.x, sourcePos.z);
            observPosT = Position(room.shape.y-observPos.y, observPos.x, observPos.z);
            posT = getReflectPosFace1(sourcePosT, observPosT);
            
            % y=yr-x', x=y', z=z'
            pos = Position(posT.y, room.shape.y-posT.x, posT.z);
        case 5
            % x'=x, y'=zr-z, z'=y
            sourcePosT = Position(sourcePos.x, room.shape.z-sourcePos.z, sourcePos.y);
            observPosT = Position(observPos.x, room.shape.z-observPos.z, observPos.y);
            posT = getReflectPosFace1(sourcePosT, observPosT);
            
            % x=x',z=zr-y', y=z'
            pos = Position(posT.x, posT.z, room.shape.z-posT.y);
        case 6
            % x'=x, y'=z, z'=yr-y
            sourcePosT = Position(sourcePos.x, sourcePos.z, room.shape.y-sourcePos.y);
            observPosT = Position(observPos.x, observPos.z, room.shape.y-observPos.y);
            posT = getReflectPosFace1(sourcePosT, observPosT);
            
            % x=x', z=y', y=yr-z'
            pos = Position(posT.x, room.shape.y-posT.z, posT.y);
        otherwise
            assert(false)
    end
    
    debug = true;
    if debug
        switch faceIndex
            case 1
                assert(pos.y == 0);
                assert((pos.x >= sourcePos.x & pos.x <= observPos.x) | (pos.x <= sourcePos.x & pos.x >= observPos.x));
                assert((pos.z >= sourcePos.z & pos.z <= observPos.z) | (pos.z <= sourcePos.z & pos.z >= observPos.z));
            case 2
                assert(pos.x == room.shape.x);
                assert((pos.y >= sourcePos.y & pos.y <= observPos.y) | (pos.y <= sourcePos.y & pos.y >= observPos.y));
                assert((pos.z >= sourcePos.z & pos.z <= observPos.z) | (pos.z <= sourcePos.z & pos.z >= observPos.z));
            case 3
                assert(pos.y == room.shape.y);
                assert((pos.x >= sourcePos.x & pos.x <= observPos.x) | (pos.x <= sourcePos.x & pos.x >= observPos.x));
                assert((pos.z >= sourcePos.z & pos.z <= observPos.z) | (pos.z <= sourcePos.z & pos.z >= observPos.z));
            case 4
                assert(pos.x == 0);
                assert((pos.y >= sourcePos.y & pos.y <= observPos.y) | (pos.y <= sourcePos.y & pos.y >= observPos.y));
                assert((pos.z >= sourcePos.z & pos.z <= observPos.z) | (pos.z <= sourcePos.z & pos.z >= observPos.z));
            case 5
                assert(pos.z == room.shape.z);
                assert((pos.x >= sourcePos.x & pos.x <= observPos.x) | (pos.x <= sourcePos.x & pos.x >= observPos.x));
                assert((pos.y >= sourcePos.y & pos.y <= observPos.y) | (pos.y <= sourcePos.y & pos.y >= observPos.y));
            case 6
                assert(pos.z == 0);
                assert((pos.x >= sourcePos.x & pos.x <= observPos.x) | (pos.x <= sourcePos.x & pos.x >= observPos.x));
                assert((pos.y >= sourcePos.y & pos.y <= observPos.y) | (pos.y <= sourcePos.y & pos.y >= observPos.y));
        end
    end
end
    










