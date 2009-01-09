function [data, header] = loadAnalyze(analyzename, realOrGrey)

% loadAnalyze, read an analyze file(.hdr) and output mxArrays
% input: name of analyze file, label of Grey image('Grey') or Real image('Real')
% output:data, header
% Grey: UINT32; Real: single
%
% reimplement this function using the matlab analyze75read
%
% [data, header] = LoadAnalyze_mex(analyzename, realOrGrey);
% header
%
% argument is 'analyzename' but can load nii also...
%
% still need to incorporate ability to open *.nii.gz files.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Modified version of Hui's script. Try and wrap Jimmy Shen's NIFTI i/o
% scripts into this one.

if (findstr('.nii.gz', analyzename))
    randstr = ['temp-' strrep(num2str(rand), '0.', '') '.nii'];
    fileUnzipped = gunzip(analyzename);
    movefile(char(fileUnzipped), randstr);
    nii = load_nii(randstr);
    delete(randstr);
else
    nii = load_nii(analyzename);
end


data = nii.img;

if (nargin < 2)
    realOrGrey = 'Real';
end

if ( strcmp(realOrGrey, 'Grey') == 1 )
    data = uint32(data);
elseif (strcmp(realOrGrey, 'Real') == 1)
    data = single(data);
end

% Hui was flipping the data before, really not sure why this is needed if
% we're reading an hdr/img pair.
% data(1:header.ysize, : ,:) = data(header.ysize:-1:1, : ,:);
if findstr('.hdr', analyzename)
  data = flipdim(data, 2); % y-flip
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

header.bytes = double(nii.original.hdr.dime.bitpix / 8);

header.nii.hdr = nii.hdr;
header.nii.original = nii.original;
header.nii.filetype = nii.filetype;
header.nii.machine  = nii.machine;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function [data, header] = loadAnalyze(analyzename, realORgrey)

% savedDir = pwd;
% [tempPath, tempName, tempExt, tempVer] = fileparts(analyzename);
% if (isdir(tempPath))
%     cd (tempPath);
% end
% %info = analyze75info(analyzename);
% info = analyze75info(tempName);
% data = analyze75read(info);
% cd (savedDir);


% if ( strcmp(realORgrey, 'Grey') == 1 )
%     data = uint32(data);
% elseif (strcmp(realORgrey, 'Real') == 1)
%     data = single(data);
% end

% header = struct('xsize', 0, 'ysize', 0, 'zsize', 0, ...
%         'xvoxelsize', 0.0, 'yvoxelsize', 0.0, 'zvoxelsize', 0.0, 'bytes', 2);
% header.xsize = double(info.Dimensions(1));
% header.ysize = double(info.Dimensions(2));
% header.zsize = double(info.Dimensions(3));
% header.xvoxelsize = info.PixelDimensions(1);
% header.yvoxelsize = info.PixelDimensions(2);
% header.zvoxelsize = info.PixelDimensions(3);
% header.bytes = double(info.BitDepth/8);
% header;

% data(1:header.ysize, : ,:) = data(header.ysize:-1:1, : ,:);