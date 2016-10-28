function computeTilt(self)
% COMPUTETILT computes the tilt images along x and y directions.
% Assumed Quadrant Ordering:
% |3|4|
% |2|1|
%
% Note: Tilt images are always computed with a -NAi term in front.
% Multiply resulting tilt images by -1 again for Reflection PAW.

self.ImgTiltX = -self.NAi*((self.ImgQuads(:,:,1)+self.ImgQuads(:,:,4)...
    -self.ImgQuads(:,:,2)-self.ImgQuads(:,:,3))./self.ImgSum);
self.ImgTiltY = -self.NAi*((self.ImgQuads(:,:,1)+self.ImgQuads(:,:,2)...
    -self.ImgQuads(:,:,3)-self.ImgQuads(:,:,4))./self.ImgSum);

% eliminate the mundane DC term
self.ImgTiltX = self.ImgTiltX - mean2(self.ImgTiltX);
self.ImgTiltY = self.ImgTiltY - mean2(self.ImgTiltY);
end

