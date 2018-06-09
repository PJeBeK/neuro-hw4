function [zvalue,label] = extractDifferenceOfGenresFeatures
    %load root
    [folder, ~, ~] = fileparts(which('extractDifferenceOfGenresFeatures'));
    root = strcat(folder, '\..\');
    %create file for output
    [status, ~, ~] = mkdir(strcat(root,'output\differenceGenre\'));
    assert(status == 1, 'output directory creation failed');
    %just minimze figures
    set(0, 'DefaultFigureWindowStyle', 'docked');
    %define variables
    zvalue=zeros(10,160,160,36);
    %main part
    for run_id = 1:7
        %calculate t-value for each run
        label= extractTValueFromOneRun(run_id,true,true);
        for i = 1:10
            %read t-value for each genre
            [~,t] = convertnii2mat(strcat(root,'output\differenceGenre\run',num2str(run_id),...
                '/spmT_',sprintf('%04d',i),'.nii'),'untouch');
            %close figure
            close;
            %find z-value from t-value
            z = spm_t2z(t,140);
            %sum z-value's together
            zvalue(i,:,:,:) = zvalue(i,:,:,:) + reshape(z, [1 160 160 36]);
        end
    end
    %divide by number of run (for mean)
    zvalue = zvalue./7;
    set(0, 'DefaultFigureWindowStyle', 'normal');
end