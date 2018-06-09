function [tvalue,zvalue,label] = extractSongsFeatures
    %load root
    [folder, ~, ~] = fileparts(which('extractTValueFromOneRun'));
    root = strcat(folder, '\..\');
    %create file for output
    [status, ~, ~] = mkdir(strcat(root,'output\song\'));
    assert(status == 1, 'output directory creation failed');
    %just minimze figures
    set(0, 'DefaultFigureWindowStyle', 'docked');
    %define variables
    tvalue=zeros(200,160*160*36);
    zvalue=zeros(200,160*160*36);
    label = cell(1,200);
    %main part
    for run_id = 1:8
        %calculate t-value for each run
        label(run_id*25-24:run_id*25) = extractTValueFromOneRun(run_id,false,false);
        for i = 1:25
            [~,t] = convertnii2mat(strcat(root,'output\song\run',num2str(run_id),...
                '\spmT_',sprintf('%04d',i),'.nii'),'untouch');
            %close figure
            close;
            %find z-value from t-value
            z = spm_t2z(t,120);
            %stick t-value's together
            tvalue(run_id*25+i-25,:) = t(:);
            %stick z-value's together
            zvalue(run_id*25+i-25,:) = z(:);
        end
    end
    set(0, 'DefaultFigureWindowStyle', 'normal');
end