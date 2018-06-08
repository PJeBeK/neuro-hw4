function labels=extractTValueFromOneRun(genre_grouped,run_id)
    %specify type of extraction (song or genre)
    if genre_grouped == true
        type = 'genre';
    else
        type = 'song';
    end
    %load root
    [folder, ~, ~] = fileparts(which('extractTValueFromOneRun'));
    root = strcat(folder, '\..\');
    %add pathes
    addpath spm12;
    addpath niitools;
    addpath dataset;
    addpath functions;
    %load a saved specify 1st-lvl
    firstlvl = load(strcat(root,'output\specify1lvl.mat'));
    %specify place where scans should be load
    for i = 4:153
        firstlvl.matlabbatch{1,1}.spm.stats.fmri_spec.sess.scans(i-3) = ...
            {strcat(root,'dataset\run-0',num2str(run_id),'_bold.nii,',num2str(i))};
    end
    %specify genres and their starts
    %and set number of stimuli in each run
    if genre_grouped == false
        [labels,starts] = extractStartOfSong(run_id);
        number_of_stimuli = 25;
    else
        [labels,starts] = extractStartOfGenre(run_id);
        number_of_stimuli = 5;
    end
    for i = 1:number_of_stimuli
        firstlvl.matlabbatch{1,1}.spm.stats.fmri_spec.sess.cond(i) = ...
            firstlvl.matlabbatch{1,1}.spm.stats.fmri_spec.sess.cond(1);
        firstlvl.matlabbatch{1,1}.spm.stats.fmri_spec.sess.cond(i).name=labels{i};
        firstlvl.matlabbatch{1,1}.spm.stats.fmri_spec.sess.cond(i).onset=starts(i,:);
    end
    %specify where SPM.mat should be saved
    [status, ~, ~] = mkdir(strcat(root,'output\',type,'\run',num2str(run_id),'\'));
    assert(status == 1, 'output directory creation failed');
    firstlvl.matlabbatch{1,1}.spm.stats.fmri_spec.dir(1) = ...
        {strcat(root,'output\',type,'\run',num2str(run_id))};
    %run specify 1st-lvl
    spm_jobman('run',firstlvl.matlabbatch);
    
    %load a saved estimate
    estimate = load(strcat(root,'output\estimate.mat'));
    %define SPM.mat location
    estimate.matlabbatch{1,1}.spm.stats.fmri_est.spmmat(1) = ...
        {strcat(root,'output\',type,'\run',num2str(run_id),'\SPM.mat')};
    %run estimate
    spm_jobman('run',estimate.matlabbatch);
    
    %load a saved contrast manager
    contrast = load(strcat(root,'output\addcontrast.mat'));
    %define SPM.mat location
    contrast.matlabbatch{1,1}.spm.stats.con.spmmat(1) = ...
        {strcat(root,'output\',type,'\run',num2str(run_id),'\SPM.mat')};
    %define all contrasts
    numbers=1:number_of_stimuli;
    for i = 1:number_of_stimuli
        contrast.matlabbatch{1,1}.spm.stats.con.consess{1,i} = ...
            contrast.matlabbatch{1,1}.spm.stats.con.consess{1,1};
        contrast.matlabbatch{1,1}.spm.stats.con.consess{1,i}.tcon.name = labels{i};
        contrast.matlabbatch{1,1}.spm.stats.con.consess{1,i}.tcon.weights = ....
            (numbers==i).*1;
    end
    %run contrast manger
    spm_jobman('run',contrast.matlabbatch);
end