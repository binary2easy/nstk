#
PROJECT(mexCompiler)

# public settings
ADD_DEFINITIONS( -DMATLAB_MEX_FILE )

SET(EXECUTABLE_OUTPUT_PATH ${mexCompiler_BINARY_DIR}/bin CACHE STRING
  "Where to put the executables")
SET(LIBRARY_OUTPUT_PATH ${mexCompiler_BINARY_DIR}/lib CACHE STRING
  "Where to put the libraries")

OPTION(BUILD_SHARED_LIBS "Build shared libraries." On)
OPTION(BUILD_SHARED "Build shared library" On)

# G:/programs/MATLAB/R2008a/extern
SET(MATLAB_DIRECTORY /usr/local/matlab/
   CACHE STRING "Where the MATLAB is installed")

INCLUDE_DIRECTORIES(${MATLAB_DIRECTORY}/extern/include)

# Libraries for linking 
LINK_DIRECTORIES( ${MATLAB_DIRECTORY}/bin/glnx86  )
# ${MATLAB_DIRECTORY}/lib/win32/microsoft


# MATLAB libraries
# LINK_LIBRARIES(libmx libmex libmat)
LINK_LIBRARIES(mx mex mat)

# project directory
INCLUDE_DIRECTORIES( ${mexCompiler_SOURCE_DIR}/include)

# # first to find VTK
FIND_PACKAGE(VTK)

# Add VTK
INCLUDE(${CMAKE_ROOT}/Modules/FindVTK.cmake)

#SET(VTK_FOUND 1)
#INCLUDE(${VTK_DIR}/VTKConfig.cmake)

IF (VTK_FOUND)
  ADD_DEFINITIONS(-DHAS_VTK)

  INCLUDE_DIRECTORIES(${VTK_INCLUDE_DIRS})
  LINK_DIRECTORIES(${VTK_LIBRARY_DIRS})

  IF (VTK_KITS MATCHES "HYBRID")
     ADD_DEFINITIONS(-DHAS_VTK_HYBRID)
     LINK_LIBRARIES (vtkHybrid)
  ENDIF (VTK_KITS MATCHES "HYBRID")

  LINK_LIBRARIES(vtkRendering vtkCommon vtkexpat
          vtkFiltering vtkfreetype vtkftgl vtkGraphics
          vtkHybrid vtkImaging vtkIO)

  MESSAGE("vtk found")

ELSE (VTK_FOUND)

  MESSAGE("VTK NOT FOUND : Please set VTK directory manually")

ENDIF (VTK_FOUND)

# DITK

SET(DITK_DIRECTORY /home/pa100/shared-data/Users/paul/work/project
        CACHE STRING "Where the DITK is installed")

INCLUDE_DIRECTORIES( ${DITK_DIRECTORY}/recipes/include)
INCLUDE_DIRECTORIES( ${DITK_DIRECTORY}/common++/include)
INCLUDE_DIRECTORIES( ${DITK_DIRECTORY}/geometry++/include)
INCLUDE_DIRECTORIES( ${DITK_DIRECTORY}/image++/include)
INCLUDE_DIRECTORIES( ${DITK_DIRECTORY}/contrib++/include)
INCLUDE_DIRECTORIES( ${DITK_DIRECTORY}/nifti/niftilib)
INCLUDE_DIRECTORIES( ${DITK_DIRECTORY}/nifti/znzlib)

INCLUDE_DIRECTORIES( ${DITK_DIRECTORY}/packages/transformation/include)
INCLUDE_DIRECTORIES( ${DITK_DIRECTORY}/packages/registration/include)
INCLUDE_DIRECTORIES( ${DITK_DIRECTORY}/packages/segmentation/include)

INCLUDE_DIRECTORIES( ${DITK_DIRECTORY}/packages/contrib/include)

SET(DITK_LIB_DIRECTORY ${DITK_DIRECTORY}/linux/lib
       CACHE STRING "Where the DITK Library files are installed")

LINK_DIRECTORIES(${DITK_LIB_DIRECTORY})

LINK_LIBRARIES(common++ contrib++ geometry++ image++
  niftiio recipes registration++
  segmentation++ transformation++ znz)

# INCLUDE_DIRECTORIES(G:/pa100/zlib123-dll/include)
# LINK_DIRECTORIES(G:/pa100/zlib123-dll/lib)
# LINK_LIBRARIES(zdll)

# sub directories


SUBDIRS(mxUtil)
# SUBDIRS(BSpline_Unser_implementation)
# SUBDIRS(vtk_programs)
# SUBDIRS(vtk_programs_withDITK)
# SUBDIRS(gridding)
# SUBDIRS(ems_MRF)
# SUBDIRS(speedup)


IF (WIN32)
#   SET (CMAKE_SHARED_LINKER_FLAGS_RELEASE /EXPORT:mexFunction CACHE
#     STRING "Flags used by the linker during the creation of dll's.")
ENDIF (WIN32)
