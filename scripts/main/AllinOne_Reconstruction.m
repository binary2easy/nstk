function AllinOne_Reconstruction(rootDir, fourClasses_flag, fiveClasses_flag, ...
  appDir, subfolder)

disp('----------------------------------------------------');
disp('AllinOne_Reconstruction');

if (nargin == 4)
  [subdirs, num] = findAllDirectory(rootDir);
elseif (nargin == 5)
  % Single subfolder to process.
  subdirs = {subfolder};
  num = 1;  
else
  error('AllinOne_Reconstruction : called with wrong number of arguments.');  
end

for i=1:num
    
  subjDir = fullfile(rootDir, subdirs{i});
  disp(['AllinOne_Reconstruction : ' subjDir ]);

  if (fourClasses_flag)
    Cortex_Reconstruction_WholePipeline_AllRun(subjDir, 4, appDir);
  end
  
  if (fiveClasses_flag)
    Cortex_Reconstruction_WholePipeline_AllRun(subjDir, 5, appDir);
  end
  
end

disp('----------------------------------------------------');