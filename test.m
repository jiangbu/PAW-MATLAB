i = 1;
while i
ImgRaw = getsnapshot(vid);
PawObj.computeQuads(ImgRaw);        % update the raw image to class object
PawObj.computeTilt();               % compute tilt image
PawObj.computeHeight('Tikhonov');   % compute height image, use 'Fourier' or 'Tikhonov' method
% PawObj.computeHeight('Fourier'); 
if i == 1
    figure; h = imshow(PawObj.ImgHeight,); 
else
    h.Cdata = PawObj.ImgHeight;
end
drawnow;

i = i+1;
end