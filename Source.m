classdef Source < handle
%SOURCE Source object
%
%   Copyright (c) 2010, Enzo De Sena
    
    properties
        position = Position;
        
        % heading is the angle formed between the x-axis and the source's 
        % axis. Angles are anticlockwise.
        heading = 0;
        
        % directivity = 1 means omnidirectional
        directivity = 1;
        
        signal
    end
    
    properties (Constant)
        c = 343;
    end
    
    methods
        function set.directivity(this, directivity)
            assert(isvector(directivity));
            
            % We store data only as row vectors
            [~, N] = size(directivity);
            assert(isvector(directivity));
            if N > 1
                this.directivity = directivity;
            else
                this.directivity = directivity';
            end
        end
        
        function set.heading(this, angle)
            this.heading = mod(angle, 2*pi);
        end
        
        function Gamma = getGamma(this, theta)
            Gamma = abs(this.directivity * ...
                cos(theta-this.heading).^(0:(length(this.directivity)-1))');
        end
        
        function sig = getSignalAt(this, atPosition, applyAttenuation, applyDelay)
            if nargin <= 2
                applyAttenuation = 1;
                applyDelay = 1;
            end
            if nargin <= 3
                applyDelay = 1;
            end
            
            % The distance between point and loudspeaker
            distance = Position.getDistance(atPosition, this.position);
            
            % The angle by witch the loudspeaker sees the position
            alfa = Position.getAngle(this.position, atPosition);
            
            Gamma = this.getGamma(alfa);
            data = Gamma .* this.signal.data;
            
            if applyDelay
                delay = distance / this.c;
                delayTap = round(delay * this.signal.FS);
            else
                delayTap = 0;
            end
            
            if applyAttenuation == 1;
                data = data / distance;
            end
            
            sig = Signal(data, this.signal.FS, this.signal.initDelayTap + delayTap);
        end
    end
    
end

