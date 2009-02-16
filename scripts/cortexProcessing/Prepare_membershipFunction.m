
p = dir('post_wm1_Real.hdr');
if ( isempty(p) == 0 )
    filename = 'post_wm1_Real.hdr';
    [post_wm1_Real, header] = LoadAnalyze(filename, 'Real');

    filename = 'post_wm2_Real.hdr';
    [post_wm2_Real, header] = LoadAnalyze(filename, 'Real');

    post_wm_Real = post_wm1_Real + post_wm2_Real;

    SaveAnalyze(post_wm_Real, header, 'post_wm_Real.hdr', 'Real');
end
