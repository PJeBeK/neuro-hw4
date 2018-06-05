function [genres_name, starts] = extractStartOfStimulis(run_id)
    addpath('dataset');
    fid = fopen(strcat('run-0',num2str(run_id),'_events.tsv'));
    data = textscan(fid,'%f %f %s %d %d %d %d %s %s %d %d %f %f','HeaderLines',1);
    genres = data{:,3};
    seconds = data{:,1};
    starts = zeros(5);
    cnt=ones(1,5);
    list=1:5;
    genres_name={'rocknroll','symphonic','metal','country','ambient'};
    for i=1:25
        x=sum(strcmp(genres(i),genres_name).*list);
        starts(x,cnt(x))=seconds(i);
        cnt(x) = cnt(x) + 1;
    end
end