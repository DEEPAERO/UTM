% Special notes:
% Get height map from
% https://api.tiles.mapbox.com/v3/dnomadb.ArcToMapbox/page.html, preferably
% fully zoomed in

clear all
close all
clc

% Image processing and flattening
% Gets clicks defining where agents are
% Turns the image into a csv for program processing
obstacle_map1 = imread('SF_southofmarket.png');
%obstacle_map = imread('newmap.png');
obstacle_map = obstacle_map1(:,:,1); % Just take first element (good enough for height map)
obstacle_map = im2double(obstacle_map); % Scales automatically [0,1]
obstacle_map = obstacle_map./(max(max(obstacle_map)));
obstacle_map = obstacle_map.*255;
obstacle_map = uint8(obstacle_map);

obstacle_map = imfill(obstacle_map);

figure(1)
imshow(obstacle_map1)

[mapx,mapy] = getpts(1);
agent_map = [mapx,mapy];
%agent_map = ginput(n_agents);
    

% Export obstacle and agent map
csvwrite('obstacle_map.csv',obstacle_map);
csvwrite('agent_map.csv',agent_map);


%% START FROM HERE IF YOU DON'T WANT TO RE-PICK POINTS

clear all
close all
clc

load('obstacle_map.csv');
load('agent_map.csv');

% Make a membership map
agent_map = int32(agent_map);

% make a vector of points
allpts = zeros(size(obstacle_map(:),1),2);
ptcount = 1;
for i=1:size(obstacle_map,1)
   for j=1:size(obstacle_map,2)
       allpts(ptcount,:) = [i,j];
       ptcount = ptcount+1;
   end
end

% find which closest to which agent
dists = zeros(size(allpts,1),size(agent_map,1));
for i=1:size(agent_map,1)
    agentpts = [ones(size(allpts,1),1)*double(agent_map(i,1)),ones(size(allpts,1),1)*double(agent_map(i,2))];
    dxdy = allpts - agentpts;
    dx = dxdy(:,1);
    dy = dxdy(:,2);
    dists(:,i) = hypot(dx,dy);
end

