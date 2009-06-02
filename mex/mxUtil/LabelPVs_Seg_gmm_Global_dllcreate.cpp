
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

bool ExistLabel(unsigned int* labels, int noOfLabels, int label)
{
  int i;
	for (i = 0; i < noOfLabels; i++){
		if ( labels[i] == label )
			return true;
	}
	return false;
}

void GetNeighbourhood_offsets(const mxArray* mxSegImage, unsigned int* segImage,
						int xsize, int ysize, int zsize,
						int* offsetX, int* offsetY, int* offsetZ, int lenOfOffset,
						int x, int y, int z,
						unsigned int*& neighbouringLabels, int& noOfLabelledNeighbours)
{
	if ( neighbouringLabels == NULL )
		neighbouringLabels = static_cast<unsigned int*>
			(mxCalloc(lenOfOffset, sizeof(unsigned int)));

	noOfLabelledNeighbours = 0;

	int px, py, pz;

	int three = 3;

	mwIndex sub3D[3];

	int index;
	int tt;

	for (tt = 0; tt < lenOfOffset; ++tt){

		px = x + offsetX[tt];
		py = y + offsetY[tt];
		pz = z + offsetZ[tt];

		if ((px > 0) && (px <= xsize) && (py > 0) && (py <= ysize) && (pz > 0) && (pz <= zsize)){
		  // Converting from matlab one-indexing to zero-indexing.
			sub3D[0] = px - 1; // row
			sub3D[1] = py - 1; // col
			sub3D[2] = pz - 1; // depth

      index = mxCalcSingleSubscript(mxSegImage, three, sub3D);
			neighbouringLabels[noOfLabelledNeighbours] = segImage[index];

			++noOfLabelledNeighbours;
		}
	}

	return;
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray* prhs[])

