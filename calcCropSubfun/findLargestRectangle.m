function rect = findLargestRectangle(img)
% finds the inscribed rectangle with largest size for a given binary image.
% Algorithm Source:  
% http://www.imagingshop.com/articles/automatic-cropping-non-rectangular-images
% img = input binary image
% rect = [x, y, w, h] of largest square, (x,y) = top left coordinate,
% w h, width and height of the inscribed rectangle.
% Time Complexity: O(m*n)

%% make sure the input is a binary image
if ~islogical(img)
    error('Not a valid binary image.  Check test file for proper usage.');
end

%% find largest squares
[r, c] = size(img);
squares = zeros(r, c);
squares(end,:) = img(end,:);    % copy bottom row
squares(:,end) = img(:,end);    % copy rightmost column

for row = (r-1):-1:1
    for col = (c-1):-1:1
        % largest square that can be drawn from the given pixel is bounded
        % by the minimum of its three southeast neighbors
        if img(row,col)
            squares(row,col) = min([squares(row+1,col), squares(row,col+1), squares(row+1,col+1)]) + 1;            
        end
    end
end

%% find largest rectangles with width >= height
maxSquare = max(squares(:));

widths = zeros(r,c);
heights = zeros(r, c);
sizes = squares.^2;

for row = 1:r
    height2width = zeros(1, maxSquare + 1);
    for col = c:-1:1
        square = squares(row, col);
        if square > 0
            maxSize = sizes(row, col);
            for rectHeight = square:-1:1
                rectWidth = height2width(rectHeight+1);
                rectWidth = max(rectWidth+1, square);
                height2width(rectHeight+1) = rectWidth;
                
                S = rectHeight * rectWidth;
                if S >= maxSize
                    maxSize = S;
                    widths(row, col) = rectWidth;
                    heights(row, col) = rectHeight;
                end
            end
            sizes(row, col) = maxSize;
        end
        
        for s = square : maxSquare
            % widths larger that 'square' will not be available
            height2width(s+1) = 0;
        end
    end
end

%% find largest rectangle with width < height
for col = 1:c
    width2height = zeros(1, maxSquare + 1);
    for row = r:-1:1
        square = squares(row, col);
        if square > 0
            maxSize = sizes(row, col);
            for rectWidth = square:-1:1
                rectHeight = width2height(rectWidth+1);
                rectHeight = max(rectHeight+1, square);
                width2height(rectWidth+1) = rectHeight;
                
                S = rectHeight *  rectWidth;
                if S >= maxSize
                    maxSize = S;
                    widths(row, col) = rectWidth;
                    heights(row, col) = rectHeight;
                end
            end
            sizes(row, col) = maxSize;
        end
        
        for s = square : maxSquare
            % widths larger that 'square' will not be available
            width2height(s+1) = 0;
        end
    end
end

%% find the largest rectangle
maxSize = 0;
rectWidth = 0;
rectHeight = 0;
 
rectRow = 0;
rectCol = 0;
 
for row = 1:r
    for col = 1:c
        S = sizes(row, col); 
        if (S > maxSize)       
            maxSize = S;
            rectRow = row;
            rectCol = col;
            rectWidth = widths(row, col);
            rectHeight = heights(row, col);
        end
    end
end

rect = [rectCol rectRow rectWidth rectHeight];