% Example script generating the SDN output for:
% - a 5x5x5 m room,
% - a source positioned at (0.3,0.5,0.9)
% - an omnidirectional microphone positioned at (0.4,0.1,0.4)
% - wall reflection coefficient of 0.9 followed by a low-pass butterworth
%   filter
% - sampling frequency: 44100
% - calculating 10000 samples (i.e. ~0.23 sec)


room = Room();
room.shape = Cuboid(5,5,5);
d=fdesign.lowpass('N,F3dB',5,15000,44100);
for i=1:6
    room.wallAttenuations{i} = 0.9;
    for j=1:5
        room.wallFilters{i}{j} = design(d,'butter'); %dfilt.delay(0);%
    end
end

source = Source();
source.position = Position(0.3,0.5,0.9);
source.signal = Signal([1, zeros(1,9999)], 44100);

microphone = Microphone();
microphone.position = Position(0.4,0.1,0.4);

sim = Simulation();
sim.room = room;
sim.source = source;
sim.microphone = microphone;
sim.NSamples = 10000;

sim.frameLength = 1;

output = sim.run();

plot(output)