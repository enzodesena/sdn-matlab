classdef DelayFilter < handle
%DELAY Class implementing a delay line
%   
%   Copyright (c) 2010, Enzo De Sena
    
    properties
        state
        index = 0;
        latency;
    end
    
    methods
        function this = DelayFilter(latency)
            this.state = zeros(1,latency+1);
            this.latency = latency;
        end
        
        function out = nextSample(this, thisSample)
            this.state(mod(this.index, this.latency+1) + 1) = thisSample;
            out = this.state(mod(this.index + 1, this.latency + 1) + 1);
            
            this.index = this.index + 1;
        end
    end
    
end

