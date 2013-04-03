#
#
PROJECT(nstkMex)
#
#


CMAKE_MINIMUM_REQUIRED(VERSION 2.4)

IF(COMMAND CMAKE_POLICY)
  CMAKE_POLICY(SET CMP0003 NEW)
ENDIF(COMMAND CMAKE_POLICY)


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

SET(BITNESS 32)

IF( ${CMAKE_SIZEOF_VOID_P} EQUAL 8)
  SET(BITNESS 64)
ENDIF()

IF(APPLE)
  IF ( ${BITNESS} EQUAL 64 )
    LINK_DIRECTORIES( ${MATLAB_ROOT}/bin/maci64  )
  ELSE( ${BITNESS} EQUAL 64 )
    MESSAGE(FATAL_ERROR
      "Macintosh 32 bit unsupported.")
  ENDIF( ${BITNESS} EQUAL 64 )
ENDIF(APPLE)

IF( ${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
  IF ( ${BITNESS} EQUAL 64 )
    LINK_DIRECTORIES( ${MATLAB_ROOT}/bin/glnxa64 )
  ELSE( ${BITNESS} EQUAL 64 )
    LINK_DIRECTORIES( ${MATLAB_ROOT}/bin/glnx86 )
  ENDIF( ${BITNESS} EQUAL 64 )
ENDIF()


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

SET(IRTK_DIRECTORY NOT_FOUND
        CACHE PATH "Where the IRTK is installed")

IF( ${IRTK_DIRECTORY} STREQUAL "NOT_FOUND")

    MESSAGE(FATAL_ERROR
      "Cannot build without IRTK.  Please set IRTK_DIRECTORY.")
ENDIF()

SET(IRTK_BUILD_DIRECTORY_SUFFIX "build" CACHE STRING "The directory beneath the IRTK folder where the build is")


INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/recipes/include)
INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/common++/include)
INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/geometry++/include)
INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/image++/include)
INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/contrib++/include)
INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/nifti/niftilib)
INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/nifti/znzlib)

INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/packages/transformation/include)
INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/packages/registration/include)
INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/packages/segmentation/include)
INCLUDE_DIRECTORIES( ${IRTK_DIRECTORY}/packages/contrib/include)

SET(IRTK_LIB_DIRECTORY ${IRTK_DIRECTORY}/${IRTK_BUILD_DIRECTORY_SUFFIX}/lib
       CACHE STRING "Where the IRTK Library files are installed")

LINK_DIRECTORIES(${IRTK_LIB_DIRECTORY})

LINK_LIBRARIES(common++ contrib++ geometry++ image++
  niftiio recipes registration++
  segmentation++ transformation++ znz)


INCLUDE(${CMAKE_ROOT}/Modules/FindZLIB.cmake)

IF (ZLIB_FOUND)
  INCLUDE_DIRECTORIES(${ZLIB_INCLUDE_DIR})
  LINK_LIBRARIES(${ZLIB_LIBRARIES})
ENDIF (ZLIB_FOUND)

############################################


# IF (WIN32)
#   SET (CMAKE_SHARED_LINKER_FLAGS_RELEASE /EXPORT:mexFunction CACHE
#     STRING "Flags used by the linker during the creation of dll's.")
# ENDIF (WIN32)
