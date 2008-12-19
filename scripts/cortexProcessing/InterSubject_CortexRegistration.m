
% parameters

% NumofLevels <-- the level nums of iterations
% maximal_inflation_factor [0 1]
% NumberOfIterations = 5; <-- the inflation iteration between two checking
% RelaxationFactor = 0.5; < lemda in inflation
% ThresRatio = 0.01; <-- the threshold to stop
% numofSurfaceNonRigid

% targetImageName
% Internal_Target_Name
% 
% sourceImageName
% Internal_Source_Name

% CortexRegistationDir
cd(CortexRegistationDir);

tt = numofSurfaceNonRigid;
output = ['DirectNoSmooth' '_afterNonRigid_' num2str(tt) '.vtk'];
if ( isempty(dir(output))==0 )
    return;
end

locator = 2;
iterations = 250;
epsilon = 0.005;
symmetric = [];

numofparameters = 5; % 20mm --> 1.25mm

spacing = 20;

if ( exist('Prefix') == 0 )
    Prefix = '';
end

if ( exist('numofSurfaceNonRigid') == 0 )
    numofSurfaceNonRigid = 4;
end

% -------------------------------------------------------------------------
surfacefile_Target = Internal_Target_Name;
vtkfile_Target = 'internal_target.vtk';
vtkfile_Target_inflated = 'internal_target_inflated.vtk';
image_Target = targetImageName;

surfacefile_Source = Internal_Source_Name;
vtkfile_Source = 'internal_source.vtk';
vtkfile_Source_inflated = 'internal_source_inflated.vtk';
image_Source = sourceImageName;


threshold = 0;
shrink = [1 1 1];
smooth = [0.1 20];

datacolor = [1 1 1];
opacity = 1;

rreg_name = 'image_rigid.dof';
areg_name = 'image_affine.dof';

% -------------------------------------------------------------------------

filename = surfacefile_Target;

if ( isempty(dir(vtkfile_Target))==1 )
    [data, header] = LoadAnalyze(filename, 'Real');
    mcubes2VTKFile(data, header, vtkfile_Target, threshold, shrink, smooth);
%     if ( isempty(dir(brainMask_Target_Name))==0 )
%         MaskVTK_PolyData_Binary(vtkfile_Target, vtkfile_Target, brainMask_Target_Name);
%     end
end

[ICI_Target, ECI_Target, GLN_Target, MLN_Target, newMeanC, newGaussC] = Compute_SecondOrderStatistics_OutlierRemoval(vtkfile_Target);

% numCells = 97424; 
% ICI = 468.492952; ECI = 572.119621; GLN = 5482.743057; MLN = 35.260129; 
%------------------------------------------------------------------------
filename = surfacefile_Source;

if ( isempty(dir(vtkfile_Source))==1 )
    [data, header] = LoadAnalyze(filename, 'Real');
    mcubes2VTKFile(data, header, vtkfile_Source, threshold, shrink, smooth);
    
%     if ( isempty(dir(brainMask_Source_Name))==0 )
%         MaskVTK_PolyData_Binary(vtkfile_Source, vtkfile_Source, brainMask_Source_Name);
%     end   
end

[ICI_Source, ECI_Source, GLN_Source, MLN_Source, newMeanC, newGaussC] = Compute_SecondOrderStatistics_OutlierRemoval(vtkfile_Source);

% target_stats
lower_stats = [min(ICI_Target, ICI_Source) min(ECI_Target, ECI_Source) min(GLN_Target, GLN_Source) min(MLN_Target, MLN_Source)];
lower_stats(3) = -1;
%------------------------------------------------------------------------
% image registration
target = image_Target;
source = image_Source;

% all subject directories
rreg_parameterfile = 'C:\huixue\work\more_neonates_images_LS\parameters\parameters.rreg';
areg_parameterfile = 'C:\huixue\work\more_neonates_images_LS\parameters\parameters.areg';

