%SIMULATION  Class implementing the Scattering Delay Network (SDN) algorithm
%
%   See also Position, Room, Shape
%
%   Author: Enzo De Sena
%  
%   Copyright (c) 2010, Enzo De Sena, UK
%   All rights reserved.
%   
%   Please notice that this algorithm is protected by USPTO patent:
%   E. De Sena, H. Hac?habibo?lu, and Z. Cvetkovi?, inventors; 
%   King's College London, assignee, "Electronic Device with Digital 
%   Reverberator and Method", US Patent n. 8,908,875, filed 2/2/2012, 
%   granted 09/12/2014.
%   For any queries, please contact Enzo De Sena at enzodesena AT gmail DOT com
classdef Simulation < handle
    properties
        room
        source
        microphone
        frameLength = 1;
        NSamples
    end
    
    methods
        function output = run(this, verbose)
            if nargin < 2
                verbose = true;
            end
            
            %%% Initialize variables
            
            M = 6;  % 3D case
            FS = this.source.signal.FS;
            
            % junctions is the vector containing all the junction
            % objects.
            junctions = cell(1,M);
            for i=1:M
                junction = Junction();
                
                %%% Run the ray-tracing module
                junction.position = getReflectPos(this.room, i, this.source.position, this.microphone.position);
                junctions{i} = junction;
            end
            
            
            
            for i=1:M
                for j=1:M
                    if i==j
                        continue;
                    end
                    
                    % The offset -1 means that we want a propagation line
                    % with delaysample - 1. This is due to the way the
                    % updating at the junction is made, which intrinsecally
                    % delays the output by one sample.
                    propLine = PropLine(junctions{i}, junctions{j}, FS, -1);
                    
                    % Initialize the propagation lines with empty frames
                    propLine.setNextFrame(zeros(1,this.frameLength));
                    
                    % Tell the in and out junctions that this is their
                    % propagation line.
                    junctions{i}.addPropLineOut(propLine);
                    junctions{j}.addPropLineIn(propLine);

                    propLine.attenuation = 1;
                end
            end
            
            % TBD: define the filters
            for i=1:M
                junctions{i}.wallAttenuation = this.room.wallAttenuations{i}; %this.room.wallAttenuations{i};
                junctions{i}.setWallFilter(this.room.wallFilters{i});
            end
            
            
            
            % Define source propagation line
            sPropLines = cell(1,M);
            sDummyJunction = Junction();
            sDummyJunction.position = this.source.position;
            firstSourceFrame = this.source.signal.getFrame(1, this.frameLength).data;
            for i=1:M
                propLine = PropLine(sDummyJunction, junctions{i}, FS);
                propLine.setNextFrame(firstSourceFrame);
                sPropLines{i} = propLine;
            end
            
            % Define microphone propagation line
            mPropLines = cell(1,M);
            mDummyJunction = Junction();
            mDummyJunction.position = this.microphone.position;
            for i=1:M
                mPropLine = PropLine(junctions{i}, mDummyJunction, FS);
                
                distSourceJunct = Position.distance(junctions{i}.position, sDummyJunction.position);
                distJunctMic = Position.distance(junctions{i}.position, mDummyJunction.position);

                
                % We use this attenuation in such a way that the first
                % order reflections have an exact attenuation. (We don't
                % have (mPropLine.c ./ FS) at the numerator, because it is
                % already at the numerator of the attenuation of the
                % propLine between source and junction.
                mPropLine.attenuation = 1 / (1 + distJunctMic/distSourceJunct);
                mPropLines{i} = mPropLine;
            end
            
            % Define one last propagation line between source and
            % microphone. This line models the LOS component.
            smPropLine = PropLine(sDummyJunction, mDummyJunction, FS);
            smPropLine.setNextFrame(firstSourceFrame);
            
            %%% Run the simulation sample by sample
            tempOutput = zeros(M, this.NSamples);
            output = zeros(1, this.NSamples);
            n = 1;
            while true
                if n > this.NSamples
                    break;
                end
                
                if verbose && mod(n/100,1) == 0
                    display(['>> Running frame n. ', num2str(n)]);
                end
                
                framesOut = cell(1,M);
                for i=1:M
                    
                    [framesOut{i}, pressureFrame] = junctions{i}.getFramesOut(sPropLines{i}.getCurrentFrame());
                    
                    mPropLines{i}.setNextFrame(pressureFrame);
                    
                    tempOutput(i,n) = mPropLines{i}.getCurrentFrame();
                end
                
                %TODO: weight the mic directivity pattern
                output(n) = sum(tempOutput(:,n)) + smPropLine.getCurrentFrame();
                
                smPropLine.setNextFrame(this.source.signal.getFrame(n+1, this.frameLength).data);
                
                for i=1:M
                    sPropLines{i}.setNextFrame(this.source.signal.getFrame(n+1, this.frameLength).data);
                    junctions{i}.pushNextFrameInPropLines(framesOut{i});
                end
                
                
                n = n + 1;
            end
            
        end
    end
    
    methods(Access='private')
        
    end
end

