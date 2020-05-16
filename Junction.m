%JUNCTION  
%
%   See also Position, Room, Shape
%
%   Copyright (c) 2010, Enzo De Sena
classdef Junction < handle
    properties
        wallFilters
        wallAttenuation = 1;
        position
    end
    
    properties (Access='private')
        propLinesIn = [];
        propLinesOut = [];
    end
    
    methods
        function this = Junction()
        end
            
        function [framesOut, pressureOut,framesIn] = getFramesOut(this, sourceFrame)
            % To produce the output to one of the neighbouring junctions, I
            % need all the inputs ready.
            
            assert(length(this.propLinesOut) == length(this.propLinesIn));
            M = length(this.propLinesOut);
            
            framesIn = cell(1,M);
            for i=1:M
                framesIn{i} = this.propLinesIn{i}.getCurrentFrame();
            end
            
            N = length(framesIn{1});
            
            framesOut = cell(1,M);
            for i=1:M
                propLineOut = this.propLinesOut{i};
                
                tempFrame = zeros(1, N);
                for j=1:M
                    frameIn = framesIn{j}; % This is P+_j
                    
                    if nargin == 2
                        frameIn = frameIn + sourceFrame ./ 2;
                    end
                    
                    propLineIn = this.propLinesIn{j};
                    % Implementing S=1/M-I...
                    if (propLineOut.getJunctionB() == propLineIn.getJunctionA())
                        a = 2/M - 1;
                    else
                        a = 2/M;
                    end
                    
                    tempFrame = tempFrame + frameIn.*a;
                end
                
                
                %%% Filter the signal at the output
                filteredFrame = filter(this.wallFilters{i}, tempFrame) .* this.wallAttenuation;
                
                framesOut{i} = filteredFrame;
                
                if i == 1
                    pressureOut = (2./M).*filteredFrame;
                else
                    pressureOut = pressureOut + (2./M).*filteredFrame;
                end
                
                
            end
        end
        
        function pushNextFrameInPropLines(this, framesOut)
            M = length(this.propLinesOut);
            assert(length(framesOut) == M);
            for i=1:M
                this.propLinesOut{i}.setNextFrame(framesOut{i});
            end
        end
        
        function addPropLineIn(this,propLine)
            this.propLinesIn{length(this.propLinesIn)+1} = propLine;
        end
        
        function addPropLineOut(this,propLine)
            this.propLinesOut{length(this.propLinesOut)+1} = propLine;
        end
        
        function n = getNumPropLinesOut(this)
            n = length(this.propLinesOut);
        end
        
        function setWallFilter(this, filters)
            this.wallFilters = filters;
            for i=1:this.getNumPropLinesOut()
                this.wallFilters{i}.PersistentMemory = true;
            end
        end
    end
    
end

