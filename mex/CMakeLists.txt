#
#
PROJECT(nstkMex)
#
#


cmake_minimum_required(VERSION 2.4)

if(COMMAND cmake_policy)
  cmake_policy(SET CMP0003 NEW)
endif(COMMAND cmake_policy)


############################################
# Project specific stuff:

SET(EXECUTABLE_OUTPUT_PATH ${nstkMex_BINARY_DIR}/bin CACHE STRING
  "Where to put the executables")
SET(LIBRARY_OUTPUT_PATH ${nstkMex_BINARY_DIR}/lib CACHE STRING
  "Where to put the libraries")

OPTION(BUILD_SHARED_LIBS "Build shared libraries." ON)
OPTION(BUILD_SHARED "Build shared library" ON)


INCLUDE_DIRECTORIES( ${nstkMex_SOURCE_DIR}/include)


SUBDIRS(mxUtil)


############################################
# Matlab stuff:

SET( MATLAB_ROOT NOT_FOUND CACHE PATH  "Matlab Dir")

IF( ${MATLAB_ROOT} STREQUAL "NOT_FOUND")

    MESSAGE(FATAL_ERROR
      "Cannot build without MATLAB.  Please set MATLAB_ROOT.")

ENDIF()


SET( MATLAB_INCLUDE_DIR ${MATLAB_ROOT}/extern/include )

INCLUDE_DIRECTORIES(${MATLAB_INCLUDE_DIR})

# Libraries for linking 
IF(APPLE)
  LINK_DIRECTORIES( ${MATLAB_ROOT}/bin/maci64  )
ENDIF(APPLE)
  
# MATLAB libraries
LINK_LIBRARIES(mx mex mat)

# Not sure how much this is needed.
ADD_DEFINITIONS( -DMATLAB_MEX_FILE )


############################################


# # Now to find VTK
FIND_PACKAGE(VTK)

# Add VTK
INCLUDE(${CMAKE_ROOT}/Modules/FindVTK.cmake)

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

ELSE (VTK_FOUND)

  MESSAGE("VTK NOT FOUND : Please set VTK directory manually")

ENDIF (VTK_FOUND)

############################################

# # IRTK

# SET(IRTK_DIRECTORY NOT_FOUND
#         CACHE PATH "Where the IRTK is installed")

# IF( ${IRTK_DIRECTORY} STREQUAL "NOT_FOUND")

#     MESSAGE(FATAL_ERROR
#       "Cannot build without IRTK.  Please set IRTK_DIRECTORY.")
# ENDIF()

# SET(IRTK_BUILD_DIRECTORY_SUFFIX "build" CACHE STRING "The directory beneath the IRTK folder where the build is")


# INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/recipes/include)
# INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/common++/include)
# INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/geometry++/include)
# INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/image++/include)
# INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/contrib++/include)
# INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/nifti/niftilib)
# INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/nifti/znzlib)

# INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/packages/transformation/include)
# INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/packages/registration/include)
# INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/packages/segmentation/include)
# INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/packages/contrib/include)

# SET(IRTK_LIB_DIRECTORY ${IRTK_DIRECTORY}/${IRTK_BUILD_DIRECTORY_SUFFIX}/lib
#        CACHE STRING "Where the IRTK Library files are installed")

# LINK_DIRECTORIES(${IRTK_LIB_DIRECTORY})

# LINK_LIBRARIES(common++ contrib++ geometry++ image++
#   niftiio recipes registration++
#   segmentation++ transformation++ znz)


############################################


# IF (WIN32)
#   SET (CMAKE_SHARED_LINKER_FLAGS_RELEASE /EXPORT:mexFunction CACHE
#     STRING "Flags used by the linker during the creation of dll's.")
# ENDIF (WIN32)
