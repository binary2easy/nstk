#include <matrix.h>

#include <mat.h>

#include <mex.h>

#define PI 3.14159265358979

#define MEXPRINTF(name) mexPrintf(#name);

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[]);

// Legacy code that was not used any way.

// #include <mexExport.h>

// #ifndef _MEXFUNCTION

// #ifdef __cpluslus

// #define _MEXFUNCTION extern"C"__declspec(dllimport)

// #else

// #define _MEXFUNCTION __declspec(dllimport)

// #endif

// #endif

// #include <mclmcr.h> 

//#include <mex_vc7.h>
