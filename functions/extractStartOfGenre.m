function [labels, starts] = extractStartOfGenre(run_id)
    %add path
    addpath('dataset');
    %read tsv file
    fid = fopen(strcat('run-0',num2str(run_id),'_events.tsv'));
    data = textscan(fid,'%f %f %s %d %d %d %d %s %s %d %d %f %f','HeaderLines',1);
    %read genre and start of each file
    genres = data{:,3};
    seconds = data{:,1};
    %define some variable
    starts = zeros(5);
    cnt=ones(1,5);
    list=1:5;
    labels={'rocknroll','symphonic','metal','country','ambient'};
    %put each song in it's genre
    for i=1:25
        x=sum(strcmp(genres(i),labels).*list);
        starts(x,cnt(x))=seconds(i);
        cnt(x) = cnt(x) + 1;
    end
end
%spm_jobman('run',matlabbatch)