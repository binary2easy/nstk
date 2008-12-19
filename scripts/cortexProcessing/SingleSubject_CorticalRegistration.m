
clear
home = 'J:\more_neonates_images_LS\new_subjects2\Intra_subjects\test_Registration';
cd(home);

targetDir = '3T637'; % first scan
sourceDir = '3T714'; % second scan

ImageName = 'N3Brain_roi.hdr';
InternalName = 'Internal_levelset_Result.hdr';
brainMask_nostem = 'brainmask_nostem_roi.hdr';

CortexRegistationDir = 'CortexRegistration';

% for the intra subject registration

% only one level is fine
NumofLevels = 4; %the level nums of iterations
% no need to inflate the simple surface
maximal_inflation_factor = 0.6;

NumberOfIterations = 30; % the number of iterations performed for every inflation process
MaxofIterations = 150;
RelaxationFactor = 0.5;
ThresRatio = 0.02;
numofSurfaceNonRigid = 5; % up to 6
% ============================================================== %    

targetImageName = fullfile(home, targetDir, ImageName);
if ( isempty(dir(targetImageName))==1 )
    error('file is not there');
end

Internal_Target_Name = fullfile(home, targetDir, InternalName);
if ( isempty(dir(Internal_Target_Name))==1 )
    error('file is not there');
end

brainMask_Target_Name = fullfile(home, targetDir, brainMask_nostem);;

sourceImageName = fullfile(home, sourceDir, ImageName);
if ( isempty(dir(sourceImageName))==1 )
    error('file is not there');
end

Internal_Source_Name = fullfile(home, sourceDir, InternalName);
if ( isempty(dir(Internal_Source_Name))==1 )
    error('file is not there');
end

brainMask_Source_Name = fullfile(home, sourceDir, brainMask_nostem);;

CortexRegistationDir = fullfile(home, [targetDir '_' sourceDir '_' 'CortexRegistration'])
mkdir(CortexRegistationDir);
InterSubject_CortexRegistration