% numofparameters = 5; % 20mm --> 1.25mm
% hreg_parameterfiles = cell(numofparameters);
% hreg_parameterfiles{1} = 'J:\Neonatal_brain_data\parameters\parameters-20mm.mreg';
% hreg_parameterfiles{2} = 'J:\Neonatal_brain_data\parameters\parameters-10mm.mreg';
% hreg_parameterfiles{3} = 'J:\Neonatal_brain_data\parameters\parameters-5mm.mreg';
% hreg_parameterfiles{4} = 'J:\Neonatal_brain_data\parameters\parameters-2.5mm.mreg';
% hreg_parameterfiles{5} = 'J:\Neonatal_brain_data\parameters\parameters-2.5mm.mreg';
% 
% dofnames = cell(numofparameters);
% dofnames{1} = 'image_nonrigid_20mm.dof';
% dofnames{2} = 'image_nonrigid_10mm.dof';
% dofnames{3} = 'image_nonrigid_5mm.dof';
% dofnames{4} = 'image_nonrigid_2.5mm.dof';
% dofnames{5} = 'image_nonrigid_1.25mm.dof';

controlPoints = [20 20 20];
if ( isempty(dir(rreg_name))==1 )
    RigidRegistrationRun2(target, source, rreg_name, rreg_parameterfile);
end

if ( isempty(dir(areg_name))==1 )
    AffineRegistrationRun2(target, source, areg_name, areg_parameterfile, rreg_name);
end
% NonRigidRegistrationRun2(target, source, dofnames, hreg_parameterfiles, numofparameters, areg_name, 0, controlPoints);
%------------------------------------------------------------------------
ind = find(lower_stats==-1);
num = length(ind);

if ( NumofLevels > 1 )
    increment = (1-maximal_inflation_factor) / (NumofLevels-1);
else
    increment = 0;
end
current_inflation_factor = maximal_inflation_factor;

dofinName = areg_name;

sareg_name = 'affine.dof';

% locator = 2;
% iterations = 150;
% epsilon = 0.005;
% symmetric = [];
% 
% numofparameters = 6; % 20mm --> 1.25mm
% 
% spacing = 20;

% dofnames = cell(numofparameters);
% dofnames{1} = ['Level' num2str(kk) '_nonrigid_20mm.dof'];
% dofnames{2} = ['Level' num2str(kk) '_nonrigid_10mm.dof'];
% dofnames{3} = ['Level' num2str(kk) '_nonrigid_5mm.dof'];
% dofnames{4} = ['Level' num2str(kk) '_nonrigid_2.5mm.dof'];
% dofnames{5} = ['Level' num2str(kk) '_nonrigid_1.25mm.dof'];
% dofnames{6} = ['Level' num2str(kk) '_nonrigid_0.625mm.dof'];

dofnames = cell(6);

for kk=1:NumofLevels

    current_inflation_factor = maximal_inflation_factor + (kk-1)*increment;
    dst_stats = current_inflation_factor*lower_stats;
    dst_stats(find(lower_stats==-1)) = -1;
    
    Input = vtkfile_Target;
    Output1 = ['Level' num2str(kk) '_' vtkfile_Target_inflated];
    PerformInflation(Input, Output1, NumberOfIterations, RelaxationFactor, ThresRatio, dst_stats, MaxofIterations);
    
    Input = vtkfile_Source;
    Output2 = ['Level' num2str(kk) '_' vtkfile_Source_inflated];
    PerformInflation(Input, Output2, NumberOfIterations, RelaxationFactor, ThresRatio, dst_stats, MaxofIterations);
            
