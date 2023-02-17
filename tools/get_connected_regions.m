function [mask_table] = get_connected_regions(mask_name,connectivity)
% 分离3D脑图中联通的脑区，把获取的激活图中每个相连的簇单独保存为一个mask
%   输入必须为二值图像，mask_name是.nii或者.hdr的文件名
%   connectivit为联通性，通常SPM为18
%   返回mask_table,其中mask是二值脑图，no是编号，voxels是该区域包含的体素数
%   Created by QW 2023.02.17
%% -------------------default argument----------------------%%
if nargin<2
    connectivity = 18;%默认连通性为 18
end
%% ---------------separate connected regions ---------------%%
mask_V = spm_vol(mask_name);
mask_Y = spm_read_vols(mask_V);
L18 = bwlabeln(mask_Y,connectivity);%计算连通性矩阵
voxelList = regionprops3(L18,'VoxelList');%返回联通 voxellist
regionVoxels = regionprops3(L18,'volume');%返回联通 voxel数量统计表
%voxelList(regionVoxels.Volume<50,:)=[]; 剔除小于50voxels的cluster
mask_table = table();
for i = 1:height(voxelList)
    region_mask_i = zeros(91,109,91);
    voxels = voxelList.VoxelList{i};
    for j = 1:height(voxels)
        region_mask_i(voxels(j,2),voxels(j,1),voxels(j,3))=1;
    end
    mask_V.fname = ['region_' num2str(i,'%04d') '.nii'];
%     spm_write_vol(mask_V,region_mask_i); 保存mask为nii文件
    mask_table.mask(i) = {logical(region_mask_i)};
    mask_table.no(i) = i;
    mask_table.voxels(i) = regionVoxels.Volume(i);
end
end

