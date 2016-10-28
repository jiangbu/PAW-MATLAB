function [] = calcRegisterVals()
% CALCREGISTERVALS computes the relative shift between four quadrants

% load blank image
ImgBlank = double(imread('.\calib_images\blank.tif'));
ImgDark = double(imread('.\calib_images\dark.tif'));
% load registration images
ImgChart = double(imread('.\calib_images\chart.tif'));
ImgChart = max(ImgChart - ImgDark, 0.1) ./ max(ImgBlank - ImgDark, 0.1);
ImgChart = ImgChart / mean2(ImgChart);
% find pixel shift values
% load precomputed crop values
% rect1, rect2, rect3, rect4, rect5
load(fullfile('calib_files','cropVals.mat'));

ImgQuad = zeros(rect1(4), rect1(3), 4);

% crop input image into quadrants
ImgQuad(:,:,1) = imcrop_improved(ImgChart, rect1);
ImgQuad(:,:,2) = imcrop_improved(ImgChart, rect2);
ImgQuad(:,:,3) = imcrop_improved(ImgChart, rect3);
ImgQuad(:,:,4) = imcrop_improved(ImgChart, rect4);

maxS2 = dftregistration(ImgQuad(:,:,1), ImgQuad(:,:,2));
maxS3 = dftregistration(ImgQuad(:,:,1), ImgQuad(:,:,3));
maxS4 = dftregistration(ImgQuad(:,:,1), ImgQuad(:,:,4));

rowOffset = [0, maxS2(1), maxS3(1), maxS4(1)];
colOffset = [0, maxS2(2), maxS3(2), maxS4(2)];

% save to mat file
save(fullfile('calib_files','registerVals.mat'), 'rowOffset', 'colOffset');

% save to txt file
fid = fopen('./calib_files/registerVals.txt','w');
fprintf(fid,'%f %f %f %f\r\n',rowOffset);
fprintf(fid,'%f %f %f %f\r\n',colOffset);
fclose(fid);

%% DEBUG plot the cropped regions to verify coordinates are correct
quad1 = imcrop(ImgChart, rect1);
quad1 = double(circshift(quad1, [rowOffset(1), colOffset(1)]));

quad2 = imcrop(ImgChart, rect2);
quad2 = double(circshift(quad2, [rowOffset(2), colOffset(2)]));

quad3 = imcrop(ImgChart, rect3);
quad3 = double(circshift(quad3, [rowOffset(3), colOffset(3)]));

quad4 = imcrop(ImgChart, rect4);
quad4 = double(circshift(quad4, [rowOffset(4), colOffset(4)]));

figure; 
subplot(2,2,1); imshowpair(quad1,quad1);
subplot(2,2,2); imshowpair(quad1,quad2);
subplot(2,2,3); imshowpair(quad1,quad3);
subplot(2,2,4); imshowpair(quad1,quad4);

ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 1,'\bf Registeritation Alignment','HorizontalAlignment','center','VerticalAlignment', 'top');

end
function retImg = imcrop_improved( img, rect )
%IMAGECROP performs a pixel precise image crop, unlike the default imcrop
retImg = imcrop(img, rect);
% cutoff the extra pixels.
retImg = retImg(1:end-1,1:end-1);
end

function shiftVal = dftregistration(ImgReference, ImgShift)
% ImgReference and ImgShift have the same size
shiftVal = zeros(1,2);

tmp1 = fftshift(fft2(ImgReference));
tmp2 = fftshift(fft2(ImgShift));
tmp3 = tmp1 .* conj(tmp2);

CC = abs(ifftshift(ifft2(tmp3)));
[shiftM, shiftN] = find(CC == max(CC(:)));

[m, n] = size(ImgReference);
midM = fix(m/2);
midN = fix(n/2);
shiftVal(1) = shiftM - midM - 1;
shiftVal(2) = shiftN - midN - 1;

end
