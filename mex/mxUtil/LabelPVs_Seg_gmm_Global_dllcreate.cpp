
#include <math.h>
#include <string.h>
#include <mexExport.h>

// Defines needed if matlab version < 7.3

// Hack to see if the following typdefs have or have not been
// made.  Matlab versions >7.3 do the typedef and define the
// following preproc. definition.  If it is not defined, we need
// to do a typedef.
#ifndef MWSIZE_MAX
typedef int mwIndex;
typedef int mwSize;
#endif

bool ExistLabel(unsigned int* labels, int lenOfLabels, int label)
{
  int i;
	for (i = 0; i < lenOfLabels; i++){
		if ( labels[i] == label )
			return true;
	}
	return false;
}

void GetNeighbourhood_offsets(const mxArray* SegResult, unsigned int* pSegResult,
						int xsize, int ysize, int zsize,
						int* offsetX, int* offsetY, int* offsetZ, int lenOfOffset,
						int x, int y, int z,
						unsigned int*& neighbors, int& lenOfNeighbors)
{
	if ( neighbors == NULL )
		neighbors = static_cast<unsigned int*>
			(mxCalloc(lenOfOffset, sizeof(unsigned int)));

	lenOfNeighbors = 0;

	int px, py, pz;

	int ndim3 = 3;

	mwIndex subs3[3];

	int ind;
	int tt;

	for (tt = 0; tt < lenOfOffset; ++tt){

		px = x + offsetX[tt];
		py = y + offsetY[tt];
		pz = z + offsetZ[tt];

		if ((px > 0) && (px <= xsize) && (py > 0) && (py <= ysize) && (pz > 0) && (pz <= zsize)){
			subs3[0] = px - 1; // row
			subs3[1] = py - 1; // col
			subs3[2] = pz - 1; // depth

      ind = mxCalcSingleSubscript(SegResult, ndim3, subs3);
			neighbors[lenOfNeighbors] = pSegResult[ind];

			++lenOfNeighbors;
		}
	}

	return;
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray* prhs[])