{
	// both 4 and 5 classes are supported ...

	// priors, N x {4 or 5} prior array
	// indexes, N x3 image coordinate array, each coordinate corresponds 
  //          to a point with the same row as in the priors array.

	// segResult, 3D unit32 array <-- all white matter has been labelled into one class
	// connectivity <-- 6 or 26

	// lambda (0.5)
	// xsize Dimensions of image array
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
		mexPrintf("[LabelSeg, Priors] = LabelPVs_Seg_gmm_GLobal_MEX(priors, indexes, segResult, neighborwidth, lambda, xsize, ysize, zsize, csflabel, wmlabel, cortexlabel, pvlabel, nonbrainlabel)\n\n");
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
	// prhs[0] -> priors array (N x {4 or 5})
	int number_of_dims = mxGetNumberOfDimensions(prhs[0]);
	if ((number_of_dims != 2) || !mxIsSingle(prhs[0]))
	{
		mexErrMsgTxt("priors must be a 2-dimensional single matrix.");
	}

	const mwSize* dim_Priors = mxGetDimensions(prhs[0]);

	int noOfVoxels;
	// the number of voxels
	noOfVoxels = dim_Priors[0]; 

	int noOfClasses;
	// 4 classes or 5 classes
	noOfClasses = dim_Priors[1]; 

	float* priorsArray = static_cast<float*>(mxGetData(prhs[0]));
	// ============================================================== //


	// ============================================================== //
	// Image indices, N x 3 array.
	number_of_dims = mxGetNumberOfDimensions(prhs[1]);
	if ((number_of_dims != 2) || !mxIsUint32(prhs[1]))
	{
		mexErrMsgTxt("indexes must be a 2-dimensional uint32 matrix.");
	}

	unsigned int* imageIndices = static_cast<unsigned int*>(mxGetData(prhs[1]));
	// ============================================================== //

	
	// ============================================================== //
	// segResult : Result of GMM/EM segmentation.
	//             A 3D image array with dimensions xsize x ysize x zsize.
	number_of_dims = mxGetNumberOfDimensions(prhs[2]);
	if ((number_of_dims != 3) || !mxIsUint32(prhs[2]))
	{
		mexErrMsgTxt("segResult must be a 3-dimensional uint32 matrix.");
	}

	const mwSize* segImageDims = mxGetDimensions(prhs[2]);

	unsigned int* inputSegImage = static_cast<unsigned int*>(mxGetData(prhs[2]));
	// ============================================================== //

	
	// ============================================================== //
	// connectivity
	int connectivity = static_cast<int>(mxGetScalar(prhs[3]));

	// lambda
	float lambda = static_cast<float>(mxGetScalar(prhs[4]));

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
	int noOfWMclasses = mxGetNumberOfElements(prhs[9]);

	int wmlabel;

	if ( noOfWMclasses == 1 ){
	  // 4 classes in total
		wmlabel = static_cast<int>(mxGetScalar(prhs[9]));
	}

	if ( noOfWMclasses == 2 )
	{
	  // 5 classes in total.
		double* wmLabelArray = static_cast<double*>(mxGetData(prhs[9]));
		// first label only!?
		wmlabel = static_cast<int>(wmLabelArray[0]); 
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
	mxArray* mxOutputSegImage = mxCreateNumericArray(3, segImageDims, mxUINT32_CLASS, mxREAL);
	
	unsigned int* outputSegImage = static_cast<unsigned int*>(mxGetData(mxOutputSegImage));
	
	// Copy current segmentation into pLabelSeg.
	memcpy(outputSegImage, inputSegImage, sizeof(unsigned int)*xsize*ysize*zsize);
	plhs[0] = mxOutputSegImage;

	plhs[1] = mxCreateNumericArray(2, dim_Priors, mxSINGLE_CLASS, mxREAL);
	float* outputPriorsArray = static_cast<float*>(mxGetData(plhs[1]));
	// Copy input priors into output priors.
	memcpy(outputPriorsArray, priorsArray, sizeof(float)*noOfVoxels*noOfClasses);
	// ============================================================== //

	int i, j, k, n;
	unsigned int label = 0;
	int two = 2;

	mwIndex sub2D[2];

	int three = 3;

	mwIndex sub3D[3];

	int ind;
	unsigned int* neighbouringLabels = NULL; // allocate using mxCalloc, not need to mxFree
	int labelledNeigbourCount = 0;
	
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

	switch (connectivity)
	{
		case 26:
			{
				lenOfOffset = 26;
				offsetX = static_cast<int*>(mxCalloc(lenOfOffset, sizeof(int)));
				offsetY = static_cast<int*>(mxCalloc(lenOfOffset, sizeof(int)));
				offsetZ = static_cast<int*>(mxCalloc(lenOfOffset, sizeof(int)));
				// Seems to tail off.  No offsets actually assigned.
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
				offsetY[0] =  0;
				offsetZ[0] =  0;

				offsetX[1] =  1;
				offsetY[1] =  0;
				offsetZ[1] =  0;

				offsetX[2] =  0;
				offsetY[2] = -1;
				offsetZ[2] =  0;

				offsetX[3] =  0;
				offsetY[3] =  1;
				offsetZ[3] =  0;

				offsetX[4] =  0;
				offsetY[4] =  0;
				offsetZ[4] = -1;

				offsetX[5] =  0;
				offsetY[5] =  0;
				offsetZ[5] =  1;
			}
	}

	// For every voxel
	for (n = 0; n < noOfVoxels; ++n){

	  // --------------------------------------------- //
		// j = mix.indexes(pp, 1);
		// i = mix.indexes(pp, 2);
		// k = mix.indexes(pp, 3);

    // prhs[1] <- imageIndices in the form of a N x 3 (2D) mxArray

		sub2D[0] = n; // row
		sub2D[1] = 0; // col
		ind = mxCalcSingleSubscript(prhs[1], two, sub2D);
		i = imageIndices[ind];

		sub2D[0] = n; // row
		sub2D[1] = 1; // col
		ind = mxCalcSingleSubscript(prhs[1], two, sub2D);
		j = imageIndices[ind];

		sub2D[0] = n; // row
		sub2D[1] = 2; // col
		ind = mxCalcSingleSubscript(prhs[1], two, sub2D);
		k = imageIndices[ind];
		// --------------------------------------------- //

		sub3D[0] = i - 1; // row
		sub3D[1] = j - 1; // col
		sub3D[2] = k - 1; // depth

		// What is the label of the current voxel?
		// prhs[2] <- inputSegImage
		ind = mxCalcSingleSubscript(prhs[2], three, sub3D);
		label = inputSegImage[ind];

		// if the pixel is nonbrain or csf or background (labelled by 0), continue
		if ( (label == 0) || (label == csflabel) || (label == nonbrainlabel) )
			continue;

		// Investigate the neighbourhood of the voxel.
		
		//                       prhs[2] <- inputSegImage
		GetNeighbourhood_offsets(prhs[2], inputSegImage, xsize, ysize, zsize,
						offsetX, offsetY, offsetZ, lenOfOffset,
						i, j, k, neighbouringLabels, labelledNeigbourCount);

		hasCSF      = ExistLabel(neighbouringLabels, labelledNeigbourCount, csflabel);
		hasCortex   = ExistLabel(neighbouringLabels, labelledNeigbourCount, cortexlabel);
		hasWM       = ExistLabel(neighbouringLabels, labelledNeigbourCount, wmlabel);
		hasNonbrain = ExistLabel(neighbouringLabels, labelledNeigbourCount, nonbrainlabel);

		// Retrieve the prior probabilities for the voxel.
		
		sub2D[0] = n; // row
		sub2D[1] = 0; // col
		ind = mxCalcSingleSubscript(prhs[0], two, sub2D);
		priorCSF = priorsArray[ind];

		sub2D[0] = n; // row
		sub2D[1] = 1; // col
		ind = mxCalcSingleSubscript(prhs[0], two, sub2D);
		priorCortex = priorsArray[ind];

		if ( fourClasses )
		{
			sub2D[0] = n; // row
			sub2D[1] = 2; // col
			ind = mxCalcSingleSubscript(prhs[0], two, sub2D);
			priorWM = priorsArray[ind];

			sub2D[0] = n; // row
			sub2D[1] = 3; // col
			ind = mxCalcSingleSubscript(prhs[0], two, sub2D);
			priorNonbrain = priorsArray[ind];
		}
		else
		{
			sub2D[0] = n; // row
			sub2D[1] = 2; // col
			ind = mxCalcSingleSubscript(prhs[0], two, sub2D);
			priorWM1 = priorsArray[ind];

			sub2D[0] = n; // row
			sub2D[1] = 3; // col
			ind = mxCalcSingleSubscript(prhs[0], two, sub2D);
			priorWM2 = priorsArray[ind];

			// Combine the separate WM priors into one.
			priorWM = priorWM1 + priorWM2;

			sub2D[0] = n; // row
			sub2D[1] = 4; // col
			ind = mxCalcSingleSubscript(prhs[0], two, sub2D);
			priorNonbrain = priorsArray[ind];
		}

		processed = false;

		///////////////////
		// Case 1: WM label?
		
		if ( (label == wmlabel) && !processed){

		  // Between CSF and non-brain tissue
			if ( hasCSF && hasNonbrain && !processed){
			  // Reduce tissue probs by factor lambda.
			  // Assign what is left over to CSF.
				priorCortex = priorCortex * lambda;

				priorWM     = priorWM * lambda;

				if ( !fourClasses ){
				  priorWM1 = priorWM1 * lambda;
					priorWM2 = priorWM2 * lambda;
				}

				temp = 1 - (priorCSF + priorCortex + priorWM + priorNonbrain);
				priorCSF = priorCSF + temp;
				processed = true;
			}

			// between CSF and GM
			if ( hasCSF && hasCortex && !processed){

			  // Reduce WM
			  priorWM = priorWM * lambda;

			  if ( !fourClasses ){
					priorWM1 = priorWM1 * lambda;
					priorWM2 = priorWM2 * lambda;
				}

			  // Find remainder with current values.
				temp = 1 - (priorCSF + priorCortex + priorWM + priorNonbrain);

				// Distribute pro-rata to CSF and GM
				csfNew    = priorCSF    + temp * priorCSF    / (priorCSF + priorCortex + eps);
				cortexNew = priorCortex + temp * priorCortex / (priorCSF + priorCortex + eps);

				priorCSF    = csfNew;
				priorCortex = cortexNew;
				processed = true;
			}

			// between non-brain tissue and GM
			if ( hasCortex && hasNonbrain && !processed){

			  // Reduce WM
				priorWM = priorWM * lambda;

				if ( !fourClasses ){
					priorWM1 = priorWM1*lambda;
					priorWM2 = priorWM2*lambda;
				}

				// Find remainder.
				temp = 1 - (priorCSF + priorCortex + priorWM + priorNonbrain);

				// Distribute pro-rata to CSF and GM
				csfNew    = priorCSF    + temp * priorCSF    / (priorCSF + priorCortex + eps);
				cortexNew = priorCortex + temp * priorCortex / (priorCSF + priorCortex + eps);

				priorCSF    = csfNew;
				priorCortex = cortexNew;
				processed = true;
			}

      if (processed){
        // Voxel was considered a PV voxel.

        // Deal with MatLab one-indexing.
				sub3D[0] = i - 1; // row
				sub3D[1] = j - 1; // col
				sub3D[2] = k - 1; // depth

				// Indicate PV status in the output labels.
				ind = mxCalcSingleSubscript(mxOutputSegImage, three, sub3D);
				outputSegImage[ind] = pvlabel;

				// Update probabilities in the output priors.
				// plhs[1] <- outputPriorsArray
				
				sub2D[0] = n; // row
				sub2D[1] = 0; // col
				ind = mxCalcSingleSubscript(plhs[1], two, sub2D);
				outputPriorsArray[ind]= priorCSF;

				sub2D[0] = n; // row
				sub2D[1] = 1; // col
				ind = mxCalcSingleSubscript(plhs[1], two, sub2D);
				outputPriorsArray[ind] = priorCortex;

				if (fourClasses){

				  sub2D[0] = n; // row
					sub2D[1] = 2; // col
					ind = mxCalcSingleSubscript(plhs[1], two, sub2D);
					outputPriorsArray[ind] = priorWM;

					sub2D[0] = n; // row
					sub2D[1] = 3; // col
					ind = mxCalcSingleSubscript(plhs[1], two, sub2D);
					outputPriorsArray[ind] = priorNonbrain;

				}	else {

				  sub2D[0] = n; // row
					sub2D[1] = 2; // col
					ind = mxCalcSingleSubscript(plhs[1], two, sub2D);
					outputPriorsArray[ind] = priorWM1;

					sub2D[0] = n; // row
					sub2D[1] = 3; // col
					ind = mxCalcSingleSubscript(plhs[1], two, sub2D);
					outputPriorsArray[ind] = priorWM2;

					sub2D[0] = n; // row
					sub2D[1] = 4; // col
					ind = mxCalcSingleSubscript(plhs[1], two, sub2D);
					outputPriorsArray[ind] = priorNonbrain;
				}
			}
		}

    ///////////////////
    // Case 1: GM label?

		if ( (label == cortexlabel) && !processed)
		{
			// between CSF and non-brain tissue
			if ( hasCSF && hasNonbrain && !processed){

			  // Reduce tissue classes
				priorCortex = priorCortex * lambda;
				priorWM     = priorWM * lambda;

				if ( !fourClasses ){
					priorWM1 = priorWM1*lambda;
					priorWM2 = priorWM2*lambda;
				}

				// Find the remainder
				temp = 1 - (priorCSF + priorCortex + priorWM + priorNonbrain);

				// Assign to CSF
				priorCSF = priorCSF + temp;
  			processed = true;
			}

			// between CSF and background
			if ( hasCSF && (label == 0) && !processed){
			  
			  // Reduce GM
				priorCortex = priorCortex * lambda;

				// Find remainder
				temp = 1 - (priorCSF + priorCortex + priorWM + priorNonbrain);

				// Assign to CSF
				priorCSF = priorCSF + temp;
				processed = true;
			}

			// between WM and background
			if ( hasWM && (label == 0) && !processed){

			  // Reduce GM
				priorCortex = priorCortex * lambda;

				// Find remainder
				temp = 1 - (priorCSF + priorCortex + priorWM + priorNonbrain);

				// Assign to CSF
				priorCSF = priorCSF + temp;
				processed = true;
			}

			if (processed){

			  // Voxel was PV.
			  // Have some updating to do on the ouput.
			  
			  sub3D[0] = i - 1; // row
				sub3D[1] = j - 1; // col
				sub3D[2] = k - 1; // depth
				
				// Show PV status on output labels.
				ind = mxCalcSingleSubscript(mxOutputSegImage, three, sub3D);
				outputSegImage[ind] = pvlabel;

				// Update output priors.
				// plhs[1] <- outputPriorsArray
				
				sub2D[0] = n; // row
				sub2D[1] = 0; // col
				ind = mxCalcSingleSubscript(plhs[1], two, sub2D);
				outputPriorsArray[ind]= priorCSF;

				sub2D[0] = n; // row
				sub2D[1] = 1; // col
				ind = mxCalcSingleSubscript(plhs[1], two, sub2D);
				outputPriorsArray[ind] = priorCortex;

				if ( fourClasses ){

				  sub2D[0] = n; // row
					sub2D[1] = 2; // col
					ind = mxCalcSingleSubscript(plhs[1], two, sub2D);
					outputPriorsArray[ind] = priorWM;

					sub2D[0] = n; // row
					sub2D[1] = 3; // col
					ind = mxCalcSingleSubscript(plhs[1], two, sub2D);
					outputPriorsArray[ind] = priorNonbrain;
				}	else {
					sub2D[0] = n; // row
					sub2D[1] = 2; // col
					ind = mxCalcSingleSubscript(plhs[1], two, sub2D);
					outputPriorsArray[ind] = priorWM1;

					sub2D[0] = n; // row
					sub2D[1] = 3; // col
					ind = mxCalcSingleSubscript(plhs[1], two, sub2D);
					outputPriorsArray[ind] = priorWM2;

					sub2D[0] = n; // row
					sub2D[1] = 4; // col
					ind = mxCalcSingleSubscript(plhs[1], two, sub2D);
					outputPriorsArray[ind] = priorNonbrain;
				}
			}
		}
	}

	return;

}

