function computeQuads( self, ImgRaw)
% COMPUTEQUADS register raw img into four quadrants
% Assumed Quadrant Ordering:
% |3|4|
% |2|1|

self.ImgRaw = single(ImgRaw);
if strcmp(self.computeDevice, 'GPU');
    self.ImgRaw = gpuArray(self.ImgRaw);
end
Img = max((self.ImgRaw - self.ImgDark),0.1)./max((self.ImgBlank - self.ImgDark),0.1);

% find the maximum shift value
padRow = ceil(max(abs(self.shiftVals.rowOffset)));
padCol = ceil(max(abs(self.shiftVals.colOffset)));
% add padding to eliminate circular wraparound error
% crop to slightly enlarged quadrants to account for shearing
rect1Pad = padRect(self.cropVals.rect1, padRow, padCol);
rect2Pad = padRect(self.cropVals.rect2, padRow, padCol);
rect3Pad = padRect(self.cropVals.rect3, padRow, padCol);
rect4Pad = padRect(self.cropVals.rect4, padRow, padCol);

switch self.computeDevice
    case 'CPU'
        Quad = zeros(rect1Pad(4)+1, rect1Pad(3)+1, 4, 'single');
    case 'GPU'
        Quad = gpuArray(zeros(rect1Pad(4)+1, rect1Pad(3)+1, 4, 'single'));
    otherwise
        warning('Unexpected computeDevice name. Program terminated');
end

Quad(:,:,1) = imcrop(Img, rect1Pad);
Quad(:,:,2) = imcrop(Img, rect2Pad);
Quad(:,:,3) = imcrop(Img, rect3Pad);
Quad(:,:,4) = imcrop(Img, rect4Pad);

for ii = 1:4
    switch self.computeDevice
        case 'CPU'
            Quad(:,:,ii) = circshift(Quad(:,:,ii), [self.shiftVals.rowOffset(ii), self.shiftVals.colOffset(ii)]);
        case 'GPU'
            Quad(:,:,ii) = gpuShift(Quad(:,:,ii), [self.shiftVals.rowOffset(ii), self.shiftVals.colOffset(ii)]);
        otherwise
            warning('Unexpected computeDevice name. Program terminated');
    end
end

% crop to undo padding and return
self.ImgQuads = Quad(1+padRow:end-padRow-1,1+padCol:end-padCol-1,:);
self.ImgSum = sum(self.ImgQuads, 3);
end

function rectOut = padRect(rectIn, padRow, padCol)
% pads the input rectangular coords with the given parameters
rectOut = [rectIn(1)-padCol, rectIn(2)-padRow, rectIn(3)+2*padCol, rectIn(4)+2*padRow];
end

function N = gpuShift(M, k)
% shift 2D array on GPU
% circshift runs slow on GPU
N = zeros(size(M), 'single', 'gpuArray');
if k(1) >= 0  && k(2) >= 0
    N(k(1)+1:end, k(2)+1:end) = M(1:end-k(1), 1:end-k(2));
elseif k(1) >= 0  && k(2) < 0
    N(k(1)+1:end, 1:end+k(2)) = M(1:end-k(1), 1-k(2):end);
elseif k(1) < 0  && k(2) < 0
    N(1:end+k(1), 1:end+k(2)) = M(1-k(1):end, 1-k(2):end);
elseif k(1) < 0  && k(2) >= 0
    N(1:end+k(1), k(2)+1:end) = M(1-k(1):end, 1:end-k(2));
else
    error('wrong shift values');
end
end