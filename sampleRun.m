%% Sample Run
close all; clc; clear all;


%%

%uses 'registered.avi' video, finding 6 spots per frame, processing the first 400 frames
%saves pictures and video to 'images' folder

%alternatively, just load('example.mat');
%this is aready processed 400 frames
centersAll = extraction('registered100.avi', 6, 400, 'y', 'y');

%visualizes the coordinate matrix
showMap(centersAll);

%models cell using the found coordinate matrix, with reference frame 372
modelling('registered100.avi', centersAll, 372);

