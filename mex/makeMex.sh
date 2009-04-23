# When building for linux, this script needs to be run manually
# after a standard make call.  This is to link the libraries for
# use within the matlab environment.  Long term, we need to find
# a way to ensure that this happens automatically after cmake
# generates the makefiles.

# In windows standard dlls need to be built but the exports in
# mexFunction.def file need to be added for each dll.

# replace MATLAB_BIN_DIR with local one e.g. /usr/local/matlab/bin/glnx86
# replace IRTK_LIB_DIR with local one e.g. /home/pa100/shared-data/Users/paul/work/project/linux/lib
# replace VTK_DIR with local one, e.g. /home/pa100/shared-data/vtk/linux/bin

cd linux/mxUtil/

mex -o ../lib/LabelPVs_Seg_gmm_Global_MEX "CMakeFiles/LabelPVs_Seg_gmm_Global_MEX.dir/LabelPVs_Seg_gmm_Global_dllcreate.o" -LMATLAB_BIN_DIR/glnx86 -LIRTK_LIB_DIR -lmx -lmex -lmat -lcommon++ -lcontrib++ -lgeometry++ -limage++ -lniftiio -lrecipes -lregistration++ -lsegmentation++ -ltransformation++ -lznz -Wl,-rpath,MATLAB_BIN_DIR/glnx86:IRTK_LIB_DIR


mex -o ../lib/libGetNearestPoints_VTK.so "CMakeFiles/GetNearestPoints_VTK.dir/GetNearestPoint_VTK_dllcreate.o" -LMATLAB_BIN_DIR -LVTK_DIR -LIRTK_LIB_DIR -lmx -lmex -lmat -lvtkHybrid -lvtkRendering -lvtkGraphics -lvtkImaging -lvtkIO -lvtkFiltering -lvtkCommon -lvtkDICOMParser -lvtksqlite -lvtkexpat -lvtkftgl -lvtkfreetype -lcommon++ -lcontrib++ -lgeometry++ -limage++ -lniftiio -lrecipes -lregistration++ -lsegmentation++ -ltransformation++ -lznz -lvtkexoIIc -lGL -lXt -lSM -lICE -lX11 -lXext -lXss -lvtkmetaio -lvtksys -lpthread -ldl -lm -lvtkverdict -lvtkNetCDF -lvtkpng -lvtktiff -lvtkzlib -lvtkjpeg -lvtkFiltering -lvtkfreetype -lvtkftgl -lvtkGraphics -lvtkHybrid -lvtkImaging -lvtkIO -lvtkCommon -lcommon++ -lcontrib++ -lgeometry++ -limage++ -lniftiio -lrecipes -lregistration++ -lsegmentation++ -ltransformation++ -lznz -Wl,-rpath,MATLAB_BIN_DIR:/home/pa100/shared-data/vtk/linux/bin:IRTK_LIB_DIR 


