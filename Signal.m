 classdef Signal < handle
%SIGNAL The signal thisect.
% To improve performance and lower memory usage,
% instead of storing the time axis as a variable,
% only the sampling frequency and the number of initial
% zeros are kept. A signal that has non-zero values
% in the negative part of the time axis has a negative
% initial delay. When initDelay = 0, the data has its
% first tap in zero.
%   Copyright (c) 2010, Enzo De Sena
    
    properties
        data
        FS = 44100;
        initDelayTap = 0;
    end
    
    
    methods
        function obj = Signal(data, FS, initDelayTap)
            if nargin >= 1
                obj.data = data;
            end
            if nargin >= 2
                assert(isscalar(FS));
                obj.FS = FS;
            end
            if nargin >= 3
                obj.initDelayTap = initDelayTap;
            end
        end
        
        function sampleFreq = SP(this)
            sampleFreq = 1 / this.FS;
        end
        
        function delay = initDelay(this)
            delay = this.initDelayTap * this.SP;
        end
        
        function nTap = nTap(this)
            nTap = length(this.data);
        end
        
        function duration = duration(this)
            duration = this.nTap / this.FS;
        end
        
        function time = time(this)
            time = this.initDelay:(this.SP):(this.initDelay + this.duration - this.SP);
        end
        
        function newSignal = getHalfWavedSignal(this)
            newSignal = Signal(this.data .* (this.data > 0), this.FS, this.initDelayTap);
        end
        
        function newSignal = getSignalWithoutDC(this)
            newSignal = Signal(this.data - mean(this.data), this.FS, this.initDelayTap);
        end
        
        function newSignal = getSignalMultipliedBy(this, normalisation)
            newSignal = Signal(this.data .* normalisation, this.FS, this.initDelayTap);
        end
        
        function newSignal = getClippedSignal(this, thresholdUp, thresholdDown)
            newSignal = Signal((this.data < thresholdUp) .* this.data ...
                + (this.data >= thresholdUp) .* thresholdUp, this.FS, this.initDelayTap);
            
            if nargin >= 3
                newSignal.data = (newSignal.data > thresholdDown) .* newSignal.data ...
                    + (newSignal.data <= thresholdDown) .* thresholdDown;
            end
        end
        
        function newSignal = getSignalElevatedTo(this, x)
            newSignal = Signal(this.data .^ x, this.FS, this.initDelayTap);
        end
        
        function newSignal = getFilteredSignal(this, num, den)
			assert(nargin == 2 | nargin == 3);
			if nargin == 3
				newSignal = Signal(filter(num,den,this.data), this.FS, this.initDelayTap);
			else 
				% This is the case where num is the filter object
				newSignal = Signal(filter(num,this.data), this.FS, this.initDelayTap);
			end
        end
        
        function newSignal = getUpsampledSignal(this, N)
            newSignal = Signal(upsample(this.data,N), N .* this.FS, N .* this.initDelayTap);
        end
        
        function rms = RMS(this)
            rms = sqrt(mean(this.data.^2));
        end
        
        function set.data(this, data)
            
            % We store data only as row vectors
            [M, N] = size(data);
            assert(isempty(data) || isvector(data));
            if N > 1 && M == 1
                this.data = data;
            else
                this.data = data';
            end
        end
        
        function set.initDelayTap(this, initDelayTap)
        	this.initDelayTap = initDelayTap;
        end
        
        function value = get.data(this)
            if rem(this.initDelayTap, 1) == 0
                value = this.data;
            else
                fracDelay = rem(this.initDelayTap, 1);
                [N, D] = Signal.thiran(fracDelay);
                value = filter(N, D, this.data);
            end
        end
        
        function plot(this)
            plot(this.time, this.data);
        end
        
        function frame = getFrame(this, frameID, frameLength)
            % This function gives back a frame of the signal.
            % frameID=1...inf.
            
            firstIndex = (frameID-1).*frameLength + 1;
            lastIndex = firstIndex + frameLength - 1;
            frame = Signal(this.data((firstIndex):(min(lastIndex, this.nTap))),this.FS);
        end
        
        
        function obj = clone(this)
           obj = Signal(this.data, this.FS, this.initDelayTap);
        end
    end
    
    methods (Static)
        
        function sumSignal = getSum(signal1, signal2)
            if isempty(signal1) || isempty(signal1.data)
                sumSignal = signal2.clone();
                return
            end
            if isempty(signal2) || isempty(signal2.data)
                sumSignal = signal1.clone();
                return
            end
            
            assert(signal1.FS == signal2.FS);
            
            if (signal1.initDelayTap == signal2.initDelayTap && signal1.nTap == signal2.nTap)
                sumSignal = Signal(signal1.data + signal2.data, signal1.FS, signal1.initDelayTap);
                return
            end
            
            sumSignal = Signal;
            sumSignal.FS = signal1.FS;
            sumSignal.initDelayTap = ...
                min(signal1.initDelayTap, signal2.initDelayTap);
            
            nx = signal1.time;
            ny = signal2.time;
            nz = min(min(nx),min(ny)) : (sumSignal.SP) : max(max(nx),max(ny)); 
            z1 = zeros(1,length(nz)); 
            z2 = z1; 
            z1(find((nz>=(min(nx) - sumSignal.SP / 2)) & ...
                (nz<=(max(nx) + sumSignal.SP / 2)))) = signal1.data;  %#ok<FNDSB>
            z2(find((nz>=(min(ny) - sumSignal.SP / 2)) & ...
                (nz<=(max(ny) + sumSignal.SP / 2)))) = signal2.data; %#ok<FNDSB>
            sumSignal.data = z1 + z2;
        end
        
        function xcor = getXCorr(signal1, signal2)
            assert(signal1.FS == signal2.FS);
            xcor = Signal;
            xcor.FS = signal1.FS;
            
            tapDiff = signal2.initDelayTap - signal1.initDelayTap;
            if tapDiff >= 0
                data1 = signal1.data;
                data2 = [zeros(1, tapDiff), signal2.data];
            else
                data1 = [zeros(1, -tapDiff), signal1.data];
                data2 = signal2.data;
            end
            xcor.data = xcorr(data1, data2);
            maxNTap = max(length(data1), length(data2));
            xcor.initDelayTap = -(maxNTap - 1);
        end 
        
        function flipped = getFlipped(signal)
           flipped = Signal(fliplr(signal.data), signal.FS, - (signal.initDelayTap + signal.nTap));
        end
            
		function convo = getConvolution(signal1, signal2)
			assert(signal1.FS == signal2.FS);
			convo = Signal;
			convo.FS = signal1.FS;
            
            N1 = signal1.nTap;
            N2 = signal2.nTap;
            if N1*N2 < (N1+N2-1)*(3*log2(N1+N2-1)+1)
                convo.data = conv(signal1.data, signal2.data);
            else
                display('Running convolution in the freq domain');
                X1 = fft(signal1.data,N1+N2-1);
                X2 = fft(signal2.data,N1+N2-1);
                Y = X1.*X2;
                if (isreal(signal1.data) && isreal(signal2.data))
                    convo.data = real(ifft(Y));
                else
                    convo.data = ifft(Y);
                end
            end
			convo.initDelayTap = signal1.initDelayTap + signal2.initDelayTap;
        end
        
        function pinkified = pinkify(signal)
            poles = [0.9986823 0.9914651 0.9580812 0.8090598 0.2896591];
            zeros = [0.9963594 0.9808756 0.9097290 0.6128445 -0.0324723];

            N = poly(zeros);
            D = poly(poles);
            pinkified = Signal(filter(N,D,signal.data), signal.FS, signal.initDelay);
        end
        
        function matrix = getMatrix(signals, withInitialDelay)
            % This function returns a matrix containing the signals on the
            % columns.
            nSignals = length(signals);
            lengths = zeros(1, nSignals);
            initDelayTaps = zeros(1, nSignals);
            
            for i = 1:nSignals
               signal_i = signals(i);
               lengths(i) = signal_i.nTap;
               initDelayTaps(i) = signal_i.initDelayTap;
            end
            
            maxLenght = max(lengths + initDelayTaps);
            matrix = zeros(maxLenght, nSignals);
           
            for i = 1:nSignals
               signal_i = signals(i);
               matrix(:, i) = [zeros(initDelayTaps(i), 1); signal_i.data'; ...
                   zeros(maxLenght - (initDelayTaps(i) + lengths(i)), 1)];
            end
            
            if ~withInitialDelay
               minInitDelayTap = min(initDelayTaps);
               matrix = matrix((minInitDelayTap + 1):maxLenght, :);
            end
        end
      
    end
    
    methods (Access = private, Static = true)
        % Author: Huseyin Hacihabiboglu
        function [N, D] = thiran(fdelay, order)
            n = 0:order;
            a = zeros(1, order);
            for i=1:order
                a(i)=(-1)^i*((factorial(order)/(factorial(i)*factorial(order-i))))*prod(((fdelay-order+n)./(fdelay-order+i+n)),2);
            end

            D = [1 a];
            N = fliplr(D);
        end
    end
end

