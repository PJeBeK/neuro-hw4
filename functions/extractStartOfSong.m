function [labels, starts] = extractStartOfSong(run_id)
    %add path
    addpath('dataset');
    %read tsv file
    fid = fopen(strcat('run-0',num2str(run_id),'_events.tsv'));
    data = textscan(fid,'%f %f %s %d %d %d %d %s %s %d %d %f %f','HeaderLines',1);
    %read start and label of each song
    labels = data{:,3};
    starts = data{:,1};
end