function computeHeight(self, method)
% COMPUTEHEIGHT compute the height(equivalente to phase) image.
% method is 'Fourier' or 'Tikhonov', corresponding to two different
% integration methods.

Nr = self.cropVals.rect1(4);
Nc = self.cropVals.rect1(3);
padr = round(Nr/5);
padc = round(Nc/5);

tx = padarray(self.ImgTiltX, [padr, padc], 'both');
ty = padarray(self.ImgTiltY, [padr, padc], 'both');

switch method
    case 'Tikhonov'
        % Tikhonov deconvolution method
        Hx = self.TransferFunX;
        Hy = self.TransferFunY;
        
        alpha = 0.0001;
        
        height = -real(ifft2( (fft2(tx).*conj(Hx) + fft2(ty).*conj(Hy))./((abs(Hx).^2 + abs(Hy).^2)+alpha)));
        height = height(1 + padr : padr + Nr, 1 + padc : padc + Nc);
        self.ImgHeight = self.pixelSize / self.totalMagnification / 4 * height;
        
    case 'Fourier'
        % Fourier integration method
        G_xy = tx + 1i * ty;
        height = ifft2(fft2(G_xy) .* self.FourierIntegrationCore);
        height = self.pixelSize / self.totalMagnification * imag(height);
        height = height(1 + padr : padr + Nr, 1 + padc : padc + Nc);
        self.ImgHeight = -0.5 * height;

    otherwise
        warning('Unexpected computeHeight method. No height computed');
end

end

