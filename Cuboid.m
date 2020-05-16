%CUBOID Class defining the shape cuboid
%   This simple class defines the dimensions of a cuboid.
%
%   See also Shape
%
%   Copyright (c) 2010, Enzo De Sena
classdef Cuboid < Shape
    properties
        x   % length
        y   % width
        z   % height
    end
    
    methods
        function this = Cuboid(x, y, z)
            this.x = x;
            this.y = y;
            this.z = z;
        end
    end
    
end

