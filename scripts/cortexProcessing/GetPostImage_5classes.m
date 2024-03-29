function [post_csf, post_wm1, post_wm2, post_gm, post_outlier] = GetPostImage_5classes(mix, header, post)

% transform posterior as image file

xsize = header.xsize;
ysize = header.ysize;
zsize = header.zsize;

post_csf     = zeros([xsize ysize zsize], 'uint16');
post_wm1     = zeros([xsize ysize zsize], 'uint16');
post_wm2     = zeros([xsize ysize zsize], 'uint16');
post_gm      = zeros([xsize ysize zsize], 'uint16');
post_outlier = zeros([xsize ysize zsize], 'uint16');

num = size(post, 1);
% prior: csf, cortex, wm1, wm2, outlier

for i = 1:num
    
    if ( abs(sum(post(i,:)) - 1) > 0.0001 )
        continue;
    end
    
    if ( (isempty(find(post(i,:) > 1)) == 0) || (isempty(find(post(i,:) < 0)) == 0) )
        maxP = max(post(i,:));
        minP = min(post(i,:));
        
        if ( (maxP>1) | (minP<-1) )
            post(i,:)
        end
        
        post(i,:) = (post(i,:) - minP) ./ (maxP - minP);
        post(i,:) = post(i,:)          ./ sum(post(i,:));
    end
    
    row   = mix.indexes(i, 1);
    col   = mix.indexes(i, 2);
    depth = mix.indexes(i, 3);
    
    post_csf(row, col, depth)     = round(uint16( 2048 * post(i,1) ));
    post_gm(row, col, depth)      = round(uint16( 2048 * post(i,2) ));
    post_wm1(row, col, depth)     = round(uint16( 2048 * post(i,3) ));
    post_wm2(row, col, depth)     = round(uint16( 2048 * post(i,4) ));
    post_outlier(row, col, depth) = 2048 - post_csf(row, col, depth) - post_gm(row, col, depth) - post_wm1(row, col, depth) - post_wm2(row, col, depth);
end

return;