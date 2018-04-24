% Author: Riley Waters
% Date: 2018-04-18
%takes a matrix of centers and outputs a possible model of the cell
%requires figure2html.m if exporting

%videoName - Name of the initial video
%centersAll - 3d matrix of point locations by framenumber
%last - the reference frame number
%autoSmall - lower bound of circle finding to auto determine model size
    %Lower bound pixel size of cell radius
%autoLarge - upper bound of circle finding to auto determine model size
    %Upper bound pixel size of cell radius
%manualCenter - use in case auto circle finding cant find the cell edge
    %Manually specify center of cell pixel coordinate of X
%manualRadius - use in case auto circle finding cant find the cell edge
    %Manually specify cell radius
%boolExport - 'y' if the model needs to be exported to a Matlab 3dx model
    


function modelling(videoName, centersMatrix, last, autoSmall, autoLarge, manualCenter, manualRadius, boolExport)

    if nargin > 8
        error('myfuns:somefun2:TooManyInputs', 'requires at most 8 inputs');
    end
    
    %Set default parameters
    for k = nargin:7
        switch k
            case 0
                videoName = 'registered100.avi';
            case 1
                centersMatrix = centersAll;
            case 2
                last = 372;
            case 3
                autoSmall = 95;
            case 4
                autoLarge = 155;
            case 5
                manualCenter = 130;
            case 6
                manualRadius = 90;
            case 7
                boolExport = 'n';
            otherwise
        end
    end
    
    centersNum = length(centersMatrix(:,1));
    
   
    
    %Attempt to automatically find the cell edge
    video = VideoReader(videoName);
    frame = readFrame(video);
    frame = rgb2gray(frame);
    adjFrame = imadjust(frame);

    [centers, radii] = imfindcircles(adjFrame,[autoSmall autoLarge],'ObjectPolarity','bright', 'Sensitivity', 0.8, 'EdgeThreshold', 0.1);

    num = numel(centers)/2;
    if num ~= 0
        %if it finds the cell edge in picture, use those to construct a 1:1 model
        imshow(adjFrame);
        hold on;
        viscircles(centers, radii,'EdgeColor','b');
        cen = centers(1,1);
        cenX = cen;
        cenY = cen;
        cenZ = cen;
        radius = radii;
    else
        %if it doesn't find the cell edge, use the manually specified
            %center and radius
        cenX = manualCenter;
        cenY = manualCenter;
        cenZ = manualCenter;
        radius = manualRadius;
    end
    
    xf = zeros(1,centersNum);
    yf = zeros(1,centersNum);
    zf = zeros(1,centersNum);
    
    lastAfter = last+15;
    for i = 1:centersNum
        %point movement analysis and plotting
        xf(i) = centersMatrix(i,1,last);
        yf(i) = centersMatrix(i,2,last);
        xAfter = centersMatrix(i,1,lastAfter);
        yAfter = centersMatrix(i,2,lastAfter);
        
            if xAfter > xf(i) && yAfter > yf(i)
                %move to bottom if x and y moved up
                 zf(i) = -sqrt((radius)^2-(xf(i)-cenX)^2-(yf(i)-cenY)^2)+cenZ;
            else
                %otherwise place on top
                zf(i) = sqrt((radius)^2-(xf(i)-cenX)^2-(yf(i)-cenY)^2)+cenZ;
            end
        
       
    end


    % Generate the x, y, and z data for the sphere
    r = radius;
    [x,y,z] = sphere(50);
    x0 = cenX; y0 = cenY; z0 = cenZ;
    x = x*r + x0;
    y = y*r + y0;
    z = z*r + z0;

    figure
    lightGrey = 0.5*[1 1 1]; % It looks better if the lines are lighter
    surface(x,y,z,'FaceColor', 'none','EdgeColor',lightGrey)
    hold on


    axis equal % so the sphere isn't distorted
    view([1 1 0.75]) % adjust the viewing angle
    xlabel('X');
    ylabel('Y');
    zlabel('Z');

    %add the blue line on circumference
    theta = linspace(0,2*pi);
    X = cenX+radius.*cos(theta);
    Y = cenY+radius.*sin(theta);
    Z = cenZ.*ones(size(X));                                 
    plot3(X,Y,Z);
    hold on;

    %add the points
    for i = 1:centersNum
        if boolExport == 'y'
            %if exporting, you need physical markers and not just targets
            msphere(xf(i),yf(i),zf(i));
        end
        scatter3(xf(i),yf(i),zf(i),100,'MarkerEdgeColor','r')
        scatter3(xf(i),yf(i),zf(i),30,'+', 'MarkerEdgeColor','r')
    end
    
    axis tight;
    rotate3d on;

    fprintf('Modelling Complete\n');
    
    if boolExport == 'y'
        %export to Matlab X3D Model format
        options=struct('output','both','height',500,'width',500,'headlight',true,'title','Matlab X3D Model','interactive',true,'embedimages',false);
        figure2xhtml('Model', options);
        fprintf('Model Exported\n');
    end

end