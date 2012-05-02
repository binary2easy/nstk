#!/bin/bash

# Script for generating mex files.


# When building the mex files the broad steps are:

# 1. Generate makefiles with cmake

# 2. Run a standard make call to generate the object files.  This will
#    also generate libraries but these will be ignored.

# 3. Run this script manually to generate linking commands that can be
#    used by the matlab tool 'mex'.  This will generate the matlab
#    compatible 'mex' libraries.  The suffix will be .dll, .glnx**,
#    .mexmac** depending on the machine used.


# Long term, we need to find a way to ensure that this happens
# automatically after cmake generates the makefiles.

# In windows standard dlls need to be built but the exports in
# mexFunction.def file need to be added for each dll.


buildDir="build"

subDirs="mxUtil"


tmpD=` mktemp -d /tmp/tmp.XXXXXX `
trap 'echo "Exiting and cleaning up ... removing ${tmpD}"; rm -rf $tmpD' EXIT

cd $buildDir

tmp=$tmpD/tmp.txt

for d in $subDirs
do
    cd $d

    fileList=`find . -name 'link.txt'`

    for f in $fileList
    do
	cp $f $tmp
	# Replace the build tool
	sed -i -e 's|.*c\+\+|\/Applications\/MATLAB_R2011b.app\/bin/mex|' $tmp
	sed -i -e 's/\-Wl,[^ ]* //g' $tmp
	sed -i -e 's/\-install_name [^ ]* //g'  $tmp
	sed -i -e 's/lib\([^\/]*\)\.dylib/\1/g'  $tmp
	sed -i -e 's/\.dylib//g' $tmp
	sed -i -e 's/\-dynamiclib//g' $tmp 
	sed -i -e 's/\-framework [^ ]* //g' $tmp
	cat $tmp
	echo
	echo

	cmd=`cat $tmp`
	eval $cmd
    done
    cd -
done


#  OLD CODE:


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

# MATLAB_BIN_DIR=""
# IRTK_LIB_DIR=""
# VTK_DIR=""

# cd linux/mxUtil/

# mex -o ../lib/LabelPVs_Seg_gmm_Global_MEX "CMakeFiles/LabelPVs_Seg_gmm_Global_MEX.dir/LabelPVs_Seg_gmm_Global_dllcreate.o" -L${MATLAB_BIN_DIR}/glnx86 -L${IRTK_LIB_DIR} -lmx -lmex -lmat -lcommon++ -lcontrib++ -lgeometry++ -limage++ -lniftiio -lrecipes -lregistration++ -lsegmentation++ -ltransformation++ -lznz -Wl,-rpath,${MATLAB_BIN_DIR}/glnx86:${IRTK_LIB_DIR}

# mex -o ../lib/GetNearestPoints_VTK "CMakeFiles/GetNearestPoints_VTK.dir/GetNearestPoint_VTK_dllcreate.o" -L${MATLAB_BIN_DIR} -L${VTK_DIR} -L${IRTK_LIB_DIR} -lmx -lmex -lmat -lvtkHybrid -lvtkRendering -lvtkGraphics -lvtkImaging -lvtkIO -lvtkFiltering -lvtkCommon -lvtkDICOMParser -lvtksqlite -lvtkexpat -lvtkftgl -lvtkfreetype -lcommon++ -lcontrib++ -lgeometry++ -limage++ -lniftiio -lrecipes -lregistration++ -lsegmentation++ -ltransformation++ -lznz -lvtkexoIIc -lGL -lXt -lSM -lICE -lX11 -lXext -lXss -lvtkmetaio -lvtksys -lpthread -ldl -lm -lvtkverdict -lvtkNetCDF -lvtkpng -lvtktiff -lvtkzlib -lvtkjpeg -lvtkFiltering -lvtkfreetype -lvtkftgl -lvtkGraphics -lvtkHybrid -lvtkImaging -lvtkIO -lvtkCommon -lcommon++ -lcontrib++ -lgeometry++ -limage++ -lniftiio -lrecipes -lregistration++ -lsegmentation++ -ltransformation++ -lznz -Wl,-rpath,${MATLAB_BIN_DIR}:${VTK_DIR}:${IRTK_LIB_DIR} 