[~,I] = min(dists');
membermap = reshape(I,size(obstacle_map,1),size(obstacle_map,2));
membership = membermap;
membermap = (membermap-min(min(membermap)))/(max(max(membermap))-min(min(membermap)));

csvwrite('membership_map.csv',membership-1);

imshow(membermap)
hold on
scatter(agent_map(:,1),agent_map(:,2));

%% Maybe pick memberships differently here?



%%
% obstacle_map1 = imread('SF_southofmarket.png');
%obstacle_map1 = im2double(obstacle_map)

%B = edge(membermap,'canny');
%B = imdilate(B, ones(2,2));



%imshow(B)


% for i = 1:size(B,1)
%     for j = 1:size(B,2)
%         if obstacle_map1(i,j,1) == 0 & obstacle_map1(i,j,2) == 0 & obstacle_map1(i,j,3) == 0
%             obstacle_map1(i,j,1) = 255;
%             obstacle_map1(i,j,2) = 255;
%             obstacle_map1(i,j,3) = 255;
%         else
%             obstacle_map1(i,j,1) = 0;
%             obstacle_map1(i,j,2) = 0;
%             obstacle_map1(i,j,3) = 0;
%         end
%         if B(i,j) == 1
%             obstacle_map1(i,j, 1) = 255;
%             obstacle_map1(i,j,2) = 0;
%             obstacle_map1(i,j,3) = 0;
%         end
%     end
% end
% imshow(obstacle_map1)
% hold on

%h = imshow(B);
%set(h, 'AlphaData', .8);
% scatter(agent_map(:,1),agent_map(:,2));



%% Color the map for output - still in progress

% obstacle_color = repmat(obstacle_map,[1 1 3]);
% for i=1:size(obstacle_map,1)
%    for j=1:size(obstacle_map,2)
%       if (membermap(i,j)==1)
%           if (obstacle_map(i,j)==0)
%             obstacle_color(i,j,1) = obstacle_map(i,j)+255;
%           else
%               obstacle_color(i,j,:) = 0;
%               obstacle_color(i,j,1) = 235;
%               obstacle_color(i,j,2) = 76;
%               obstacle_color(i,j,3) = 66;
%           end
%       end
%    end
% end
% imshow(obstacle_color)

%% Make a connection map
% now with obstacle checking!

XDIM = size(membership,1);
YDIM = size(membership,2);

% Trace the edges
connections = zeros(size(agent_map,1));
for i=1:size(membership,1)
    for j=1:size(membermap,2)
        % Assume 4 connections will capture everything (no slipping through
        % gaps!)
        mymember = membership(i,j);
        if (i-1>=1 && obstacle_map(i-1,j)~=1 && obstacle_map(i,j)~=1)
            connections(mymember,membership(i-1,j))=1;
            connections(membership(i-1,j),mymember)=1;
            
        end
        if (i+1<=XDIM && obstacle_map(i+1,j)~=1 && obstacle_map(i,j)~=1)
           connections(mymember,membership(i+1,j))=1;
           connections(membership(i+1,j),mymember)=1;
        end
        if (j-1>=1 && obstacle_map(i,j-1)~=1 && obstacle_map(i,j)~=1)
           connections(mymember,membership(i,j-1))=1;
           connections(membership(i,j-1),mymember)=1;
        end
        if (j+1<=YDIM && obstacle_map(i,j+1)~=1 && obstacle_map(i,j)~=1)
           connections(mymember,membership(i,j+1))=1;
           connections(membership(i,j+1),mymember)=1;
        end
    end
end

hold on
%LineSpec('m', 'LineWidth', 4);
gplot(connections,agent_map, 'm')
h=findobj('type','line');
set(h,'linewidth',4)
csvwrite('connections.csv',connections);

%% Create fixes in space

n_fixes = 20;
fixes = [];
for i=1:n_fixes
    xrand = uint32(rand*(XDIM-1)+1);
    yrand = uint32(rand*(YDIM-1)+1);
   while(obstacle_map(xrand,yrand)>0) 
       xrand = uint32(rand*(XDIM-1)+1);
       yrand = uint32(rand*(YDIM-1)+1);
   end
   obstacle_map(xrand,yrand);
   scatter(xrand,yrand);
   
   fixes = [fixes; xrand-1,yrand-1];
end

 
hold on
scatter(fixes(:,1),fixes(:,2),'c*')

%fixes = fixes-1;
csvwrite('fixes.csv',fixes)

%%  

%[x,y] = meshgrid(1,size(obstacle_map,1),1:size(obstacle_map,2));
%combo = [x(:),y(:),obstacle_map(:)];
Path0 = csvread('path-0.csv');

% Plot the paths over the image
figure(1)
imshow(obstacle_map)
for i=1:2:size(Path0,1)
   hold on
   scatter(Path0(i+1,:)+1,Path0(i,:)+1);
end

%%
figure(2)
Path50 = csvread('trace.csv');
imshow(obstacle_map)
for i=1:2:size(Path50,1)
   hold on
   scatter(Path50(i+1,:)+1,Path50(i,:)+1);
end

%%

Path50 = csvread('trace.csv');
startx = [];
starty = [];
for i=1:2:size(Path50,1)
   startx = [startx; Path50(i+1,1)+1];
   starty = [starty; Path50(i,1)+1];
end

starts = [startx starty]


%%

figure(3)
trace50 = csvread('trace.csv');
imshow(obstacle_map)
for i=1:2:size(trace50,1)
   hold on
   scatter(trace50(i+1,:)+1,trace50(i,:)+1);
end


%%

connected = zeros(size(obstacle_map));

%%

x1 = zeros(size(edges,1),1);
y1 = zeros(size(edges,1),1);
%%
for i=1:size(edges,1)
    [xtemp(i) ytemp(i)] = ind2sub(size(obstacle_map),edges(i,1));
end


%%

obst_check = [];
for i=1:size(x1,1)
   obst_check = [obst_check; obstacle_map(x1(i),y1(i))]; 
end

%%

x = [];
y = [];
for i=1:length(freeID)
    [xtemp ytemp] = ind2sub(size(obstacle_map),freeID(i));
    x = [x xtemp];
    y = [y ytemp];
end

obstacle_map = zeros(size(obstacle_map));

for i=1:length(IDX)
   obstacle_map(x(i),y(i)) = IDX(i); 
end

%%

load('obstacle_map.csv')
load('membership_map.csv')

%%

obsts = [];
for i=1:length(agent_map)
    obsts = [obsts obstacle_map(agent_map(i,1),agent_map(i,2))];
end

%% 
for i=-2:14
    i
   imshow(voronoi_mems==i);
   pause();
end