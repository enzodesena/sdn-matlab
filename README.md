# Scattering Delay Network (SDN)

This is a Matlab implementation of the room acoustic simulator "Scattering Delay Network" (SDN) as described in [1] and [2]. If you use this code in your research publication, please make sure to cite [1].

Please notice that this Matlab implementation was written quickly in 2010 for the purpose of showing results in [2], and is **extremely slow**, possibly because of the sample-by-sample operation and Matlab's inefficient handling of object-oriented programming. **The algorithm itself is actually orders of magnitude faster than even fft-based convolution. A dynamic C++ implementation exists which uses << 1% of a single core on a modern CPU.**

To get acquainted with the code, you can look into the script 'sdn_examples.m'. You can also check that everything is working as expected by running 'sdn_tests.m'. 

Please notice that the SDN algorithm is protected by USPTO patent 8,908,875 [3]. More specifically, the part of package that implements the patent is contained in the file "Simulation.m". **If you'd like to use this software for any reason other than non-commercial research purposes, please contact enzodesena AT gmail DOT com**



## Getting Started

### Prerequisites 

You need the Signal Processing Toolbox. 

### Installation

No need to install: just clone/download and you are ready to go!

### Example

```matlab
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
```


### Running the tests

Run `sdn_tests`.


## Authors

The conceptual work to develop SDN was carried out by all authors in [1] and [2].

The Matlab software was written by Enzo De Sena while he was a PhD student at King's college London in 2010. 

* **Enzo De Sena** - [desena.org](https://desena.org)

## References

[1] E. De Sena, H. Hacıhabiboğlu, Z. Cvetković, and J. O. Smith III "Efficient Synthesis of Room Acoustics via Scattering Delay Networks," IEEE/ACM Trans. Audio, Speech and Language Process., vol. 23, no. 9, pp 1478 - 1492, Sept. 2015.

[2] E. De Sena, H. Hacıhabiboğlu, and Z. Cvetković, "Scattering Delay Network: An Interactive Reverberator for Computer Games," in Proc. 41st AES International Conference: Audio for Games, London, UK, February 2011.

[3] E. De Sena, H. Hacıhabiboğlu, and Z. Cvetković, "Electronic Device with Digital Reverberator and Method", US Patent n. 8,908,875, filed 2/2/2012, granted 09/12/2014.


## License

This project is licensed under the AGPL License - see the [LICENSE](LICENSE) file for details. Also notice that parts of the code are protected under USPTO patent n. 8,976,977.
