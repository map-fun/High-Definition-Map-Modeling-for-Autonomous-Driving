%%
%
%
%
%
clear all;
%
addpath('..\patchGenerator\');
% load classifier
load 12_raw.mat
%
image_dir = '..\data\set3\';
save_dir = '..\data\set3\';

image_names = dir(strcat(image_dir,'*.png'));
%
PATCH_SIZE = 12;
STEP = PATCH_SIZE/6;
%
parfor j = 810:940
    % load satellite image
    satellite = imread(strcat(image_dir,num2str(j),'_satellite.png'));
    satellite = double(satellite)/255;
    % load mask image
    mask = imread(strcat(image_dir,num2str(j),'_chunkmask.png'));
    [maskX, maskY] = find(mask==255);
    minX = min(maskX);
    maxX = max(maskX);
    minY = min(maskY);
    maxY = max(maskY);
    % crop it
%     [patch, idx] = decompose(satellite, PATCH_SIZE, STEP,...
%                     [1 size(satellite,1) 1 size(satellite,2)]);
    [patch, idx] = decompose(satellite, PATCH_SIZE, STEP,...
                    [minX-PATCH_SIZE maxX+PATCH_SIZE minY-PATCH_SIZE maxY+PATCH_SIZE]);
    % heatmap
    heatmap = zeros(size(satellite,1), size(satellite,2));
    % visit each patch
    for i = 1:size(idx,1)
        % patch feature
        cpatch = patch(:,:,i);
        % predict
        [result, score] = predict(b, cpatch(:)');
        %
        heatmap(idx(i,1):idx(i,1)+PATCH_SIZE-1,idx(i,2):idx(i,2)+PATCH_SIZE-1) = ...
                    score(2) + heatmap(idx(i,1):idx(i,1)+PATCH_SIZE-1,idx(i,2):idx(i,2)+PATCH_SIZE-1);
    end%endfor i

%     imshow(myheatmap(heatmap));
    imwrite(myheatmap(heatmap),strcat(save_dir, num2str(j),'_heat.png'));
    imwrite(heatmap/max(max(heatmap)),strcat(save_dir, num2str(j),'_prob.png'));
    disp(j)
end