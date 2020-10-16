%  Author: Maria Botero
%  version: 1
%  (c)2017

clear all;
close all;
clc;

%% What is this code for?
%Makes individual plots of fringes and includes the tortuosity value
%different samples

%% DEFINITIONS

% Define folders
folder='';
Description='';
locFolder = '.\60% Flame\60Flame-10mmHAB-0.2X-Exp60\';
outputFolder='..\_Summary-Images\Tortuosity\';
File= 'A8-19_1_fringes.mat';
image= imread([locFolder,'A8-19.tif']);
imshow(image)
load([locFolder,File])
coords=fringes.coordinates;

figure
% blank=255*ones(size(image));
% imshow(blank)
% hold on
for i=1:numel(coords);
coor=coords(i).XY;
plot(coor(:,2),coor(:,1),'k')
text(0.03, 0.95, ['Tortuosity=',num2str(fringes.tortuosity(i))], 'units', 'normalized', 'HorizontalAlignment', 'left','FontWeight','bold')
set(gca, 'xlim', [min(coor(:,2))-2, max(coor(:,2))+2])
set(gca, 'ylim', [min(coor(:,1))-2, max(coor(:,1))+2])
set(gca, 'xtick', (min(coor(:,2))-2:1:max(coor(:,2))+2))
set(gca, 'ytick', (min(coor(:,1))-2:1:max(coor(:,1))+2))
axis('equal')
hold off
export_fig([outputFolder,num2str(fringes.tortuosity(i),'%2.4f'),'.png'],'-transparent')
end



