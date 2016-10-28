function rect = findLargestSquare(img)
% finds the largest inscribed square for a given binary image.
% Algorithm Source:  
% http://www.imagingshop.com/articles/automatic-cropping-non-rectangular-images
% img = input binary image
% rect = [x, y, w, h] of largest square, (x,y) = top left coordinate,
% w = h = width and height of the inscribed square.
% Time Complexity: O(m*n)

%% make sure the input is a binary image
if ~islogical(img)
    error('Not a valid binary image.  Check test file for proper usage.');
end

%% Initialize starting values for algorithm along the border
[r,c] = size(img);
mat = zeros(r,c);           % matrix to store auxiliary values
mat(end,:) = img(end,:);    % copy bottom row
mat(:,end) = img(:,end);    % copy rightmost column
maxR = 1; maxC = 1; maxVal = 1;     % store location and value of max size

for row = (r-1):-1:1
    for col = (c-1):-1:1
        % largest square that can be drawn from the given pixel is bounded
        % by the minimum of its three southeast neighbors
        if img(row,col)
            mat(row,col) = min([mat(row+1,col), mat(row,col+1), mat(row+1,col+1)]) + 1;
            % keep track of the largest box
            if mat(row,col) > maxVal
                maxR = row;
                maxC = col;
                maxVal = mat(row,col);
            end
        end
    end
end

rect = [maxC maxR maxVal maxVal];

end

