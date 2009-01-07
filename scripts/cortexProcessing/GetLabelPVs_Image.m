
function LabelPVs_Image = GetLabelPVs_Image(mix)

xsize = mix.header.xsize;
ysize = mix.header.ysize;
zsize = mix.header.zsize;

LabelPVs_Image = zeros([xsize ysize zsize], 'uint32');

if ( isempty(mix.LabelPVs) == 0 )
    LabelPVs_Image(mix.LabelPVs(:)) = 1;
end

return;