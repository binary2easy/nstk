
#include <mexExport.h>
#include <tmwtypes.h>

#include <vtkFloatArray.h>
#include <vtkCellArray.h>
#include <vtkPointData.h>
#include <vtkPolyData.h>
#include <vtkPolyDataWriter.h>
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

char *output_name = NULL;
char *vector_name = NULL;

void usage(){
  mexPrintf("\n   Usage: \n");
  mexPrintf("   Write_vtkPolyData(FILENAME, V, F, S)\n");
  mexPrintf("   Write_vtkPolyData(FILENAME, V, F, S, Snames)\n");
  mexPrintf("   V = vertices.\n");
  mexPrintf("   F = faces\n");
  mexPrintf("   S = scalars\n\n");
  mexPrintf("   Snames : optional argument. Cell array of strings to use as names for scalars\n\n");
  cout << "V must be a 3 x N array where N is the number of vertices." << endl;
  cout << "F must be a K x M array where K is the vertices per face and M is the number of faces." << endl;
  cout << "S must be a L x N array where L is the number of scalars for each vertex." << endl;

  cout << endl;
  return;
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{

  int i, j, ind;
  int scalarNamesGiven = 0;
  double pt[3];
  vtkIdType npts = 0;
  vtkIdType *ptIds;

  /* Check for proper number of arguments */
  if (nrhs < 4){
    usage();
    mexErrMsgTxt("Four or five input argument required.");
  }

  if (nrhs == 5)
    scalarNamesGiven = 1;


  output_name =  mxArrayToString(prhs[0]);
  cout << "Output: " << output_name << endl;



  if (mxGetNumberOfDimensions(prhs[1]) != 2 ||
      mxGetNumberOfDimensions(prhs[2]) != 2 ||
      mxGetNumberOfDimensions(prhs[3]) != 2){
    usage();
    mexErrMsgTxt("V, F and S arrays must be two dimensional.");
  }

  if (! mxIsClass(prhs[1], "single") ||
      ! mxIsClass(prhs[2], "uint32") ||
      ! mxIsClass(prhs[3], "single")  ){
    usage();
    mexErrMsgTxt("V and S must be single arrays and F must be a uint32 (unsigned long) array.");
  }

  const mwSize *vdims = mxGetDimensions(prhs[1]);
  const mwSize *fdims = mxGetDimensions(prhs[2]);
  const mwSize *sdims = mxGetDimensions(prhs[3]);

  if (vdims[0] != 3){
    usage();
    mexErrMsgTxt("V must have dimensions 3 x number of vertices.");
  }

  if (sdims[1] != vdims[1]){
    usage();
    mexErrMsgTxt("V and S must have the same number of columns (= # vertices).");
  }

  cout << "Vertices       : " << vdims[1] << endl;
  cout << "Faces          : " << fdims[1] << endl;
  cout << "No. of scalars : " << sdims[0] << endl;

  int noOfVertices, noOfFaces, noOfScalars;
  int vertsPerFace;


  noOfVertices = vdims[1];
  noOfFaces = fdims[1];
  vertsPerFace = fdims[0];
  noOfScalars = sdims[0];

  // Get the data;

  // Matlab 'single' type
  real32_T* vertexData = static_cast<real32_T*>(mxGetData(prhs[1]));
  // Matlab 'uint32' type
  uint32_T* faceData = static_cast<uint32_T*>(mxGetData(prhs[2]));
  real32_T* scalarData = static_cast<real32_T*>(mxGetData(prhs[3]));

  mwIndex sub[2];

  // Vertices:

  double p[3];

  vtkPoints *points = vtkPoints::New();
  points->SetNumberOfPoints(noOfVertices);

  for (i = 0; i < noOfVertices; ++i){
    sub[1] = i;
    for (j = 0; j < 3; ++j){
      sub[0] = j;
      ind = mxCalcSingleSubscript(prhs[1], 2, sub);
      p[j] = vertexData[ind];
    }

    points->SetPoint(i, p);
  }

  // Faces:

  int estSize;
  vtkIdType ptID = NULL;

  vtkCellArray* faces = vtkCellArray::New();
  faces->SetNumberOfCells(noOfFaces);
  faces->Initialize();
  estSize = faces->EstimateSize(noOfFaces, vertsPerFace);
  faces->Allocate(estSize, 0);
  faces->Reset();
  faces->InitTraversal();

  for (i = 0; i < noOfFaces; ++i){
    sub[1] = i;
    faces->InsertNextCell(vertsPerFace);

    for (j = 0; j < vertsPerFace; ++j){
      sub[0] = j;
      ind = mxCalcSingleSubscript(prhs[2], 2, sub);
      ptID = faceData[ind];
      // Convert from 1-indexing (matlab) to 0-indexing (c++)
      faces->InsertCellPoint(ptID - 1);
    }
    faces->UpdateCellCount(vertsPerFace);
  }
  faces->Squeeze();

  // Scalars:

  int scalarInd;
  char buffer[100];

  vtkFloatArray **scalars = new vtkFloatArray*[noOfScalars];
  for (i = 0; i < noOfScalars; i++){
    scalars[i] = vtkFloatArray::New();
    scalars[i]->SetNumberOfComponents(1);
    scalars[i]->SetNumberOfTuples(noOfVertices);

    sprintf(buffer, "%d", i+1);
    scalars[i]->SetName(buffer);

    sub[0] = i;
    for (j = 0; j < noOfVertices; j++){
      sub[1] = j;
      ind = mxCalcSingleSubscript(prhs[3], 2, sub);
      scalars[i]->SetTuple1(j, scalarData[ind]);
    }
  }

  if (scalarNamesGiven == 1){

    int noOfNames;
    const mxArray *cell_element_ptr;

    if (! mxIsClass(prhs[4], "cell") ){
      usage();
      mexErrMsgTxt("Scalar names must be a cell array of strings.");
    }


    noOfNames = mxGetNumberOfElements(prhs[4]);

    if (noOfNames != noOfScalars){
      usage();
      mexErrMsgTxt("Number of scalar names must match number of scalars.");
    }

    cout << "Assigning given scalar names:" << endl;

    for (i = 0; i < noOfNames; i++){
      cell_element_ptr = mxGetCell(prhs[4], i);

      if (cell_element_ptr == NULL){
        usage();
        mexErrMsgTxt("Empty item given for scalar name ");
      }

      if (! mxIsClass(cell_element_ptr, "char")){
        usage();
        mexErrMsgTxt("Scalar names must be strings.");
      }

      vector_name = mxArrayToString(cell_element_ptr);
      cout << "  " << i + 1 << " " << vector_name << endl;
      
      scalars[i]->SetName(vector_name);
    }
    
    
    
  } else {
    cout << "Assigned default scalar names:" << endl;
  }
  
  
  // Final output:
  
  vtkPolyData *output = vtkPolyData::New();
  output->SetPoints(points);
  output->SetPolys(faces);
  
  for (i = 0; i < noOfScalars; i++){
    output->GetPointData()->AddArray(scalars[i]);
  }
  
  if (noOfScalars > 0)
    output->GetPointData()->SetActiveScalars(scalars[0]->GetName());
  
  output->Update();
  
  vtkPolyDataWriter *writer = vtkPolyDataWriter::New();
  writer->SetInput(output);
  writer->SetFileName(output_name);
  writer->SetFileTypeToBinary();
  writer->Write();

  
  return;

}
