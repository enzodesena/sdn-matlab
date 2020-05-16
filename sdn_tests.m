%TESTS
%   This routine contains the test for the SDN Matlab implmenetation
%
%   Copyright (c) 2010, Enzo De Sena



%% First obvious test case

[x,y,z] = getReflectPosNObj(1,1,1,1,0.5,0.5,0.5,0.5,0.5,0.5);
assert(sum([x,y,z]==[0.5,0.0,0.5])==3);

[x,y,z] = getReflectPosNObj(1,1,1,2,0.5,0.5,0.5,0.5,0.5,0.5);
assert(sum([x,y,z]==[1,0.5,0.5])==3);

[x,y,z] = getReflectPosNObj(1,1,1,3,0.5,0.5,0.5,0.5,0.5,0.5);
assert(sum([x,y,z]==[0.5,1,0.5])==3);

[x,y,z] = getReflectPosNObj(1,1,1,4,0.5,0.5,0.5,0.5,0.5,0.5);
assert(sum([x,y,z]==[0,0.5,0.5])==3);

[x,y,z] = getReflectPosNObj(1,1,1,5,0.5,0.5,0.5,0.5,0.5,0.5);
assert(sum([x,y,z]==[0.5,0.5,1])==3);

[x,y,z] = getReflectPosNObj(1,1,1,6,0.5,0.5,0.5,0.5,0.5,0.5);
assert(sum([x,y,z]==[0.5,0.5,0])==3);

%% 

[x,y,z] = getReflectPosNObj(1,1,1,1,0.25,0.5,0.5,0.75,0.5,0.5);
assert(sum([x,y,z]==[0.5,0,0.5])==3);

[x,y,z] = getReflectPosNObj(1,1,1,2,0.25,0.5,0.5,0.75,0.5,0.5);
assert(sum([x,y,z]==[1,0.5,0.5])==3);

[x,y,z] = getReflectPosNObj(1,1,1,3,0.25,0.5,0.5,0.75,0.5,0.5);
assert(sum([x,y,z]==[0.5,1,0.5])==3);

[x,y,z] = getReflectPosNObj(1,1,1,4,0.25,0.5,0.5,0.75,0.5,0.5);
assert(sum([x,y,z]==[0,0.5,0.5])==3);

[x,y,z] = getReflectPosNObj(1,1,1,5,0.25,0.5,0.5,0.75,0.5,0.5);
assert(sum([x,y,z]==[0.5,0.5,1])==3);

[x,y,z] = getReflectPosNObj(1,1,1,6,0.25,0.5,0.5,0.75,0.5,0.5);
assert(sum([x,y,z]==[0.5,0.5,0])==3);


%%

delayFilter = DelayFilter(1);
assert(delayFilter.nextSample(0)==0);
assert(delayFilter.nextSample(1)==0);
assert(delayFilter.nextSample(2)==1);
assert(delayFilter.nextSample(3)==2);
assert(delayFilter.nextSample(4)==3);
assert(delayFilter.nextSample(0)==4);
assert(delayFilter.nextSample(4)==0);

delayFilter = DelayFilter(2);
assert(delayFilter.nextSample(0)==0);
assert(delayFilter.nextSample(1)==0);
assert(delayFilter.nextSample(2)==0);
assert(delayFilter.nextSample(3)==1);
assert(delayFilter.nextSample(4)==2);
assert(delayFilter.nextSample(0)==3);
assert(delayFilter.nextSample(4)==4);

%% Testing with object oriented implementation

room = Room();
room.shape = Cuboid(1,1,1);
sourcePos = Position(0,0,0);
observPos = Position(0,1,1);

res = getReflectPos(room,1,sourcePos,observPos);
assert(res.isEqual(Position(0,0,0)));

%%

room = Room();
room.shape = Cuboid(1,1,1);
sourcePos = Position(0,0,0);
observPos = Position(1,0,1);

res = getReflectPos(room,2,sourcePos,observPos);
assert(res.isEqual(Position(1,0,1)));

res = getReflectPos(room,3,sourcePos,observPos);
assert(res.isEqual(Position(0.5,1,0.5)));

res = getReflectPos(room,4,sourcePos,observPos);
assert(res.isEqual(Position(0,0,0)));

res = getReflectPos(room,5,sourcePos,observPos);
assert(res.isEqual(Position(1,0,1)));

res = getReflectPos(room,6,sourcePos,observPos);
assert(res.isEqual(Position(0,0,0)));

%%

