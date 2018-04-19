%% Main All - Riley Waters
close all; clear all; clc;
workingDir = 'C:\Users\Riley\Desktop\2017-2018 Homework\Thesis\Proj';
cd(workingDir);

mkdir(workingDir,'images');

warning('off', 'images:imfindcircles:warnForLargeRadiusRange');

%% 
video = VideoReader('registered100.avi');

fname = 'C:\Users\Riley\Desktop\2017-2018 Homework\Thesis\Proj\images';
%best is ('disk', 9, 8)
se = strel('disk',9,8);

%initialize the centers matrix
centersAll = zeros(6,2,400);

ii = 0;
fprintf('Processing Frames... Please Wait\n');
while hasFrame(video)
    ii = ii+1;
    frame = readFrame(video);
    frame = rgb2gray(frame);

    %Preprocessing
    clFrame = imclose(frame, se);
    opFrame = imopen(clFrame, se);
    adjFrame = imadjust(opFrame);

    nFrame = imadjust(frame);

%     Use hough transform to find circles
%     best is [10 30], 0.8, 0.1
    [centers, radii] = imfindcircles(adjFrame,[10 30],'ObjectPolarity','bright', 'Sensitivity', 0.80, 'EdgeThreshold', 0.1);
    
   
   

%     find how many circles
    num = numel(centers)/2;
    if num >= 2
        %best is overlap of 10, option 2
         [centers, radii] = RemoveOverLap(centers, radii, 10, 2);
         num = numel(centers)/2;
    end
%     if there are circles, find and plot them
    if num ~= 0
        %If theres more than 6, grab the top 6
        if num > 6
            num = 6;
        end
        
        h = figure;
        set(h, 'Visible', 'off');
        imshow(nFrame);
        %hold on;
        %viscircles(centers, radii,'EdgeColor','b');
        %Show the circles and crosshairs on the image
        for i= 1:num
          centerStrong = centers(i,:);
          radiiStrong = radii(i);
          centersAll(i,:,ii) = centerStrong;
          x = centerStrong(1,1);
          y = centerStrong(1,2);
          hold on;
          viscircles(centerStrong, radiiStrong,'EdgeColor','r');
          scatter(x,y,50,'+', 'r', 'LineWidth',1);
        end   
    end

  %Save the image

  filename = [sprintf('%03d',ii) '.jpg'];
  saveas(gcf,fullfile(fname, filename));

  %close all;
  if mod(ii,50) == 0
      fprintf('Processing Frames... Number of frames currently processed: %i\n',ii);
  end
%Control the iterations here
  if ii == 400
      break;
  end
end

fprintf('Program completed. Number of frames processed: %i\n',ii);

%%Construct video
% cd 'images';
% finalVid = VideoWriter('finalVid.avi');
% open(finalVid);
% fprintf('Creating Video... Please Wait\n');
% 
% for iii =1:ii
%    file = [sprintf('%03d',iii) '.jpg'];
%     I = imread(file);
%     writeVideo(finalVid,I);
% end
% fprintf('Video Created.');
% close(finalVid);

%%

finalVid = VideoWriter('finalVid.avi');
open(finalVid);
fprintf('Creating Video... Please Wait\n');
ii = 250;
for iii =1:ii
   file = [sprintf('%04d',iii) '.png'];
    I = imread(file);
    writeVideo(finalVid,I);
end
fprintf('Video Created.');
close(finalVid);

%% show map
xPlot = centersAll(:,1,:);
yPlot = centersAll(:,2,:);
zPlot = zeros(6,1,ii);
for iii =1:ii
    for i=1:6
        zPlot(i,:,iii) = iii;
    end
end
cNew = horzcat(xPlot, yPlot, zPlot);
a = cNew(:,1,:);

num = ii *6;
a1 = reshape(a, [1,num]);
b = cNew(:,2,:);
b1 = reshape(b, [1,num]);
c = cNew(:,3,:);
c1 = reshape(c, [1,num]);

figure;
c2 = c1;
scatter3(a1, b1, c1, 50, c2, '.');
colormap(jet);
colorbar;
xlabel('X Coordinate');
ylabel('Y Coordinate');
zlabel('Frame Number');
rotate3d on;

%%
