%% Thesis - Riley Waters
close all; clc;

%% test
close all; clc;
cenX = 130;
cenY = 130;
cenZ = 130;
radius = 90;

x1 = centersAll(1,1,16);
y1 = centersAll(1,2,16);
z1 = sqrt((radius)^2-(x1-cenX)^2-(y1-cenY)^2)+cenZ;

x2 = centersAll(2,1,16);
y2 = centersAll(2,2,16);
z2 = -1 *sqrt((radius)^2-(x2-cenX)^2-(y2-cenY)^2)+cenZ;

x3 = centersAll(3,1,16);
y3 = centersAll(3,2,16);
z3 = -1 * sqrt((radius)^2-(x3-cenX)^2-(y3-cenY)^2)+cenZ;

x4 = centersAll(4,1,16);
y4 = centersAll(4,2,16);
z4 = -1 * sqrt((radius)^2-(x4-cenX)^2-(y4-cenY)^2)+cenZ;

x5 = centersAll(5,1,16);
y5 = centersAll(5,2,16);
z5 = -1 *sqrt((radius)^2-(x5-cenX)^2-(y5-cenY)^2)+cenZ;
%z5 = 49.4632;

%x6 = centersAll(6,1,16);
%y6 = centersAll(6,2,16);
%z6 = sqrt((radius)^2-(x6-cenX)^2-(y6-cenY)^2)+cenZ;


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

%msphere(x1,y1,z1);
scatter3(x1,y1,z1,100,'MarkerEdgeColor','r')
scatter3(x1,y1,z1,30,'+', 'MarkerEdgeColor','r')
%msphere(x2,y2,z2);
scatter3(x2,y2,z2,100,'MarkerEdgeColor','r')
scatter3(x2,y2,z2,30,'+', 'MarkerEdgeColor','r')
%msphere(x3,y3,z3);
scatter3(x3,y3,z3,100,'MarkerEdgeColor','r')
scatter3(x3,y3,z3,30,'+', 'MarkerEdgeColor','r')
% msphere(x4,y4,z4);
scatter3(x4,y4,z4,100,'MarkerEdgeColor','r')
scatter3(x4,y4,z4,30,'+', 'MarkerEdgeColor','r')
%msphere(x5,y5,z5);
scatter3(x5,y5,z5,100,'MarkerEdgeColor','r')
scatter3(x5,y5,z5,30,'+', 'MarkerEdgeColor','r')
%msphere(x6,y6,z6);
scatter3(x6,y6,z6,100,'MarkerEdgeColor','r')
scatter3(x6,y6,z6,30,'+', 'MarkerEdgeColor','r')
axis tight;
rotate3d on;

%%

%      options.output : Produce output files 'x3d', 'xhtml' or 'both' (default)
%      options.width : Width of X3D render object in pixels default 500 
%      options.height : Height of X3D render object in pixels default 500 
%      options.headlight : Enable Camera head light, boolean true/false
%                           (default true)
%      options.embedimages : Instead of using separate .png files embed 
%                            the images in xhtml (Not supported bij IE9)
%                           (default false)
%      options.title : Title of xhtml page, default 'Matlab X3D'
%      options.interactive : Make mesh/surface objects clickable in xhtml,
%                          boolean true/false (default false)
options=struct('output','both','height',500,'width',500,'headlight',true,'title','Matlab X3D Model','interactive',true,'embedimages',false);
figure2xhtml('test', options);
