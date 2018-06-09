function saveBrainActivityForGenre
    %add path
    addpath functions
    addpath niitools
    %define root
    [folder, ~, ~] = fileparts(which('saveBrainActivityForGenre'));
    root = strcat(folder, '\..\');
    %make output folder
    [status, ~, ~] = mkdir(strcat(root,'output\phase3-2\'));
    assert(status == 1, 'output directory creation failed');
    %read zvalue for each run and genre
    [~,zvalue,label] = extractGenresFeatures;
    %calculate mean for each genre between all run
    meanz = mean(zvalue,1);
    %load a sample of nii file
    nii=  load_untouch_nii(strcat(root,'output\genre\run7\spmT_0004.nii'));
    for i = 1:5
        %overwrite sample data with zvalue
        nii.img = reshape(meanz(1,i,:,:,:),[160 160 36]);
        %trick used in convertnii2mat for view untouch nii
        %header correction
        nii.untouch=0;
        nii.hdr.hist.qform_code=0;
        if exist('time','var')                          % checking time 
             if (time > nii.hdr.dime.dim(5) || time < 1 )% entering an invalid time
             error('time error: time index out of range');
             end
            nii.hdr.dime.dim(5)=1;
            nii.hdr.dime.dim(1)=3; %3D data (time removed)
            img = nii.img(:,:,:,time); %cut a slice
            nii.img = img;
            nii.hdr.hist.originator=[0,0,0];
        else
            nii.hdr.dime.dim(1)=4; %4D data (time removed)
            nii.hdr.hist.originator=[0,0,0];
        end
        view_nii(nii);
        f1.Position(3) = 1000;
        f1.Position(4) = 1000;
        all_fig_path = strcat(root, 'output/phase3-2/', label{i}, '.png');
        saveas(gcf, all_fig_path);
    end
end