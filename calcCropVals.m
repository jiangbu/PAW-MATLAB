function [] = calcCropVals(shape)
% CALCROPVALS computes the crop values of four largest suqares or
% rectangles.
% shape is 'square' or 'rectangle'.

addpath('./calcCropSubfun/');
%% load image
quadBlank = imread('.\calib_images\blank.tif');
quadDark = imread('.\calib_images\dark.tif');
quadBlank = quadBlank - quadDark;      % subtract dark image
quadBlank = max(quadBlank,0);
quadBlank = imfill(quadBlank);

%% Process Quad Blank Image
% binarize image
quadBin = im2bw(quadBlank, 0.6*graythresh(quadBlank));
% quadBin = imclose(quadBin, strel('disk', 5));
% quadBin(1600:end,1:450) = 1;
% figure;imshow(quadBin,[]);

%% loop through 4 quadrants
rect = zeros(4,4);
for ii = 1:4
    % compute the largest inscribed box
    switch shape
        case 'square'
            rect(ii,:) = findLargestSquare_mex(quadBin);
        case 'rectangle'
            rect(ii,:) = findLargestRectangle_mex(quadBin);
        otherwise
            error('wrong shape parameter, use square or rectangle');
    end  
    
    % zero out those values in preparation for the next iteration
    row = rect(ii,2);
    col = rect(ii,1);
    width = rect(ii,3);
    height = rect(ii, 4);
    quadBin(row:(row+height-1), col:(col+width-1)) = 0;
end

% set the box size to the minimum of the 5 subimages
minWidth = min(rect(:, 3));
minHeight = min(rect(:, 4));
rect(:,3) = minWidth;
rect(:,4) = minHeight;

%% permute the found boxes to match the Quadrant Numbering:
% Captured Quad Image:
% |3|4|
% |2|1|

% compute the centroid of the corner points
centCol = mean(rect(1:4,1));
centRow = mean(rect(1:4,2));

% compare each point to the centroid
for ii = 1:4
    rr = rect(ii,2);
    cc = rect(ii,1);
    if rr < centRow
        if cc < centCol
            rect3 = rect(ii,:);
        else
            rect4 = rect(ii,:);
        end
    else
        if cc < centCol
            rect2 = rect(ii,:);
        else
            rect1 = rect(ii,:);
        end
    end
end

% save crop values to mat file
save(fullfile('calib_files','cropVals.mat'), 'rect1', 'rect2', 'rect3', 'rect4');

% save crop values to txt file
fid = fopen('./calib_files/cropVals.txt','w');
fprintf(fid,'%d %d %d %d\r\n',rect1);
fprintf(fid,'%d %d %d %d\r\n',rect2);
fprintf(fid,'%d %d %d %d\r\n',rect3);
fprintf(fid,'%d %d %d %d\r\n',rect4);
fclose(fid);

%% display results
% Quadrant Image
warningID = 'images:initSize:adjustingMag';
warning('off',warningID);
figure; imshow(quadBlank, []);
warning('on',warningID);
title ('quadrants crop');
% overlay the box
rectangle('Position',rect1, 'EdgeColor','r', 'LineWidth',2);
rectangle('Position',rect2, 'EdgeColor','r', 'LineWidth',2);
rectangle('Position',rect3, 'EdgeColor','r', 'LineWidth',2);
rectangle('Position',rect4, 'EdgeColor','r', 'LineWidth',2);



    