{
	// both 4 and 5 classes are supported ...

	// priors, N*4 prior array
	// indexes, N*3 coordinate array

	// segResult, 3D unit32 array <-- all white matter has been labelled into one class
	// neighborNum <-- 6 or 26

	// lamda
	// xsize
	// ysize
	// zsize
	// csflabel

	// wmlabel <-- one or two labels : 4 classes or 5 classes

	// cortexlabel

	// pvlabel

	// nonbrainlabel <-- double scalar, label for every tissue

	// output
	// LabelSeg, 3D unit32 array with PV voxels labelled as pvlabel
	// priors, N*4 prior array

	if ((nlhs==0) & (nrhs==0))
	{
		mexPrintf("\nUsage:\n\n");
		mexPrintf("[LabelSeg, Priors] = LabelPVs_Seg_gmm_GLobal_MEX(priors, indexes, segResult, neighborwidth, lamda, xsize, ysize, zsize, csflabel, wmlabel, cortexlabel, pvlabel, nonbrainlabel)\n\n");
		return;
	}

	/* Check for proper input and output arguments */
	if (nrhs != 13)
	{
		mexErrMsgTxt("Thirteen input arguments required.");
	}

	if (nlhs != 2)
	{
		mexErrMsgTxt("Two output arguments required.");
	}


	// parse the input
	// ============================================================== //
	//priors
	int number_of_dims = mxGetNumberOfDimensions(prhs[0]);
	if ((number_of_dims != 2) || !mxIsSingle(prhs[0]))
	{
		mexErrMsgTxt("priors must be a 2-dimensional single matrix.");
	}

	const mwSize* dim_Priors = mxGetDimensions(prhs[0]);

	int N;
	N = dim_Priors[0]; // the number of voxels

	int classNum;
	classNum = dim_Priors[1]; // 4 classes or 5 classes

	float* pPriors = static_cast<float*>(mxGetData(prhs[0]));
	// ============================================================== //


	// ============================================================== //
	//indexes
	number_of_dims = mxGetNumberOfDimensions(prhs[1]);
	if ((number_of_dims != 2) || !mxIsUint32(prhs[1]))
	{
		mexErrMsgTxt("indexes must be a 2-dimensional uint32 matrix.");
	}

	unsigned int* pIndexes = static_cast<unsigned int*>(mxGetData(prhs[1]));
	// ============================================================== //

	// ============================================================== //
	//segResult
	number_of_dims = mxGetNumberOfDimensions(prhs[2]);
	if ((number_of_dims != 3) || !mxIsUint32(prhs[2]))
	{
		mexErrMsgTxt("segResult must be a 3-dimensional uint32 matrix.");
	}

	const mwSize* dim_SegResult = mxGetDimensions(prhs[2]);

	unsigned int* pSegResult = static_cast<unsigned int*>(mxGetData(prhs[2]));
	// ============================================================== //

	// ============================================================== //
	// neighborNum
	int neighborNum = static_cast<int>(mxGetScalar(prhs[3]));

	// lamda
	float lamda = static_cast<float>(mxGetScalar(prhs[4]));

	// xsize
	int xsize = static_cast<int>(mxGetScalar(prhs[5]));

	// ysize
	int ysize = static_cast<int>(mxGetScalar(prhs[6]));

	// zsize
	int zsize = static_cast<int>(mxGetScalar(prhs[7]));

	// csflabel
	int csflabel = static_cast<int>(mxGetScalar(prhs[8]));

	// wmlabel

	bool fourClasses = true;
	int wmNum = mxGetNumberOfElements(prhs[9]);

	int wmlabel;

	if ( wmNum == 1 ) // 4 classes
		wmlabel = static_cast<int>(mxGetScalar(prhs[9]));

	if ( wmNum == 2 ) // 5 classes
	{
		double* pwmlabel = static_cast<double*>(mxGetData(prhs[9]));
		wmlabel = static_cast<int>(pwmlabel[0]); // first label
		fourClasses = false;
	}

	// cortexlabel
	int cortexlabel = static_cast<int>(mxGetScalar(prhs[10]));

	// pvlabel
	int pvlabel = static_cast<int>(mxGetScalar(prhs[11]));

	// nonbrainlabel <-- double scalar, label for every tissue
	int nonbrainlabel = static_cast<int>(mxGetScalar(prhs[12]));
	// ============================================================== //

	// ============================================================== //
	// output
	mxArray* LabelSeg = mxCreateNumericArray(3, dim_SegResult, mxUINT32_CLASS, mxREAL);
	unsigned int* pLabelSeg = static_cast<unsigned int*>(mxGetData(LabelSeg));
	memcpy(pLabelSeg, pSegResult, sizeof(unsigned int)*xsize*ysize*zsize);
	plhs[0] = LabelSeg;

	plhs[1] = mxCreateNumericArray(2, dim_Priors, mxSINGLE_CLASS, mxREAL);
	float* pOutPutPriors = static_cast<float*>(mxGetData(plhs[1]));
	memcpy(pOutPutPriors, pPriors, sizeof(float)*N*classNum);
	// ============================================================== //

	int i, j, k, pp;
	unsigned int label = 0;
	int ndim = 2;

	mwIndex subs[2];

	int ndim3 = 3;

	mwIndex subs3[3];

	int ind;
	unsigned int* neighbors = NULL; // allocate using mxCalloc, not need to mxFree
	int lenOfNeighbors = 0;
	bool hasCSF = false;
	bool hasCortex = false;
	bool hasWM = false;
	bool hasNonbrain = false;
	float priorCSF = 0;
	float priorCortex = 0;
	float priorWM = 0;
	float priorWM1 = 0;
	float priorWM2 = 0;
	float priorNonbrain = 0;
	float temp = 0.0;
	bool processed = false;
	float eps = 0.00000001f; // 1e-8;
	float csfNew, cortexNew;

	// set the offsets
	int* offsetX = NULL;
	int* offsetY = NULL;
	int* offsetZ = NULL;
	int lenOfOffset;

	switch (neighborNum)
	{
		case 26:
			{
				lenOfOffset = 26;
				offsetX = static_cast<int*>(mxCalloc(lenOfOffset, sizeof(int)));
				offsetY = static_cast<int*>(mxCalloc(lenOfOffset, sizeof(int)));
				offsetZ = static_cast<int*>(mxCalloc(lenOfOffset, sizeof(int)));

				break;
			}
		default:
			{
				// 6 neighbors
				lenOfOffset = 6;
				offsetX = static_cast<int*>(mxCalloc(lenOfOffset, sizeof(int)));
				offsetY = static_cast<int*>(mxCalloc(lenOfOffset, sizeof(int)));
				offsetZ = static_cast<int*>(mxCalloc(lenOfOffset, sizeof(int)));
				// -1 0 0; 1 0 0; 0 -1 0; 0 1 0; 0 0 -1; 0 0 1
				offsetX[0] = -1;
				offsetY[0] = 0;
				offsetZ[0] = 0;

				offsetX[1] = 1;
				offsetY[1] = 0;
				offsetZ[1] = 0;

				offsetX[2] = 0;
				offsetY[2] = -1;
				offsetZ[2] = 0;

				offsetX[3] = 0;
				offsetY[3] = 1;
				offsetZ[3] = 0;

				offsetX[4] = 0;
				offsetY[4] = 0;
				offsetZ[4] = -1;

				offsetX[5] = 0;
				offsetY[5] = 0;
				offsetZ[5] = 1;
			}
	}

	// for every voxel
	for (pp = 0; pp < N; ++pp){
		// --------------------------------------------- //
		//j = mix.indexes(pp, 1);
		//i = mix.indexes(pp, 2);
		//k = mix.indexes(pp, 3);

		subs[0] = pp; // row
		subs[1] = 0; // col

		// prhs[1] = indexes in the form of a mxArray

		ind = mxCalcSingleSubscript(prhs[1], ndim, subs);
		i = pIndexes[ind];

		subs[0] = pp; // row
		subs[1] = 1; // col
		ind = mxCalcSingleSubscript(prhs[1], ndim, subs);
		j = pIndexes[ind];

		subs[0] = pp; // row
		subs[1] = 2; // col
		ind = mxCalcSingleSubscript(prhs[1], ndim, subs);
		k = pIndexes[ind];
		// --------------------------------------------- //

		subs3[0] = i - 1; // row
		subs3[1] = j - 1; // col
		subs3[2] = k - 1; // depth

		// prhs[2] a.k.a segResult

		ind = mxCalcSingleSubscript(prhs[2], ndim3, subs3);
		label = pSegResult[ind];

		// if the pixel is nonbrain or csf or background (labelled by 0), continue
		if ( (label == 0) || (label == csflabel) || (label == nonbrainlabel) )
			continue;

		GetNeighbourhood_offsets(prhs[2], pSegResult, xsize, ysize, zsize,
						offsetX, offsetY, offsetZ, lenOfOffset,
						i, j, k, neighbors, lenOfNeighbors);

		hasCSF      = ExistLabel(neighbors, lenOfNeighbors, csflabel);
		hasCortex   = ExistLabel(neighbors, lenOfNeighbors, cortexlabel);
		hasWM       = ExistLabel(neighbors, lenOfNeighbors, wmlabel);
		hasNonbrain = ExistLabel(neighbors, lenOfNeighbors, nonbrainlabel);

		subs[0] = pp; // row
		subs[1] = 0; // col
		ind = mxCalcSingleSubscript(prhs[0], ndim, subs);
		priorCSF = pPriors[ind];

		subs[0] = pp; // row
		subs[1] = 1; // col
		ind = mxCalcSingleSubscript(prhs[0], ndim, subs);
		priorCortex = pPriors[ind];

		if ( fourClasses )
		{
			subs[0] = pp; // row
			subs[1] = 2; // col
			ind = mxCalcSingleSubscript(prhs[0], ndim, subs);
			priorWM = pPriors[ind];

			subs[0] = pp; // row
			subs[1] = 3; // col
			ind = mxCalcSingleSubscript(prhs[0], ndim, subs);
			priorNonbrain = pPriors[ind];
		}
		else
		{
			subs[0] = pp; // row
			subs[1] = 2; // col
			ind = mxCalcSingleSubscript(prhs[0], ndim, subs);
			priorWM1 = pPriors[ind];

			subs[0] = pp; // row
			subs[1] = 3; // col
			ind = mxCalcSingleSubscript(prhs[0], ndim, subs);
			priorWM2 = pPriors[ind];

			priorWM = priorWM1 + priorWM2;

			subs[0] = pp; // row
			subs[1] = 4; // col
			ind = mxCalcSingleSubscript(prhs[0], ndim, subs);
			priorNonbrain = pPriors[ind];
		}

		processed = false;

		if ( (label == wmlabel) && !processed){

		  // between CSF and non-brain tissue
			if ( hasCSF && hasNonbrain && !processed){

				priorCortex = priorCortex*lamda;

				priorWM = priorWM*lamda;

				if ( !fourClasses ){
				  priorWM1 = priorWM1*lamda;
					priorWM2 = priorWM2*lamda;
				}

				temp = 1 - (priorCSF + priorCortex + priorWM + priorNonbrain);
				priorCSF = priorCSF + temp;
				processed = true;
			}

			// between CSF and GM
			if ( hasCSF && hasCortex && !processed){

			  priorWM = priorWM*lamda;

			  if ( !fourClasses ){
					priorWM1 = priorWM1*lamda;
					priorWM2 = priorWM2*lamda;
				}

				temp = 1 - (priorCSF + priorCortex + priorWM + priorNonbrain);

				csfNew    = priorCSF + temp * priorCSF / (priorCSF + priorCortex + eps);
				cortexNew = priorCortex + temp * priorCortex / (priorCSF + priorCortex + eps);

				priorCSF    = csfNew;
				priorCortex = cortexNew;
				processed = true;
			}

			// between non-brain tissue and GM
			if ( hasCortex && hasNonbrain && !processed){

				priorWM = priorWM*lamda;

				if ( !fourClasses ){
					priorWM1 = priorWM1*lamda;
					priorWM2 = priorWM2*lamda;
				}

				temp = 1 - (priorCSF + priorCortex + priorWM + priorNonbrain);

				csfNew    = priorCSF + temp * priorCSF / (priorCSF + priorCortex + eps);
				cortexNew = priorCortex + temp * priorCortex / (priorCSF + priorCortex + eps);

				priorCSF    = csfNew;
				priorCortex = cortexNew;
				processed = true;
			}

      if (processed){

				subs3[0] = i - 1; // row
				subs3[1] = j - 1; // col
				subs3[2] = k - 1; // depth

				ind = mxCalcSingleSubscript(LabelSeg, ndim3, subs3);
				pLabelSeg[ind] = pvlabel;

				subs[0] = pp; // row
				subs[1] = 0; // col
				ind = mxCalcSingleSubscript(plhs[1], ndim, subs);
				pOutPutPriors[ind]= priorCSF;

				subs[0] = pp; // row
				subs[1] = 1; // col
				ind = mxCalcSingleSubscript(plhs[1], ndim, subs);
				pOutPutPriors[ind] = priorCortex;

				if (fourClasses){

				  subs[0] = pp; // row
					subs[1] = 2; // col
					ind = mxCalcSingleSubscript(plhs[1], ndim, subs);
					pOutPutPriors[ind] = priorWM;

					subs[0] = pp; // row
					subs[1] = 3; // col
					ind = mxCalcSingleSubscript(plhs[1], ndim, subs);
					pOutPutPriors[ind] = priorNonbrain;

				}	else {

				  subs[0] = pp; // row
					subs[1] = 2; // col
					ind = mxCalcSingleSubscript(plhs[1], ndim, subs);
					pOutPutPriors[ind] = priorWM1;

					subs[0] = pp; // row
					subs[1] = 3; // col
					ind = mxCalcSingleSubscript(plhs[1], ndim, subs);
					pOutPutPriors[ind] = priorWM2;

					subs[0] = pp; // row
					subs[1] = 4; // col
					ind = mxCalcSingleSubscript(plhs[1], ndim, subs);
					pOutPutPriors[ind] = priorNonbrain;
				}
			}
		}

		if ( (label == cortexlabel) && !processed)
		{
			// between CSF and non-brain tissue
			if ( hasCSF && hasNonbrain && !processed){

				priorCortex = priorCortex * lamda;
				priorWM     = priorWM * lamda;

				if ( !fourClasses ){
					priorWM1 = priorWM1*lamda;
					priorWM2 = priorWM2*lamda;
				}

				temp = 1 - (priorCSF + priorCortex + priorWM + priorNonbrain);

				priorCSF = priorCSF + temp;
  			processed = true;
			}

			// between CSF and 0
			if ( hasCSF && (label == 0) && !processed){
				priorCortex = priorCortex * lamda;

				temp = 1 - (priorCSF + priorCortex + priorWM + priorNonbrain);

				priorCSF = priorCSF + temp;
				processed = true;
			}

			// between WM and 0
			if ( hasWM && (label == 0) && !processed){

				priorCortex = priorCortex * lamda;

				temp = 1 - (priorCSF + priorCortex + priorWM + priorNonbrain);

				priorCSF = priorCSF + temp;
				processed = true;
			}

			if (processed){

			  subs3[0] = i - 1; // row
				subs3[1] = j - 1; // col
				subs3[2] = k - 1; // depth
				ind = mxCalcSingleSubscript(LabelSeg, ndim3, subs3);
				pLabelSeg[ind] = pvlabel;

				subs[0] = pp; // row
				subs[1] = 0; // col
				ind = mxCalcSingleSubscript(plhs[1], ndim, subs);
				pOutPutPriors[ind]= priorCSF;

				subs[0] = pp; // row
				subs[1] = 1; // col
				ind = mxCalcSingleSubscript(plhs[1], ndim, subs);
				pOutPutPriors[ind] = priorCortex;

				if ( fourClasses ){

				  subs[0] = pp; // row
					subs[1] = 2; // col
					ind = mxCalcSingleSubscript(plhs[1], ndim, subs);
					pOutPutPriors[ind] = priorWM;

					subs[0] = pp; // row
					subs[1] = 3; // col
					ind = mxCalcSingleSubscript(plhs[1], ndim, subs);
					pOutPutPriors[ind] = priorNonbrain;
				}	else {
					subs[0] = pp; // row
					subs[1] = 2; // col
					ind = mxCalcSingleSubscript(plhs[1], ndim, subs);
					pOutPutPriors[ind] = priorWM1;

					subs[0] = pp; // row
					subs[1] = 3; // col
					ind = mxCalcSingleSubscript(plhs[1], ndim, subs);
					pOutPutPriors[ind] = priorWM2;

					subs[0] = pp; // row
					subs[1] = 4; // col
					ind = mxCalcSingleSubscript(plhs[1], ndim, subs);
					pOutPutPriors[ind] = priorNonbrain;
				}
			}
		}
	}

	return;

}

