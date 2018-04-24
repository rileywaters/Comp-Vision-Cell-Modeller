% Author: Riley Waters
% Date: 2018-04-18
%takes a matrix of centers and outputs a possible model of the cell
%requires figure2html.m if exporting

%centersAll - 3d matrix of point locations by framenumber
%boolExport - 'y' if the model needs to be exported to a Matlab 3dx model
%last - the reference frame number


function modelling(centersMatrix, boolExport, last)

    if nargin > 2
        error('myfuns:somefun2:TooManyInputs', 'requires at most 2 inputs');
    end
    
    %Set default parameters
    for k = nargin:3
        switch k
            case 0
                centersMatrix = centersAll;
            case 1
                boolExport = 'n';
            case 2
                last = 372;
            otherwise
        end
    end
    
    centersNum = length(centersMatrix(:,1));
    
   
    
    %right now, these are set because the center pixel of the video is
    %130,130 and the cell in the vid is ~90px wide
    %TODO: Turn these into variables that change depending on the size of
    %the video. Detect the outer cell edge in Extraction to determine radius
    %automatically
    cenX = 130;
    cenY = 130;
    cenZ = 130;
    radius = 90;

    
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