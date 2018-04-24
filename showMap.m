% Author: Riley Waters
% Date: 2017-04-18
%shows an interactive matrix of adhesion ponit locations

%centersAll - 3d matrix of point locations by framenumber.

function showMap(centersAll)

    if nargin > 2
        error('myfuns:somefun2:TooManyInputs', 'requires at most 2 inputs');
    end
    
    ii = length(centersAll(1,1,:));
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

end