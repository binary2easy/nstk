function [data, header] = loadAnalyze(analyzename, realOrGrey)

% loadAnalyze, read an analyze file(.hdr) and output mxArrays
% input   : name of analyze file
%           label of data type, 
%               Short integer UINT32 ('Grey') or 
%               Floating point single ('Real') 
% output  : data and header.
% Grey: UINT32; Real: single


if ~exist(analyzename, 'file');
  error('loadAnalyzeHeader : no such file : %s', analyzename);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if (strfind(analyzename, '.nii.gz'))
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

if ( strcmpi(realOrGrey, 'grey') == 1 )
    data = uint32(data);
elseif (strcmpi(realOrGrey, 'real') == 1)
    data = single(data);
end

if strfind(analyzename, '.hdr')
  % y-flip
  data = flipdim(data, 2);
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


% if ( strcmpi(realORgrey, 'Grey') == 1 )
%     data = uint32(data);
% elseif (strcmpi(realORgrey, 'Real') == 1)
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