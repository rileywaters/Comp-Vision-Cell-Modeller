%% Thesis - Riley Waters
close all; clc;

numCenters = 6;
iterate = 400;

%Video name is 'registered100.avi, extracting 6 adhesion points for the
%first 400 frames
centersAll = extraction('registered100.avi', numCenters, iterate);

%%
save('example.mat','centersAll')

%%
load('example.mat')

%%
clc;
showMap(centersAll);

%%
clc;
modelling(centersAll, 'n');

%%


