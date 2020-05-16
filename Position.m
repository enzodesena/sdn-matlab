%POSITION  Position object
%   This object contains the cartesian coordinates of a point x,y,z. It
%   also contains some useful static methods (not all of them support the z
%   coordinate).
%
%   Copyright (c) 2010, Enzo De Sena
classdef Position < handle
    properties
        % We leave the properties undefined such that, if the coordinates
        % are not defined somewhere in the code, an error is generated
        x
        y
        z
    end
    
    methods
        function this = Position(x, y, z)
            if nargin >= 1
                this.x = double(x);
            end
            if nargin >= 2    
                this.y = double(y);
            end
            if nargin == 3
                this.z = double(z);
            end
        end
        
        function r = r(this)
            % TODO: handle z
            r = sqrt(this.x.^2 + this.y.^2);
        end
        
        function theta = theta(this)
            % TODO: handle z
            theta = angle(this.x + 1i.*this.y);
        end
        
        function empty = isEmpty(this)
            empty = isempty(this.x) || isempty(this.y);
        end
        
        function equal = isEqual(this, toThis, tol)
            assert(isa(toThis,'Position'));
            
            if nargin <= 2
                tol = 10^(-10);
            end
            
            equal = (abs(this.x-toThis.x) < tol & abs(this.y-toThis.y) < tol & abs(this.z-toThis.z) < tol);
        end
    end
    
    methods (Static)
        function distance = getDistance(position1, position2)
            % TODO: handle the case where z is not defined
            distance = sqrt((position1.x - position2.x).^2 + (position1.y - position2.y).^2 + (position1.z - position2.z).^2);
        end
        
        function distance = distance(position1, position2)
            distance = Position.getDistance(position1, position2);
        end
        
        function ang = getAngle(position1, position2)
            % Get the anlge on a xy cartesian system where position1 is the
            % center of the cartesian system.
            % TODO: handle z
            
            ang = angle((position2.x - position1.x) + ...
                1i.*(position2.y - position1.y));
        end
    end
end

