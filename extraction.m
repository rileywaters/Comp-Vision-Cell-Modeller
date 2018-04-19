% Author: Riley Waters
% Date: 2017-04-18
%takes in an input cell video and outputs a matrix giving coordinates of
%each adhesion point. Options for making video. Requires RemoveOverLap.m

%videoName - Name of the initial video
%centersNum - Number of adhesion points on cell to look for
%diskR - (optional) Preprocessing disk radius
%diskN - (optional) Preprocessing number of lines to approximate disk
%houghSmall - (optional) minimum radius to search for circles
%houghLarge - (optional) maximum radius to search for circles
%houghSens - (optional) sensitivity value of hough transform
%houghEdge - (optional) edge threshold value of hough transform
%overlapOpt - (optional) select which type of overlap removal should occur
%overlapAmount - (optional) select how much a spot overlaps before handling
%boolSave - (optional) 'y' if program should save processed images
%iterate - (optional) set manually the number of frames to process
%boolVid - (optional) 'y' if program should construct video. Needs boolSave

function centersAll = extraction(videoName, centersNum, diskR, diskN, houghSmall, houghLarge, houghSens, houghEdge, overlapOpt, overlapAmount, boolSave, iterate, boolVid)
	
    if nargin > 13
        error('myfuns:somefun2:TooManyInputs', 'requires at most 13 inputs');
    end
    
    %set defaults if none given
    for k = nargin:nargs-1
        switch k
            case 0
                videoName = 'video.avi';
            case 1
                centersNum = 6;
            case 2
                diskR = 9;
            case 3
                diskN = 8;
            case 4
                houghSmall = 10;
            case 5
                houghLarge = 30;
            case 6
                houghSens = 0.8;
            case 7
                houghEdge = 0.1;
            case 8
                overlapOpt = 2;
            case 9
                overlapAmount = 10;
            case 10
                boolSave = 'y';
            case 11
                iterate = 400;
            case 12
                boolVid = 'y';
            otherwise
        end
    end

    mkdir(workingDir,'images');
    warning('off', 'images:imfindcircles:warnForLargeRadiusRange');

    video = VideoReader(videoName);

    fname = 'C:\Users\Riley\Desktop\2017-2018 Homework\Thesis\Proj\images';
    %best is ('disk', 9, 8)
    se = strel('disk',diskR,diskN);

    %initialize the centers matrix
    centersAll = zeros(centersNum,2,iterate);

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
        [centers, radii] = imfindcircles(adjFrame,[houghSmall houghLarge],'ObjectPolarity','bright', 'Sensitivity', houghSens, 'EdgeThreshold', houghEdge);




    %     find how many circles
        num = numel(centers)/2;
        if num >= 2
            %best is overlap of 10, option 2
             [centers, radii] = RemoveOverLap(centers, radii, overlapAmount, overlapOpt);
             num = numel(centers)/2;
        end
    %     if there are circles, find and plot them
        if num ~= 0
            %If theres more than 6, grab the top 6
            if num > centersNum
                num = centersNum;
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
        if boolSave == 'y'
          filename = [sprintf('%03d',ii) '.jpg'];
          saveas(gcf,fullfile(fname, filename));
        end
      %close all;
      if mod(ii,50) == 0
          fprintf('Processing Frames... Number of frames currently processed: %i\n',ii);
      end
    %Control the iterations here
      if ii == iterate
          break;
      end
    end

    fprintf('Program completed. Number of frames processed: %i\n',ii);

    %%Construct video
    if boolVid == 'y'
        cd 'images';
        finalVid = VideoWriter('finalVid.avi');
        open(finalVid);
        fprintf('Creating Video... Please Wait\n');

        for iii =1:ii
           file = [sprintf('%03d',iii) '.jpg'];
            I = imread(file);
            writeVideo(finalVid,I);
        end
        fprintf('Video Created.');
        close(finalVid);
    end

end