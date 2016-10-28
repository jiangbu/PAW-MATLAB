classdef PAW < handle
    % PAW class implements accruate optical phase measurement
    % reconstruction. Refer to:
    % https://www.osapublishing.org/ol/abstract.cfm?uri=ol-37-19-4062
    % for the PAW theory and experiment.
    % 
    % The phase reconstruction is carried out in four steps as follows.
    % 
    % step 1: Create a PAW class object.
    % USAGE: PawObj = PAW(systemParameters);
    % systemParameters is a struct to pass the system physical parameters.
    % use the 'computeDevice' entry to choose between CPU and GPU
    % computation.
    %
    % step 2: Update the camera raw image and register to four quadrants.
    % USAGE: PawObj.computeQuads(ImgRaw); 
    % ImgRaw is the most recent accquired camera raw image.
    % 
    % step 3: Compute the tilt images along x and y direction.
    % USAGE: PawObj.computeTilt();
    %
    % step 4: Compute the height(equivalente to phase) image.
    % USAGE: PawObj.computeHeight(method);
    % method is 'Fourier' or 'Tikhonov', corresponding to two different
    % integration methods.
    %
    % Written by Jiang Li, based upon previous codes of our lab:
    % http://biomicroscopy.bu.edu/
    
    
    properties (Hidden, SetAccess = private)
        % physical parameters of the system
        NAi;        % illumination NA
        NAd;        % detection NA
        wavelength; % wavelength, in meter
        pixelSize;  % camera pixel size, in meter
        totalMagnification; % total magnification
        
        % registeration parameters
        ImgDark;    % dark image to be substracted to take off dark noise
        ImgBlank;   % blank reference image to be divided to blance global tilt
        cropVals;   % coordinates to cut out four quadrant sub-images
        shiftVals;  % registeration values for four quads
        ImgSize;    % size of the final output images
        
        TransferFunX; % transfer function of tiltx
        TransferFunY; % transfer function of tilty
        FourierIntegrationCore; % Fourier integration core
        
        computeDevice % use 'CPU' or 'GPU' device to do the computation
    end
    
    properties
        ImgQuads = []; % four quadrant sub-images
        ImgRaw;     % raw input image
        ImgSum;     % sum of four quads, reprensenting intensity image        
        ImgHeight;	% height image for reflecting illumination
        ImgTiltX;	% image of tilt along x direction
        ImgTiltY;	% image of tilt along y direction
    end
    
    methods
        % class constructor
        function self = PAW(systemParameters)
            % systemParameters, struct contains physical parameters of the system
            self.NAi = systemParameters.NAi;
            self.NAd = systemParameters.NAd;
            self.wavelength = systemParameters.wavelength;
            self.totalMagnification = systemParameters.totalMagnification;
            self.pixelSize = systemParameters.pixelSize;
            self.computeDevice = systemParameters.computeDevice;
            
            % load registration values
            self.ImgDark = single(imread('.\calib_images\dark.tif'));
            self.ImgBlank = single(imread('.\calib_images\blank.tif'));
            self.cropVals = load('.\calib_files\cropVals.mat');
            self.shiftVals = load('.\calib_files\registerVals.mat');
            
            self.ImgQuads = zeros(self.cropVals.rect1(4), self.cropVals.rect1(3), 4, 'single');
            
            % compute transfer function of tilt
            [self.TransferFunX, self.TransferFunY] =computeTransFun(self);
            
            % use CUDA for GPU computation
            switch self.computeDevice
                case 'CPU'

                case 'GPU'
                    self.ImgDark = gpuArray(self.ImgDark);
                    self.ImgBlank = gpuArray(self.ImgBlank);
                    self.ImgQuads = gpuArray(self.ImgQuads);
                    self.TransferFunX = gpuArray(self.TransferFunX);
                    self.TransferFunY = gpuArray(self.TransferFunY);
                    self.FourierIntegrationCore = gpuArray(self.FourierIntegrationCore);
                    
                otherwise
                    error('Unexpected computeDevice name. Use CPU or GPU');
            end
            
        end
        
        computeQuads(self, ImgRaw);
        computeTilt(self);
        computeHeight(self, method);        
    end
    
    methods (Hidden)
        [Hx, Hy] = computeTransFun(self);
    end
end