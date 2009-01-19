function copyFiles_cortexReconstruction(rootDir)

posteriorDir = 'posterior_4classes';

cortex_reconstruction = 'cortex_reconstruction';
segResult = 'Result';
N3Dir = 'N3Brain';
brainMask = 'brainMask';

suffix = 'nii.gz';

[subdirs, num] = findAllDirectory(rootDir)

for i=1:num
  
  currentDir = fullfile(rootDir, subdirs{i})
  cd(currentDir);

  %------------------------------------------------------------------
  sourcefile = fullfile(currentDir, posteriorDir);
  dstfile = fullfile(currentDir, cortex_reconstruction);
  p = dir(fullfile(dstfile, ['post_csf_Real.' suffix]));
  if ( isempty(p)==1 )
    %%% Note copying of whole of directory contents!
    copyfile(sourcefile, dstfile);
  end

  %------------------------------------------------------------------
  sourcefile = fullfile(currentDir, N3Dir, ['withStemBrain_N3.' suffix]);
  dstfile = fullfile(currentDir, cortex_reconstruction, 'withStemBrain_N3.' suffix]);
  if ( isempty(dir(dstfile))==1 )
    copyfile(sourcefile, dstfile);
  end

  %------------------------------------------------------------------
  sourcefile = fullfile(currentDir, brainMask, ['brainmask_nostem.' suffix]);
  dstfile = fullfile(currentDir, cortex_reconstruction, 'brainmask_nostem.' suffix]);
  if ( isempty(dir(dstfile))==1 )
    copyfile(sourcefile, dstfile);
  end

  %------------------------------------------------------------------
  if ( fourClasses_flag )
    sourcefile = fullfile(currentDir, segResult, ['cortex_seg_4classes.' suffix]);
    dstfile = fullfile(currentDir, cortex_reconstruction, ['cortex_seg_4classes.' suffix]);
    if ( isempty(dir(dstfile))==1 )
      copyfile(sourcefile, dstfile);
    end

    sourcefile = fullfile(currentDir, segResult, ['wm_seg_4classes.' suffix]);
    dstfile = fullfile(currentDir, cortex_reconstruction, ['wm_seg_4classes.' suffix]);
    if ( isempty(dir(dstfile))==1 )
      copyfile(sourcefile, dstfile);
    end

    sourcefile = fullfile(currentDir, segResult, ['csf_seg_4classes.' suffix]);
    dstfile = fullfile(currentDir, cortex_reconstruction, ['csf_seg_4classes.' suffix]);
    if ( isempty(dir(dstfile))==1 )
      copyfile(sourcefile, dstfile);
    end

    sourcefile = fullfile(currentDir, ['segResult_4classes.' suffix]);
    dstfile = fullfile(currentDir, cortex_reconstruction, ['segResult.' suffix]);
    if ( isempty(dir(dstfile))==1 )
      copyfile(sourcefile, dstfile);
    end

  if ( fiveClasses_flag )
    sourcefile = fullfile(currentDir, segResult, ['cortex_seg.' suffix]);
    dstfile = fullfile(currentDir, cortex_reconstruction, ['cortex_seg.' suffix]);
    if ( isempty(dir(dstfile))==1 )
      copyfile(sourcefile, dstfile);
    end

    sourcefile = fullfile(currentDir, segResult, ['wm_seg.' suffix]);
    dstfile = fullfile(currentDir, cortex_reconstruction, ['wm_seg.' suffix]);
    if ( isempty(dir(dstfile))==1 )
      copyfile(sourcefile, dstfile);
    end

    sourcefile = fullfile(currentDir, segResult, ['csf_seg.' suffix]);
    dstfile = fullfile(currentDir, cortex_reconstruction, ['csf_seg.' suffix]);
    if ( isempty(dir(dstfile))==1 )
      copyfile(sourcefile, dstfile);
    end

    sourcefile = fullfile(currentDir, ['segResult_5classes.' suffix]);
    dstfile = fullfile(currentDir, cortex_reconstruction, ['segResult.' suffix]);
    if ( isempty(dir(dstfile))==1 )
      copyfile(sourcefile, dstfile);
    end

  %------------------------------------------------------------------
end
