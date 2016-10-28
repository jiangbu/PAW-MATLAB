%% an example to demonstrate PAW phase reconstruction
%% load physical system parameters
systemParameters = struct(...
    'wavelength',0.56e-6, ...       % wavelength in meter
    'totalMagnification',10, ...    % Total Magnification
    'NAi', 0.3, ...                 % illumination NA
    'NAd', 1.0, ...                 % detection NA
    'pixelSize',8e-6, ...         % Camera pixel size in meter
    'computeDevice', 'GPU');        % computing device, use 'GPU' or 'CPU'

%% Registeritation, only need to run once
% find largeset 'square' or 'rectangle' crops
% calcCropVals('square');
% calcCropVals('rectangle');

% calculate relative shifts between four quadrants
% calcRegisterVals;

%% Phase reconstruction
PawObj = PAW(systemParameters);     % PAW class object initialization

ImgRaw = imread('./sample_images/LetterM.tif');     % capture raw camera image
% ImgRaw = getsnapshot(vid);

PawObj.computeQuads(ImgRaw);        % update the raw image to class object
PawObj.computeTilt();               % compute tilt image
% PawObj.computeHeight('Tikhonov');   % compute height image, use 'Fourier' or 'Tikhonov' method
PawObj.computeHeight('Fourier'); 

%% Display results
edge_mask = zeros(size(PawObj.ImgHeight));
edge_mask(10:end-10,10:end-10) = 1;
figure; imagesc(PawObj.ImgHeight/1E-6 .* edge_mask ); 
axis image; colorbar; colormap('default'); title('PAW height measurement (um)');
figure;mesh(PawObj.ImgHeight/1E-6);