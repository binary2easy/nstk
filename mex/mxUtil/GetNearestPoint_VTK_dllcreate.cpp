
#include <mexExport.h>

#include <vtkFloatArray.h>
#include <vtkPointData.h>
#include <vtkPolyData.h>

#include <irtkImage.h>
#include <irtkLocator.h>

// #include <mxUtil.h>
// #include <mxVTK.h>

// Defined at end.
vtkPolyData* Pointsets2vtkPolyData(const mxArray* pts, int len);

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{ 

  int i;
  int _x, _y, _z; // column, row, depth

  /* Check for proper number of arguments */
  if (nrhs != 2) 
    mexErrMsgTxt("Two input arguments required."); 

  if (nlhs != 2) 
    mexErrMsgTxt("Two output arguments required."); 

  int ndim;
  const int* dims1;

  ndim = mxGetNumberOfDimensions(prhs[0]);
  dims1 = mxGetDimensions(prhs[0]);

  if ( dims1[1] != 3 )
    mexErrMsgTxt("The first input argument should be an array of 3D points.");

  double* pprhs0;
  const int* dims2;

  pprhs0 = mxGetPr(prhs[0]);
  dims2 = mxGetDimensions(prhs[1]);

  if ( dims2[1] != 3 )
    mexErrMsgTxt("The second input argument should be an array of 3D points.");

  double* pprhs1;
  int len1, len2;


  pprhs1 = mxGetPr(prhs[1]);
  len1 = dims1[0];
  len2 = dims2[0];

  /* Create a matrix for the return argument */

  plhs[0] = mxCreateDoubleMatrix(len1, 1, mxREAL); // minDist

  double* pplhs0;
  double* pplhs1;
  pplhs0 = mxGetPr(plhs[0]);
  plhs[1] = mxCreateDoubleMatrix(len1, 3, mxREAL); // nearestPoints
 
  pplhs1 = mxGetPr(plhs[1]);

  vtkPolyData* line2;


  line2 = Pointsets2vtkPolyData(prhs[1], len2);


  int stage = 8;
  mexPrintf("Got to stage %d\n", stage);



  /*itkLocator *locator = new itkLocator;  
    locator->SelectLocatorType(2); // kd-tree locator
    locator->SetDataSet(line2);*/

  vtkKDTreePointLocator *kd_locator = vtkKDTreePointLocator::New();
  kd_locator->SetNumberOfPointsPerBucket(50);
  kd_locator->SetDataSet(line2);

  stage = 9;
  mexPrintf("Got to stage %d\n", stage);

  //  kd_locator->BuildLocator();

  stage = 10;
  mexPrintf("Got to stage %d\n", stage);
  //  return;




  double dx, dy, dz;
  double xyz[3];
  int subscripts[2];
  int index1, index2, index3;
  int temp_id = -1;

  for (i = 0; i < len1; i++){

    subscripts[0] = i;	

    subscripts[1] = 0;
    index1 = mxCalcSingleSubscript(prhs[0], ndim, subscripts);
    xyz[0] = pprhs0[index1];

    subscripts[1] = 1;
    index2 = mxCalcSingleSubscript(prhs[0], ndim, subscripts);
    xyz[1] = pprhs0[index2];

    subscripts[1] = 2;
    index3 = mxCalcSingleSubscript(prhs[0], ndim, subscripts);
    xyz[2] = pprhs0[index3];

  stage = 13;
  mexPrintf("Got to stage %d\n", stage);
  return;


    temp_id = kd_locator->FindClosestPoint(xyz);
    //temp_id = locator->FindClosestPoint(xyz);

    line2->GetPoint(temp_id, xyz);

    dx = pprhs0[index1] - xyz[0];
    dy = pprhs0[index2] - xyz[1];
    dz = pprhs0[index3] - xyz[2];

    pplhs0[i] = sqrt(dx*dx + dy*dy + dz*dz);

    pplhs1[index1] = xyz[0];
    pplhs1[index2] = xyz[1];
    pplhs1[index3] = xyz[2];
  }



  line2->Delete();
  kd_locator->Delete();

  //delete locator;
  return;

}




vtkPolyData* Pointsets2vtkPolyData(const mxArray* pts, int len)
{

  double* ppts;
  int i, ndim;
  int subs[2];
  double x, y, z;
  int p1, p2, p3;

  ppts = mxGetPr(pts);
  ndim = 2;

  vtkPoints* target = vtkPoints::New();
  target->SetNumberOfPoints(len);
  target->Allocate(len, 1000);
  target->SetDataTypeToDouble();

  for (i = 0; i < len; i++){
    subs[0] = i;
    subs[1] = 0;
    p1 = mxCalcSingleSubscript(pts, ndim, subs);

    subs[0] = i;
    subs[1] = 1;
    p2 = mxCalcSingleSubscript(pts, ndim, subs);

    subs[0] = i;
    subs[1] = 2;
    p3 = mxCalcSingleSubscript(pts, ndim, subs);

    x = ppts[p1];
    y = ppts[p2];
    z = ppts[p3];

    target->InsertPoint(i, x, y, z); 
    //target->InsertNextPoint(x, y, z); 
  }


  vtkIdList* idlist = vtkIdList::New();
  idlist->Allocate(len);

  for (i = 0; i < len; i++)
    idlist->InsertNextId(i);




  // create data attributes
  vtkFloatArray* radius = vtkFloatArray::New();

  radius->Allocate(len);
  for (i = 0; i < len; i++)
    radius->InsertNextValue(0.2);

  // create the vtkPolyData using the cell and attributes
  vtkPolyData* target_pts = vtkPolyData::New();
  target_pts->Allocate(len, len);
  target_pts->SetPoints(target);



  //for ( i=0; i<len; i++  )
  //	target_pts->InsertNextCell(VTK_VERTEX, 1, &i);

  target_pts->InsertNextCell(VTK_POLY_VERTEX, idlist);
  target_pts->GetPointData()->SetScalars(radius);
  target_pts->Update();


  /*vtkPolyDataWriter* writer = vtkPolyDataWriter::New();
    writer->SetFileTypeToBinary();
    writer->SetInput(target_pts);
    writer->SetFileName("test.vtp");
    writer->Update();
    writer->Write();*/

  radius->Delete();
  idlist->Delete();
  target->Delete();


  return target_pts;
}

