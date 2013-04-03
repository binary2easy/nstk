
#include <mexExport.h>
#include <tmwtypes.h>

#include <irtkImage.h>
#include <irtkFileToImage.h>

#include <irtkRegionFilter.h>

#include <irtkTransformation.h>

#include <irtkResampling.h>

#include <limits>
using namespace std;

// Hack to see if the following typdefs have or have not been
// made.  Matlab versions >7.3 do the typedef and define the
// following preproc. definition.  If it is not defined, we need
// to do a typedef.

#ifndef MWSIZE_MAX
typedef int mwIndex;
typedef int mwSize;
#endif

char *modeName = NULL;
enum {modeDispX, modeDispY, modeDispMag, modeDeformedSource};


void usage(){
  cout << "" << endl;
  cout << "xxx" << endl;
  cout << "" << endl;
  cout << "" << endl;
  cout << "" << endl;
  cout << "" << endl;
  cout << "" << endl;

  cout << endl;
  return;
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{

  int i, j, ind, mode;
  int vectorNamesGiven = 0;
  double pt[3];
  double x, y, z, x1, x2, y1, y2, z1, z2, dx, dy, dz;
  int xdim, ydim;


  /* Check for proper number of arguments */
  if (nrhs < 4){
    usage();
    mexErrMsgTxt("Minimum 3 input argument required.");
  }


  if (mxGetNumberOfDimensions(prhs[0]) != 2 ||
      mxGetNumberOfDimensions(prhs[1]) != 2 ||
      mxGetNumberOfDimensions(prhs[2]) != 2){
    usage();
    mexErrMsgTxt("XXXX arrays must be two dimensional.");
  }

  if (! mxIsClass(prhs[0], "double") ||
      ! mxIsClass(prhs[1], "double") ||
      ! mxIsClass(prhs[2], "double") ||
      ! mxIsClass(prhs[3], "char")){
    usage();
    mexErrMsgTxt("XXXX arrays must be double.");
  }

  const mwSize *imageDims = mxGetDimensions(prhs[0]);

  const mwSize *gridDims = mxGetDimensions(prhs[1]);
  const mwSize *gridDims2 = mxGetDimensions(prhs[2]);

  if (gridDims2[0] != gridDims[0] || gridDims2[1] != gridDims[1]){
    usage();
    mexErrMsgTxt("Dimension mismatch in dispX and dispY.");
  }

  if (gridDims[0] < 1 || gridDims[1] < 1){
    usage();
    mexErrMsgTxt("Displacement grid dimensions must be positive.");
  }


  xdim = imageDims[1];
  ydim = imageDims[0];

  modeName = mxArrayToString(prhs[3]);

  if (strcmp(modeName, "xDisp") == 0){
    mode = modeDispX;
  } else if (strcmp(modeName, "yDisp") == 0){
    mode = modeDispY;
  } else if (strcmp(modeName, "magDisp") == 0){
    mode = modeDispMag;
  } else if (strcmp(modeName, "deformedSource") == 0){
    mode = modeDeformedSource;
  } else {
    usage();
    cerr << modeName << " : ";
    mexErrMsgTxt("Invalid mode type.");
  }
//  cout << "Mode to be used : " << modeName << endl;



  // Get the data;
  double *imageData = static_cast<double*>(mxGetData(prhs[0]));


  mwIndex sub[2];

  irtkImageAttributes attr;
  attr._x = xdim;
  attr._y = ydim;
  attr._z = 1;
  attr._dx = attr._dy = attr._dz = 1;

  irtkRealImage irtkImg(attr);

//  cout << "Image has " <<  irtkImg.GetNumberOfVoxels() << " voxels" << endl;
//  cout << "Image has " <<  irtkImg.GetX() << " x " << irtkImg.GetY() <<  " voxels" << endl;


  int nVoxels = xdim * ydim;
  for (i = 0; i < xdim; ++i){
    sub[1] = i;
    for (j = 0; j < ydim; ++j){
      sub[0] = j;
      ind = mxCalcSingleSubscript(prhs[0], 2, sub);
      irtkImg.Put(i, j, 0, imageData[ind]);
    }
  }

  double *dispDataX = static_cast<double*>(mxGetData(prhs[1]));
  double *dispDataY = static_cast<double*>(mxGetData(prhs[2]));

//  x1 = y1 = z1 = 0.0f;
//  x2 = irtkImg.GetX() - 1;
//  y2 = irtkImg.GetY() - 1;
//  z2 = 0;
//  irtkImg.ImageToWorld(x1, y1, z1);
//  irtkImg.ImageToWorld(x2, y2, z2);
//  dx = (x2 - x1 + 1) / ((double) gridDims[1] - 1);
//  dy = (y2 - y1 + 1) / ((double) gridDims[0] - 1);
//  dz = 1;

  x1 = y1 = z1 = 0.0f;
  x2 = irtkImg.GetX() - 1;
  y2 = irtkImg.GetY() - 1;
  z2 = 0;
  irtkImg.ImageToWorld(x1, y1, z1);
  irtkImg.ImageToWorld(x2, y2, z2);
  dx = (x2 - x1 + 1) / ((double) gridDims[1] - 1);
  dy = (y2 - y1 + 1) / ((double) gridDims[0] - 1);
  dz = 1;


  irtkBSplineFreeFormTransformation transf(x1, y1, z1, x2, y2, z2, dx, dy, dz,
      attr._xaxis, attr._yaxis, attr._zaxis);


  ////////////////////////////////////////////////////////////////////////////////
//  transf.Print();
//
//  x1 = y1 = z1 = 0;
//  transf.LatticeToWorld(x1, y1, z1);
//  cout << " === " << x1 << " " << y1 << " " << z1 << endl;
//
//  x1 = gridDims[1] - 1;
//  y1 = gridDims[0] - 1;
//  z1 = 0;
//  transf.LatticeToWorld(x1, y1, z1);
//  cout << " --- " << x1 << " " << y1 << " " << z1 << endl;
  ////////////////////////////////////////////////////////////////////////////////

  // Read in control point data.
  int count = 0;

  for (i = 0; i < gridDims[1]; ++i){
    for (j = 0; j < gridDims[0]; ++j){
      transf.Put(i, gridDims[0] - 1 - j, 0, dispDataX[count], -1 * dispDataY[count], 0.0);
      ++count;
    }
  }


  irtkMultiLevelFreeFormTransformation *mffd = new irtkMultiLevelFreeFormTransformation;
  mffd->PushLocalTransformation(&transf);

  plhs[0] = mxCreateDoubleMatrix(ydim, xdim, mxREAL);
  double *outPtr = mxGetPr(plhs[0]);

  irtkRealImage img2 = irtkImg;

  irtkImageFunction *interpolator = new irtkLinearInterpolateImageFunction;
  // Create image transformation
  irtkImageTransformation *imagetransformation =
    new irtkImageTransformation;

  switch (mode){
  case modeDeformedSource:
//    cout << "Calculating deformed source" << endl;


    imagetransformation->SetInput (&irtkImg, mffd);
    imagetransformation->SetOutput(&img2);
    imagetransformation->PutInterpolator(interpolator);

    // Transform image
    imagetransformation->Run();

    for (i = 0; i < xdim; ++i){
      sub[1] = i;
      for (j = 0; j < ydim; ++j){
        sub[0] = j;
        ind = mxCalcSingleSubscript(plhs[0], 2, sub);
        outPtr[ind] = img2.Get(i, j, 0);
      }
    }

//    img2.Write("bla.nii.gz");


    break;

  case modeDispX:

    for (i = 0; i < xdim; ++i){
      sub[1] = i;
      for (j = 0; j < ydim; ++j){
        x = i;
        y = j;
        z = 0;
        irtkImg.ImageToWorld(x, y, z);
        transf.Displacement(x, y, z);

        sub[0] = j;
        ind = mxCalcSingleSubscript(plhs[0], 2, sub);
        outPtr[ind] = x;
      }
    }

    break;

  case modeDispY:

    for (i = 0; i < xdim; ++i){
      sub[1] = i;
      for (j = 0; j < ydim; ++j){
        x = i;
        y = j;
        z = 0;
        irtkImg.ImageToWorld(x, y, z);
        transf.Displacement(x, y, z);

        sub[0] = j;
        ind = mxCalcSingleSubscript(plhs[0], 2, sub);
        outPtr[ind] = y;
      }
    }

    break;

  case modeDispMag:

    for (i = 0; i < xdim; ++i){
      sub[1] = i;
      for (j = 0; j < ydim; ++j){
        x = i;
        y = j;
        z = 0;
        irtkImg.ImageToWorld(x, y, z);
        transf.Displacement(x, y, z);

        sub[0] = j;
        ind = mxCalcSingleSubscript(plhs[0], 2, sub);
        outPtr[ind] = sqrt(x*x + y*y);
      }
    }

    break;

  default:
    cerr << mode << " : ";
    mexErrMsgTxt("Invalid mode value");
    break;
  }



  ////////////////////////////////////////////////////////////////////////////////
//  mffd->irtkTransformation::Write("bla.dof");
//
//  irtkImg.Write("bla1.nii.gz");
//  img2.Write("bla2.nii.gz");
  ////////////////////////////////////////////////////////////////////////////////


  
  return;

}
