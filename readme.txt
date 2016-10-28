PAW (Partioned Aperture Wavefront imaging)
==========================================

The package provides MATLAB functions that accruately and efficiently
reconstructs phase image of PAW measurements. 
Refer to:
http://biomicroscopy.bu.edu/research/partioned-aperture-wavefront-imaging
https://www.osapublishing.org/ol/abstract.cfm?uri=ol-37-19-4062
https://www.osapublishing.org/josaa/abstract.cfm?uri=josaa-32-11-2123
for detailed information about this technique. 

Usage:
-------------------
- Registeritation

Before doing the phase reconstruction, an image registeritation needs to be 
done once.

Registeritation images are placed in folder 'calib_images\'. Three images are 
required. They are: 'dark.tif' for deduction of dark noise, 'blank.tif' for 
finding the coordinates of four quadrants, and 'chart.tif' for computing the 
relative shiftting of the four quadrants.

Run:
    calcCropVals('square');
    calcRegisterVals();
consecutively. Function calcCropVals() can take 'square' or 'rectangle' as 
input value.

Note that inside of function calcCropVals(), two subfunctions are called, 
which are 'findLargestRectangle_mex' and 'findLargestSquare_mex'. They are 
prebuilt mex files from script function 'findLargestRectangle.m' and
'findLargestSquare.m'. Matlab mex files are generally not backward compatible. 
My system info: Windows 7 sp1, MATLAB R2014b x64, VS 2013 compiler.
If your system is not compatible, consider building your own mex file or 
simply using their corresponding script m functions (much slower).

-------------------
- Phase reconstruction
The phase reconstruction is carried out in four steps as follows.

step 1: Create a PAW class object.
    USAGE: PawObj = PAW(systemParameters);
systemParameters is a struct to pass the system physical parameters.
Use the 'computeDevice' entry to choose between 'CPU' and 'GPU'
computation.

step 2: Update the camera raw image and register to four quadrants.
    USAGE: PawObj.computeQuads(ImgRaw);
ImgRaw is the accquired camera raw image.

step 3: Compute the tilt images along x and y direction.
USAGE: PawObj.computeTilt();

step 4: Compute the height(equivalente to phase) image.
    USAGE: PawObj.computeHeight(method);
method is 'Fourier' or 'Tikhonov', corresponding to two different
integration methods. The result of 'Tikhonov' method is potentially better
than that of the 'Fourier' method, however it is also more susceptible to 
the input of physical system parameters , which means it can fail if the 
parameters are too absurd.

-------------------
Written by Jiang Li, based upon previous codes of our lab:
http://biomicroscopy.bu.edu/
3/20/2016
