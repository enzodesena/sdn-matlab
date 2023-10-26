%PROPLINE  
%
%   See also Position, Room, Shape
%
%   Copyright (c) 2010, Enzo De Sena
classdef PropLine < handle
    properties
        attenuation
    end
    
    properties (Access='private')
        delayFilter
        nextFrame
        delaySamples
        junctionA
        junctionB
    end
    
    properties (Constant=true)
        c = 343;
    end
    
    
    methods
        function this = PropLine(junctionA, junctionB, FS, offset)
            distance = Position.distance(junctionA.position, junctionB.position);
            
            delay = distance / this.c;
            this.delaySamples = round(delay .* FS);
            if nargin == 4
                this.delaySamples = this.delaySamples + offset;
            end
            %this.delayFilter = dfilt.delay(delaySamples);
            %this.delayFilter.PersistentMemory = true;
            this.delayFilter = DelayFilter(this.delaySamples);
            this.attenuation = (this.c./FS) ./ (distance);
            
            this.junctionA = junctionA;
            this.junctionB = junctionB;
        end
        
        function setNextFrame(this, frame)
            this.nextFrame = frame;
        end
        
        function out = getCurrentFrame(this)
            assert(~isempty(this.nextFrame));
            %out = filter(this.delayFilter, this.nextFrame) .* this.attenuation;
            out = this.delayFilter.nextSample(this.nextFrame) .* this.attenuation;
        end
        
        
        %function updateDistance(this,distance, FS)
           % TODO 
        %end
        
        function junct = getJunctionA(this)
            junct = this.junctionA;
        end
        
        function junct = getJunctionB(this)
            junct = this.junctionB;
        end
    end
    
end

