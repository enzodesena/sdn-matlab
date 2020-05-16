classdef Microphone < handle
%MICROPHONE Class of a microphone
%
%   Copyright (c) 2010, Enzo De Sena
    
    properties
		position
        directivity
        heading
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
            Gamma = this.directivity * ...
                (cos(theta-this.heading).^(0:(length(this.directivity)-1))');
        end
        
        function sig = getSignalFromSource(this, source)
            % 1,1 in the following call means: apply delay and attenuation.
            signalAt = source.getSignalAt(this.position, 1, 1);
            
            if length(this.directivity) ~= 1 || this.directivity ~= 1
				theta = Position.getAngle(this.position, source.position);
				Gamma = this.getGamma(theta);
				data = signalAt.data;
            
				sig = Signal(data .* Gamma, signalAt.FS, signalAt.initDelayTap);
			else
				sig = Signal(data, signalAt.FS, signalAt.initDelayTap);
            end
        end
        
        function sig = getSignalFromPosition(this, signal, position)
            % 1,1 in the following call means: apply delay and attenuation.
            signalAt = source.getSignalAt(this.position, 1, 1);
            
            if length(this.directivity) ~= 1 || this.directivity ~= 1
				theta = Position.getAngle(this.position, source.position);
				Gamma = this.getGamma(theta);
				data = signalAt.data;
            
				sig = Signal(data .* Gamma, signalAt.FS, signalAt.initDelayTap);
			else
				sig = Signal(data, signalAt.FS, signalAt.initDelayTap);
            end
        end
    end
    
end