room = Room();
room.shape = Cuboid(1,1,1);
sourcePos = Position(0.2,0.2,0.2);
observPos = Position(0.8,0.8,0.8);

res = getReflectPos(room,1,sourcePos,observPos);
assert(res.isEqual(Position(0.32,0,0.32)));

res = getReflectPos(room,2,sourcePos,observPos);
assert(res.isEqual(Position(1,1-0.32,1-0.32)));

res = getReflectPos(room,3,sourcePos,observPos);
assert(res.isEqual(Position(1-0.32,1,1-0.32)));

res = getReflectPos(room,4,sourcePos,observPos);
assert(res.isEqual(Position(0,0.32,0.32)));

res = getReflectPos(room,5,sourcePos,observPos);
assert(res.isEqual(Position(1-0.32,1-0.32,1)));

res = getReflectPos(room,6,sourcePos,observPos);
assert(res.isEqual(Position(0.32,0.32,0)));

%% Testing the objects

junctionA = Junction();
junctionA.position = Position(0,0,0);
junctionB = Junction();
junctionB.position = Position(0.02,0,0);


distance = Position.distance(junctionA.position, junctionB.position);
assert(distance==.02);

c = 343;
FS = 44100;
attenuation = (c./FS)/(distance);
delay = distance / c;
latency = round(delay.*FS);
assert(latency == 3);

propLine = PropLine(junctionA, junctionB, FS);
assert(propLine.getJunctionA() == junctionA);
assert(propLine.getJunctionB() == junctionB);


propLine.setNextFrame(1);
assert(propLine.getCurrentFrame() == 0);
propLine.setNextFrame(2);
assert(propLine.getCurrentFrame() == 0);
propLine.setNextFrame(3);
assert(propLine.getCurrentFrame() == 0);
propLine.setNextFrame(-1);
assert(propLine.getCurrentFrame() == 1*attenuation);
propLine.setNextFrame(-1);
assert(propLine.getCurrentFrame() == 2*attenuation);
propLine.setNextFrame(-1);
assert(propLine.getCurrentFrame() == 3*attenuation);
propLine.setNextFrame(-1);
assert(propLine.getCurrentFrame() == -1*attenuation);



%%

FS = 44100;
c = 343;

minDist = c/FS;
room = Room();
room.shape = Cuboid(8*minDist,8*minDist,1000);
%room.shape = Cuboid(8*minDist,1000,1000);
for i=1:6
    room.wallAttenuations{i} = 1;
    for j=1:5
        room.wallFilters{i}{j} = dfilt.delay(0);
    end
end

source = Source();
source.position = Position(6*minDist,5*minDist,500);
%source.position = Position(6*minDist,1000-3*minDist,500);
source.signal = Signal([1, zeros(1,8820)], 44100);

microphone = Microphone();
microphone.position = Position(3*minDist,5*minDist,500);
%microphone.position = Position(3*minDist,1000-3*minDist,500);

sim = Simulation();
sim.room = room;
sim.source = source;
sim.microphone = microphone;
sim.NSamples = 18;

sim.frameLength = 1;

output = sim.run(false);

cmp = zeros(1,18);
cmp(3+1) = 1/3;
cmp(7+1) = 1/7;
cmp(9+1) = 1/9;
cmp(10+1) = 1/(2*sqrt(5^2+1.5^2));
cmp(6+1) = 1/(2*sqrt(3^2+1.5^2));
cmp(11+1) = 2/(15*sqrt(3^2+1.5^2));
cmp(10+1) = cmp(10+1)+1/20;
cmp(13+1) = 1/15;
cmp(15+1) = 2/(15*sqrt(5^2+1.5^2));
cmp(13+1) = cmp(13+1)+1/20;
cmp(16+1) = 2/(5*7*sqrt(1.5^2+5^2));
cmp(16+1) = cmp(16+1)+1/(10*sqrt(1.5^2+5^2));
cmp(16+1) = cmp(16+1)+1/(10*sqrt(1.5^2+3^2));
cmp(13+1) = cmp(13+1)+2/(5*7*sqrt(1.5^2+3^2));
cmp(14+1) = 1/60;
cmp(17+1) = cmp(17+1)+1/(5*7)*(-3/5);
cmp(16+1) = cmp(16+1)+1/(10*sqrt(1.5^2+3^2))*(-3/5);
cmp(16+1) = cmp(16+1)+1/(10*sqrt(1.5^2+3^2))*(-3/5);
cmp(15+1) = cmp(15+1)+2/75;

assert(abs(sum(output-cmp))<10^(-10));


%% Done!
display('All tests succeded'); clear all;


