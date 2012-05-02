
#include <mexExport.h>
#include <tmwtypes.h>

#include <vtkDoubleArray.h>
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
  mexPrintf("   Write_vtkPolyDataWithVectors(FILENAME, V, F, vecs)\n");
  mexPrintf("   Write_vtkPolyDataWithVectors(FILENAME, V, F, vecs, vecNames)\n");
  mexPrintf("   V    = vertices.\n");
  mexPrintf("   F    = faces\n");
  mexPrintf("   vecs = per vertex vector data\n\n");
  mexPrintf("   vecNames : optional argument. Cell array of strings to use as names for vecs\n\n");
  cout << "V    must be a 3 x N array where N is the number of vertices." << endl;
  cout << "F    must be a K x M array where K is the vertices per face and M is the number of faces." << endl;
  cout << "vecs must be a 3 x N array." << endl;

  cout << endl;
  return;
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{

  int i, j, ind;
  int vectorNamesGiven = 0;
  double pt[3];
  vtkIdType npts = 0;
  vtkIdType *ptIds;

  /* Check for proper number of arguments */
  if (nrhs < 4){
    usage();
    mexErrMsgTxt("Four or five input argument required.");
  }

  if (nrhs == 5)
    vectorNamesGiven = 1;


  output_name =  mxArrayToString(prhs[0]);
  cout << "Output: " << output_name << endl;



  if (mxGetNumberOfDimensions(prhs[1]) != 2 ||
      mxGetNumberOfDimensions(prhs[2]) != 2 ||
      mxGetNumberOfDimensions(prhs[3]) != 2){
    usage();
    mexErrMsgTxt("V, F and vecs arrays must be two dimensional.");
  }

  if (! mxIsClass(prhs[1], "single") ||
      ! mxIsClass(prhs[2], "uint32") ||
      ! mxIsClass(prhs[3], "single")  ){
    usage();
    mexErrMsgTxt("V and vecs must be single arrays and F must be a uint32 (unsigned long) array.");
  }

  const mwSize *vdims = mxGetDimensions(prhs[1]);
  const mwSize *fdims = mxGetDimensions(prhs[2]);
  const mwSize *vecdims = mxGetDimensions(prhs[3]);

  if (vdims[0] != 3){
    usage();
    mexErrMsgTxt("V must have dimensions 3 x number of vertices.");
  }

  if (vecdims[1] != vdims[1]){
    usage();
    mexErrMsgTxt("V and vecs must have the same number of columns (= # vertices).");
  }

  if (vecdims[0] != 3){
  	usage();
  	mexErrMsgTxt("vecs must have 3 rows.");
  }

  cout << "Vertices       : " << vdims[1] << endl;
  cout << "Faces          : " << fdims[1] << endl;

  int noOfVertices, noOfFaces;
  int vertsPerFace;


  noOfVertices = vdims[1];
  noOfFaces = fdims[1];
  vertsPerFace = fdims[0];

  // Get the data;

  // Matlab 'single' type
  real32_T* vertexData = static_cast<real32_T*>(mxGetData(prhs[1]));
  // Matlab 'uint32' type
  uint32_T* faceData = static_cast<uint32_T*>(mxGetData(prhs[2]));
  real32_T* vectorData = static_cast<real32_T*>(mxGetData(prhs[3]));

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

  // Vectors:

  int scalarInd;
  char buffer[100];


  vtkDoubleArray *vectors = vtkDoubleArray::New();
  vectors->SetNumberOfComponents(3);
  vectors->SetNumberOfTuples(noOfVertices);

  sprintf(buffer, "vecs");
  vectors->SetName(buffer);

  double vx, vy, vz;

  for (j = 0; j < noOfVertices; j++){
  	sub[1] = j;

    sub[0] = 0;
  	ind = mxCalcSingleSubscript(prhs[3], 2, sub);
  	vx = vectorData[ind];

    sub[0] = 1;
  	ind = mxCalcSingleSubscript(prhs[3], 2, sub);
  	vy = vectorData[ind];

    sub[0] = 2;
  	ind = mxCalcSingleSubscript(prhs[3], 2, sub);
  	vz = vectorData[ind];
  	vectors->SetTuple3(j,vx, vy, vz);
  }



  if (vectorNamesGiven == 1){

    int noOfNames;
    const mxArray *cell_element_ptr;

    if (! mxIsClass(prhs[4], "cell") ){
      usage();
      mexErrMsgTxt("Scalar names must be a cell array of strings.");
    }


    noOfNames = mxGetNumberOfElements(prhs[4]);

    if (noOfNames != 1){
      usage();
      mexErrMsgTxt("Exactly one name must be given for vector data.");
    }

    cout << "Assigning given vector name:" << endl;

    cell_element_ptr = mxGetCell(prhs[4], 0);

    if (cell_element_ptr == NULL){
    	usage();
    	mexErrMsgTxt("Empty item given for vector name ");
    }

    if (! mxIsClass(cell_element_ptr, "char")){
    	usage();
    	mexErrMsgTxt("Scalar names must be strings.");
    }

    vector_name = mxArrayToString(cell_element_ptr);
    cout << " " << vector_name << endl;

    vectors->SetName(vector_name);
  } else {
    cout << "Assigned default name." << endl;
  }

  // Final output:
  
  vtkPolyData *output = vtkPolyData::New();
  output->SetPoints(points);
  output->SetPolys(faces);
  
  output->GetPointData()->SetVectors(vectors);
//  output->GetPointData()->SetActiveVectors(vectors->GetName());
  output->Update();
  

  vtkPolyDataWriter *writer = vtkPolyDataWriter::New();
  writer->SetInput(output);
  writer->SetFileName(output_name);
  writer->SetFileTypeToBinary();
  writer->Write();

  
  return;

}
