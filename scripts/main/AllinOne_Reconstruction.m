function AllinOne_Reconstruction(rootDir)

disp('----------------------------------------------------');
disp('AllinOne_Reconstruction');

% Try and avoid this step.
% copyFiles_cortexReconstruction; 

cortex_reconstruction = 'cortex_reconstruction';
[subdirs, num] = findAllDirectory(rootDir);

if ( fourClasses_flag )
    csf_seg_filename = 'csf_seg_4classes.hdr';
    wm_seg_filename = 'wm_seg_4classes.hdr';
    
    post_wm_Real_filename = 'post_wm_Real.hdr';
    post_gm_Real_filename = 'post_gm_Real.hdr';
    post_csf_Real_filename = 'post_csf_Real.hdr';
    Brainfilename = 'withStemBrain_N3.hdr';
end

if ( fiveClasses_flag )
    csf_seg_filename = 'csf_seg.hdr';
    wm_seg_filename = 'wm_seg.hdr';
    
    post_wm_Real_filename = 'post_wm_Real.hdr';
    post_gm_Real_filename = 'post_gm_Real.hdr';
    post_csf_Real_filename = 'post_csf_Real.hdr';
    Brainfilename = 'withStemBrain_N3.hdr';
end

for i=1:num
    
    dirName = fullfile(rootDir, subdirs{i}, cortex_reconstruction)

    cd(dirName);


    Cortex_Reconstruction_WholePipeline_AllRun
end

disp('----------------------------------------------------');