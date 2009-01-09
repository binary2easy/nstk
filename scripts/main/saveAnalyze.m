function saveAnalyze(data, header, analyzename, realORgrey)

% saveAnalyze, save data and headr as an analyze file(.hdr)
% input: data, header, name of analyze file, label of Grey image('Grey') or Real image('Real')
% output: 0 normal 1 failed
% Grey: UINT32; Real: single
%
% Modified version of Hui's script. Try and wrap Jimmy Shen's NIFTI i/o
% scripts into this one.
%
%
% saveAnalyze(data, header, analyzename, realORgrey)
%
% argument is 'analyzename' but can save nii also...
%
% still need to incorporate ability to save to *.nii.gz files.



pixdims = [header.xvoxelsize header.yvoxelsize header.zvoxelsize];

if ( strcmp(realORgrey, 'Grey') == 1 )
  % Signed short
  datatype = 4;
  bitpix   = 16;
elseif (strcmp(realORgrey, 'Real') == 1)
  % Single / float32
  datatype = 16;
  bitpix   = 32;
end

dims = [header.xsize header.ysize header.zsize];

origin = 0.5 * (dims + ones(size(dims))) ;

nii = make_nii(data, pixdims, origin, datatype);

% Writing to nii?
if findstr('.nii', analyzename)
    % Have sensible qform or sform info?
    if (header.nii.original.hdr.hist.qform_code || header.nii.original.hdr.hist.sform_code)
        % restore header.
        nii.hdr = header.nii.original.hdr;
        % But adhere to data type required.
        nii.hdr.dime.datatype = datatype;
        nii.hdr.dime.bitpix   = bitpix;
    end
end

% Undo the reorientation that would have been done on loading (see
% nifti/load_nii nifti/xform_nii).

rot_orient  = header.nii.hdr.hist.rot_orient;
flip_orient = header.nii.hdr.hist.flip_orient;

if (~isempty(rot_orient))
  % Note: Inverse permutation.
  nii.img = ipermute(nii.img, rot_orient);
  
  if (~isempty(flip_orient))
    [dummy, inv_rot_orient] = sort(rot_orient);
    flip_orient = flip_orient(inv_rot_orient);
    
    for i = 1:3
      if flip_orient(i)
        nii.img = flipdim(nii.img, i);
      end
    end
  end
end


if (findstr('.gz',analyzename))
    % Prepare for a bit of name-mangling in save_nii
    analyzename = strrep(analyzename,'.gz','');
    save_nii(nii, analyzename);
    gzip(analyzename);
    delete(analyzename);
else
    % Just save the nifti file, no compression.
    save_nii(nii, analyzename);
end


return

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% nii.hdr      = header.nii.original.hdr;
% nii.original = header.nii.original;
% nii.filetype = header.nii.filetype;
% nii.machine  = header.nii.machine;
% 
% if findstr('.nii', analyzename)
%   fileprefix = strrep(analyzename,'.nii','');
% end
%    
% if findstr('.hdr', analyzename)
%   fileprefix = strrep(analyzename,'.hdr','');
% end
% 
% nii.fileprefix = fileprefix;
% 
% nii.img = data;
% 
% save_nii(nii, analyzename);


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% nii.hdr.hk.sizeof_hdr    = 348;
% nii.hdr.hk.data_type     = '';
% nii.hdr.hk.db_name       = '';
% nii.hdr.hk.extents       = 0;
% nii.hdr.hk.session_error = 0;
% nii.hdr.hk.regular       = 'r';
% nii.hdr.hk.dim_info      = 0;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% dims = [header.xsize header.ysize header.zsize];
% nii.hdr.dime.dim            = [4 dims 1 1 1 1];

% nii.hdr.dime.intent_p1      = 0;
% nii.hdr.dime.intent_p2      = 0;
% nii.hdr.dime.intent_p3      = 0;
% nii.hdr.dime.intent_code    = 0;

% if ( strcmp(realORgrey, 'Grey') == 1 )
%   % Signed short
%   nii.hdr.dime.datatype       = 4;
%   nii.hdr.dime.bitpix         = 16;
% elseif (strcmp(realORgrey, 'Real') == 1)
%   % Single / float32
%   nii.hdr.dime.datatype       = 16;
%   nii.hdr.dime.bitpix         = 32;
% end

% nii.hdr.dime.slice_start    = 0;

% pixdims = [header.xvoxelsize header.yvoxelsize header.zvoxelsize];
% nii.hdr.dime.pixdim         = [1 pixdims 1 0 0 0];

% nii.hdr.dime.vox_offset     = 352;
% nii.hdr.dime.scl_slope      = 0;
% nii.hdr.dime.scl_inter      = 0;
% nii.hdr.dime.slice_end      = 0;
% nii.hdr.dime.slice_code     = 0;
% nii.hdr.dime.xyzt_units     = 10;
% nii.hdr.dime.cal_max        = 0;
% nii.hdr.dime.cal_min        = 0;
% nii.hdr.dime.slice_duration = 0;
% nii.hdr.dime.toffset        = 0;
% nii.hdr.dime.glmax          = 1;
% nii.hdr.dime.glmin          = 0;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% nii.hdr.hist.descrip     = '';
% nii.hdr.hist.aux_file    = '';
% nii.hdr.hist.qform_code  = 0;
% nii.hdr.hist.sform_code  = 0;
% nii.hdr.hist.quatern_b   = 0;
% nii.hdr.hist.quatern_c   = 0;
% nii.hdr.hist.quatern_d   = 0;

% temp = dims - ones(size(dims));
% temp = -0.5 * temp;
% temp = temp .* pixdims;

% nii.hdr.hist.qoffset_x   = temp(1);
% nii.hdr.hist.qoffset_y   = temp(2);
% nii.hdr.hist.qoffset_z   = temp(3);

% nii.hdr.hist.srow_x      = [0 0 0 0];
% nii.hdr.hist.srow_y      = [0 0 0 0];
% nii.hdr.hist.srow_z      = [0 0 0 0];
% nii.hdr.hist.intent_name = '';
% nii.hdr.hist.magic       = 'n+1';

% temp = ones(size(dims)) + floor(dims / 2);

% nii.hdr.hist.originator  = [temp 0 0]

% nii.hdr.hist.rot_orient  = []
% nii.hdr.hist.flip_orient = []

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% nii.filetype = 2;

% if findstr('.nii', analyzename)
%   fileprefix = strrep(analyzename,'.nii','');
% end
   
% if findstr('.hdr', analyzename)
%   fileprefix = strrep(analyzename,'.hdr','');
% end

% nii.fileprefix = fileprefix;

% nii.machine =  'ieee-le';

% nii.img = data;

% save_nii(nii, analyzename);
