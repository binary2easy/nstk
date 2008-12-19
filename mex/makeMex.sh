# When building for linux, this script needs to be run manually
# after a standard make call.  This is to link the libraries for
# use within the matlab environment.  Long term, we need to find
# a way to ensure that this happens automatically after cmake
# generates the makefiles.

# In windows standard dlls need to be built but the exports in
# mexFunction.def file need to be added for each dll.

cd linux/mxUtil/

mex -o ../lib/LabelPVs_Seg_gmm_Global_MEX "CMakeFiles/LabelPVs_Seg_gmm_Global_MEX.dir/LabelPVs_Seg_gmm_Global_dllcreate.o" -LMATLAB_BIN_DIR -LIRTK_LIB_DIR -lmx -lmex -lmat -lcommon++ -lcontrib++ -lgeometry++ -limage++ -lniftiio -lrecipes -lregistration++ -lsegmentation++ -ltransformation++ -lznz -Wl,-rpath,MATLAB_BIN_DIR/glnx86:IRTK_LIB_DIR
