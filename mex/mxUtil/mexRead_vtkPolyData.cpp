
#include <mexExport.h>

#include <vtkFloatArray.h>
#include <vtkCellArray.h>
#include <vtkPointData.h>
#include <vtkPolyData.h>
#include <vtkPolyDataReader.h>

// #include <irtkImage.h>


// #include <mxUtil.h>
// #include <mxVTK.h>

// Defines needed if matlab version < 7.3

// Hack to see if the following typdefs have or have not been
// made.  Matlab versions >7.3 do the typedef and define the
// following preproc. definition.  If it is not defined, we need
// to do a typedef.

#ifndef MWSIZE_MAX
typedef int mwIndex;
typedef int mwSize;
#endif

char *input_name = NULL;

void copyFaces(vtkCellArray *src, vtkCellArray *dest){
  int i, j, noOfCells;
  vtkIdType npts = 0;
  vtkIdType *ptIds;
  noOfCells = src->GetNumberOfCells();
  dest->SetNumberOfCells(noOfCells);

  int estSize;
  int maxPts;
  maxPts = src->GetMaxCellSize();

  dest->Initialize();
  estSize = dest->EstimateSize(noOfCells, maxPts);
  dest->Allocate(estSize, 0);
  dest->Reset();

  dest->InitTraversal();
  src->InitTraversal();
  for (i = 0; i < noOfCells; ++i){
    src->GetNextCell(npts, ptIds);
    dest->InsertNextCell(npts);
    for (j = 0; j < npts; ++j){
      dest->InsertCellPoint(ptIds[j]);
    }
    dest->UpdateCellCount(npts);
  }
  dest->Squeeze();
}
void usage(){
  cout << " Usage: " << endl;
  cout << "    [V, F, S] = Read_vtkPolyData(FILE)" << endl;
  cout << "    [V, F, S, Snames] = Read_vtkPolyData(FILE)" << endl;
  cout << "      V = vertices." << endl;
  cout << "      F = faces" << endl;
  cout << "      S = scalars" << endl;
  cout << "    Snames: Optional output argument, names of scalars" << endl;
  cout << "    Currently only single component scalars are read." << endl;
  cout << "    Vector valued per-vertex features not possible." << endl;
  cout << endl;
  
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{

  int i, j, ind;
  int scalarNamesRequired = 0;
  
  double pt[3];
  vtkIdType npts = 0;
  vtkIdType *ptIds;
  
  /* Check for proper number of arguments */
  if (nrhs != 1){
    usage();
    mexErrMsgTxt("One input argument required.");
  }

  if (nlhs < 3){
    usage();
    mexErrMsgTxt("Three or four output arguments required.");
  }

  if (nlhs == 4)
    scalarNamesRequired = 1;


  input_name =  mxArrayToString(prhs[0]);
  cout << "Input: " << input_name << endl;
  cout << "No. of args : " << nlhs << " " << nrhs << endl;
  
  vtkPolyData *polydata = vtkPolyData::New();
  vtkPolyDataReader *reader = vtkPolyDataReader::New();
  
  reader->SetFileName(input_name);
  reader->Modified();
  reader->Update();
  polydata = reader->GetOutput();
  polydata->Update();
  
  vtkCellArray* faces = vtkCellArray::New();
  copyFaces(polydata->GetPolys(), faces);
  
  int noOfScalarArrays = 0;
  
  for (i = 0; i < polydata->GetPointData()->GetNumberOfArrays(); i++ ){
    vtkFloatArray *scalars = (vtkFloatArray*) polydata->GetPointData()->GetArray(i);
    
    if (scalars->GetNumberOfComponents() != 1){
      continue;
    }
    noOfScalarArrays++;
  }
  
  // Output arguments.
  
  // Array with 3 x no of points for vertex locations. 
  mwSize *vdims = new mwSize[2];
  vdims[0] = 3;
  vdims[1] = polydata->GetNumberOfPoints();

  plhs[0] = mxCreateNumericArray(2, vdims, mxSINGLE_CLASS, mxREAL);
  float* vertices = static_cast<float*>(mxGetData(plhs[0]));

  // Array with 3 rows to represent triangular faces.
  mwSize *fdims = new mwSize[2];
  fdims[0] = 3;
  fdims[1] = faces->GetNumberOfCells();

  plhs[1] = mxCreateNumericArray(2, fdims, mxUINT32_CLASS, mxREAL);
  int *facesOut = static_cast<int*>(mxGetData(plhs[1]));
  
  // Array with a row per set of scalars.
  mwSize *sdims = new mwSize[2];
  sdims[0] = noOfScalarArrays;
  
  if (noOfScalarArrays > 0)
    sdims[1] = polydata->GetNumberOfPoints();
  else
    sdims[1] = 0;
  
  plhs[2] = mxCreateNumericArray(2, sdims, mxSINGLE_CLASS, mxREAL);
  float *scalarsOut = static_cast<float*>(mxGetData(plhs[2]));



  cout << "No of points        : " << polydata->GetNumberOfPoints() << endl;
  cout << "No of faces         : " << faces->GetNumberOfCells() << endl;
  cout << "No of scalar arrays : " << noOfScalarArrays << endl;
  
  mwIndex sub[2];
  
  // Vertices:
  
  for (i = 0; i < polydata->GetNumberOfPoints(); i++){
    sub[1] = i;

    polydata->GetPoint(i, pt);

    for (j = 0; j < 3; ++j){
      sub[0] = j;
      ind = mxCalcSingleSubscript(plhs[0], 2, sub);
      vertices[ind] = pt[j];
    }
  }
  
  // Faces:
  
  faces->InitTraversal();
  for (i = 0; i < faces->GetNumberOfCells(); ++i){
    sub[1] = i;
    faces->GetNextCell(npts, ptIds);
    
    if (npts != 3){
      cerr << "Only implemented for triangle surfaces." << endl;
      exit(1);
    }
    
    for (j = 0; j < npts; ++j){
      sub[0] = j;
      ind = mxCalcSingleSubscript(plhs[1], 2, sub);
      // One-indexing for matlab
      facesOut[ind] = ptIds[j] + 1;
    }
  }
  
  // Scalars:
  
  int scalarInd = 0;
  
  for (i = 0; i < polydata->GetPointData()->GetNumberOfArrays(); i++ ){
    vtkFloatArray *scalars = (vtkFloatArray*) polydata->GetPointData()->GetArray(i);
    
    if (scalars->GetNumberOfComponents() != 1){
      continue;
    }
    sub[0] = scalarInd;
    scalarInd++;

    for (j = 0; j < scalars->GetNumberOfTuples(); ++j){
      sub[1] = j;
      ind = mxCalcSingleSubscript(plhs[2], 2, sub);
      scalarsOut[ind] = scalars->GetTuple1(j);
    }
  }
  
  if (scalarNamesRequired == 1){
    sdims[0] = noOfScalarArrays;
    sdims[1] = 1;
    plhs[3] = mxCreateCellArray(2, sdims);
    
    scalarInd = 0;
    for (i = 0; i < polydata->GetPointData()->GetNumberOfArrays(); i++){
      vtkFloatArray *scalars = (vtkFloatArray*) polydata->GetPointData()->GetArray(i);
      if (scalars->GetNumberOfComponents() != 1){
        continue;
      }
      
      cout << "Returning scalar name " << 1 + scalarInd << " : " << scalars->GetName() << endl;
      
      mxSetCell(plhs[3], scalarInd, mxCreateString(scalars->GetName()));
      scalarInd++;
    }
  }
  
  
  return;

}





















