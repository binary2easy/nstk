INCLUDE_DIRECTORIES( ${CMAKE_CURRENT_SOURCE_DIR})


# ADD_LIBRARY(LabelPVs_Seg_gmm_Global_MEX SHARED ../include/mexExport.h LabelPVs_Seg_gmm_Global_dllcreate.cpp)

# ADD_LIBRARY(GetNearestPoints_VTK SHARED ../include/mexExport.h GetNearestPoint_VTK_dllcreate.cpp)
#  ../include/mxUtil.h ../include/mxVTK.h 

ADD_LIBRARY(Read_vtkPolyData SHARED ../include/mexExport.h mexRead_vtkPolyData.cpp)

ADD_LIBRARY(Write_vtkPolyData SHARED ../include/mexExport.h mexWrite_vtkPolyData.cpp)

# ADD_LIBRARY(LabelPVs_Seg_gmm_Local_MEX SHARED ../include/mexExport.h LabelPVs_Seg_gmm_Local_dllcreate.cpp)
# ADD_LIBRARY(LabelPVs_Seg_gmm_atlas_Global_MEX SHARED ../include/mexExport.h LabelPVs_Seg_gmm_atlas_Global_dllcreate.cpp)
# ADD_LIBRARY(LabelPVs_Seg_gmm_atlas_Local_MEX SHARED ../include/mexExport.h LabelPVs_Seg_gmm_atlas_Local_dllcreate.cpp)
# ADD_LIBRARY(GetPVs_WM2CSF_MEX SHARED ../include/mexExport.h GetPVs_WM2CSF_MEX_dllcreate.cpp)
