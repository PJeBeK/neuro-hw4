function [tvalue,zvalue,label] = extractGenresFeatures
    %load root
    [folder, ~, ~] = fileparts(which('extractTValueFromOneRun'));
    root = strcat(folder, '\..\');
    %create file for output
    [status, ~, ~] = mkdir(strcat(root,'output\genre\'));
    assert(status == 1, 'output directory creation failed');
    %just minimze figures
    set(0, 'DefaultFigureWindowStyle', 'docked');
    %define variables
    tvalue=zeros(8,5,160,160,36);
    zvalue=zeros(8,5,160,160,36);
    %main part
    for run_id = 1:7
        %calculate t-value for each run
        label= extractTValueFromOneRun(true,run_id);
        for i = 1:5
            %read t-value for each genre
            [~,t] = convertnii2mat(strcat(root,'output\genre\run',num2str(run_id),...
                '\spmT_',sprintf('%04d',i),'.nii'),'untouch');
            %close figure
            close;
            %find z-value from t-value
            z = spm_t2z(t,140);
            %stick t-value's together
            tvalue(run_id,i,:) = t(:);
            %stick z-value's together
            zvalue(run_id,i,:) = z(:);
        end
    end
    set(0, 'DefaultFigureWindowStyle', 'normal');
end