%     dofnames = cell(numofSurfaceNonRigid);
    dofnames{1} = ['Level' num2str(kk) '_nonrigid_20mm.dof'];
    dofnames{2} = ['Level' num2str(kk) '_nonrigid_10mm.dof'];
    dofnames{3} = ['Level' num2str(kk) '_nonrigid_5mm.dof'];
    dofnames{4} = ['Level' num2str(kk) '_nonrigid_2.5mm.dof'];
    dofnames{5} = ['Level' num2str(kk) '_nonrigid_1.25mm.dof'];
    dofnames{6} = ['Level' num2str(kk) '_nonrigid_0.625mm.dof'];
         
    target = Output1;
    source = Output2;
   
    if ( kk == 1 )
        
        dofin = areg_name;
        SurfaceAffineRegistrationRun(target, source, sareg_name, dofin, locator, iterations, 0, epsilon, symmetric);

        output = 'target_afterAffine.vtk';
        SurfaceTransformationRun(target, output, sareg_name);
        
        target = output;
        SurfaceNonRigidRegistrationRun2(target, source, dofnames, numofSurfaceNonRigid,...
            [], locator, iterations, spacing, epsilon, symmetric);        
    else
        
        SurfaceNonRigidRegistrationRun2(target, source, dofnames, numofSurfaceNonRigid,...
            dofinName, locator, iterations, spacing, epsilon, symmetric);
    end
    
    for tt = 1:numofSurfaceNonRigid
        output = ['Level' num2str(kk) '_afterNonRigid_' num2str(tt) '.vtk'];
        SurfaceTransformationRun(target, output, dofnames{tt});
    end

    dofinName = dofnames{numofSurfaceNonRigid};
end
%------------------------------------------------------------------------

% as the final registration
% try to use the nonrigid for the original surfaces
target = vtkfile_Target;
source = vtkfile_Source;

% dofnames = cell(numofSurfaceNonRigid);
dofnames{1} = ['noSmooth' num2str(kk) '_nonrigid_20mm.dof'];
dofnames{2} = ['noSmooth' num2str(kk) '_nonrigid_10mm.dof'];
dofnames{3} = ['noSmooth' num2str(kk) '_nonrigid_5mm.dof'];
dofnames{4} = ['noSmooth' num2str(kk) '_nonrigid_2.5mm.dof'];
dofnames{5} = ['noSmooth' num2str(kk) '_nonrigid_1.25mm.dof'];
dofnames{6} = ['noSmooth' num2str(kk) '_nonrigid_0.625mm.dof'];

SurfaceNonRigidRegistrationRun2(target, source, dofnames, numofSurfaceNonRigid,...
    dofinName, locator, iterations, spacing, epsilon, symmetric);

for tt = 1:numofSurfaceNonRigid
    output = ['noSmooth' '_afterNonRigid_' num2str(tt) '.vtk'];
    SurfaceTransformationRun(target, output, dofnames{tt});
end
%------------------------------------------------------------------------

% as a comparison, do the direct non-rigid registration
% use the affine to initialize the cortex registration

target = 'target_afterAffine.vtk';
source = vtkfile_Source;

% dofnames = cell(numofSurfaceNonRigid);
dofnames{1} = ['DirectNoSmooth_' 'nonrigid_20mm.dof'];
dofnames{2} = ['DirectNoSmooth_' 'nonrigid_10mm.dof'];
dofnames{3} = ['DirectNoSmooth_' 'nonrigid_5mm.dof'];
dofnames{4} = ['DirectNoSmooth_' 'nonrigid_2.5mm.dof'];
dofnames{5} = ['DirectNoSmooth_' 'nonrigid_1.25mm.dof'];
dofnames{6} = ['DirectNoSmooth_' 'nonrigid_0.625mm.dof'];

SurfaceNonRigidRegistrationRun2(target, source, dofnames, numofSurfaceNonRigid,...
    [], locator, iterations, spacing, epsilon, symmetric);

for tt = 1:numofSurfaceNonRigid
    output = ['DirectNoSmooth' '_afterNonRigid_' num2str(tt) '.vtk'];
    SurfaceTransformationRun(target, output, dofnames{tt});
end
%------------------------------------------------------------------------