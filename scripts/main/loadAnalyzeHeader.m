function header = loadAnalyzeHeader(analyzename)

if ~exist(analyzename, 'file');
  header = struct([]);
  error('loadAnalyzeHeader : no such file : %s', analyzename);
  return
end

   
if (findstr('.nii.gz', analyzename))
    randstr = ['temp-' strrep(num2str(rand), '0.', '') '.nii'];
    fileUnzipped = gunzip(analyzename);
    movefile(char(fileUnzipped), randstr);
    [nii.hdr,nii.filetype,nii.fileprefix,nii.machine] = load_nii_hdr(randstr);
    delete(randstr);
else
    [nii.hdr,nii.filetype,nii.fileprefix,nii.machine] = load_nii_hdr(filename);
end

% Return the same header Hui was returning.
header = struct('xsize', 0, 'ysize', 0, 'zsize', 0, ...
        'xvoxelsize', 0.0, 'yvoxelsize', 0.0, 'zvoxelsize', 0.0, 'bytes', 2);

size = nii.hdr.dime.dim;
voxelsize = nii.hdr.dime.pixdim;

header.xsize = double(size(2));
header.ysize = double(size(3));
header.zsize = double(size(4));

header.xvoxelsize = voxelsize(2);
header.yvoxelsize = voxelsize(3);
header.zvoxelsize = voxelsize(4);

header.bytes = double(nii.hdr.dime.bitpix / 8);

% Leave this empty - not needed in Hui's code and the image header
% information is not to be modified.
header.nii.original = [];

header.nii.filetype = nii.filetype;
header.nii.machine  = nii.machine;

return

