function [ Hx, Hy ] = computeTransFun(self)
% COMPUTETRANSFUN computes the transfer function of tilt images of optical
% system and the Fourier Integration Core.
% refer to Roman's paper:
% https://www.osapublishing.org/josaa/abstract.cfm?uri=josaa-32-11-2123
% for detailed information about the transfer function.

% system resolution evaluated by number of pixels
resInPixel = self.wavelength / (2*self.NAi) * self.totalMagnification / self.pixelSize;

% Prepare the spatial frequency grid
Nr = self.cropVals.rect1(4);
Nc = self.cropVals.rect1(3);
padr = round(Nr/5);
padc = round(Nc/5);
Nr = Nr + 2*padr;
Nc = Nc + 2*padc;

mc = 1/2; % Spatial-frequency cutoff.
kxx = linspace(-mc, mc, Nc);
kyy = linspace(-mc, mc, Nr);

% Ensure that DC position set to zero irrespective of numerical errors.
kxx = kxx - min(abs(kxx));
kyy = kyy - min(abs(kyy));

[kx, ky]=meshgrid(kxx, kyy);

% calculate tilt transfer function
kc = 1 / resInPixel;
beta = self.NAd / self.NAi;
Hx = 2i * gminus(kx/kc, beta) .* gplus(ky/kc, beta);
Hy = 2i * gminus(ky/kc, beta) .* gplus(kx/kc, beta);

Hx = ifftshift(Hx);
Hy = ifftshift(Hy);

% compute Fourier integration core
nrm = sqrt(kx.^2+ky.^2);
spf = zeros(size(nrm));
spf(nrm > 1e-15) = 1./(kx(nrm > 1e-15)+1i*ky(nrm > 1e-15)); % account for singularity
self.FourierIntegrationCore = ifftshift(spf)/(2*pi);
end

function g = gminus(q, beta)
g = zeros(size(q));
tf = (abs(q) >= 0 & abs(q) < 0.5);
g(tf) = q(tf);
tf = (abs(q) >= 0.5 & abs(q) < (beta - 0.5) & q > 0);
g(tf) = 0.5;
tf = (abs(q) >= 0.5 & abs(q) < (beta - 0.5) & q < 0);
g(tf) = -0.5;
tf = (abs(q) >= (beta - 0.5) & abs(q) < beta & q > 0);
g(tf) = beta - q(tf);
tf = (abs(q) >= (beta - 0.5) & abs(q) < beta & q < 0);
g(tf) = -beta - q(tf);
tf = (abs(q) >= beta);
g(tf) = 0;
end

function g = gplus(q, beta)
g = zeros(size(q));

tf = ( abs(q) >= 0 & abs(q) < 0.5 );
g(tf) = 1 - abs(q(tf));
tf = ( abs(q) >= 0.5 & abs(q) < (beta - 0.5));
g(tf) = 0.5;
tf = ( abs(q) >= (beta - 0.5) & abs(q) < beta);
g(tf) = beta - abs(q(tf));
tf = ( abs(q) >= beta);
g(tf) = 0;
end

