% **** PHASE 3 *****

%save images which viewing brain activity for each genre
saveBraingActivityForGenre;

%save images which viewing brain activity for difference between each two
%genres
saveBrainActivityForDifferenceGenre;


% Load libraries and data
addpath('functions')
addpath('dataset')
addpath('niitools')
addpath('spm12')

% **** PHASE 4 *****

% For speed, check if zvalues and labels are already computed.
% if not, compute it and save it for later usage.

if exist('songs_zvalue.mat', 'file') && exist('songs_label.mat', 'file')
    load('songs_label.mat');
    load('songs_zvalue.mat');    
else
    [~, songs_zvalue, songs_label] = extractSongsFeatures();
    save songs_zvalue.mat songs_zvalue
    save songs_label.mat songs_label
end

% Separate train and test data

train_count = 7 * 25;
test_count = 25;
train_X = songs_zvalue(1:train_count, :);
train_y = songs_label(1:train_count);
test_X = songs_zvalue(train_count+1:train_count + test_count, :);

% If not yet caclulated, calculated p-value with all train data and save it
% for later usage

if exist('p_values_no_cross_val.mat', 'file')
    load('p_values_no_cross_val.mat');
else
    p_values_no_cross_val = extractPValues(train_X, train_y);
    save p_values_no_cross_val.mat p_values_no_cross_val
end

% if not yet calculated, calculate p-value once with each run removed(7
% times in total). save it for later usage.

if exist('p_values_cross_val.mat', 'file')
    load('p_values_cross_val.mat');
else
    p_values_cross_val = {};
    for i = 1:7
        out_data = zeros(1, 7 * 25);
        out_data(i * 25 - 24:i * 25) = 1;
        out_data = logical(out_data);
        train_crop_X = train_X(~out_data,:);
        train_crop_y = train_y(~out_data);
        p_values_cross_val{i} = extractPValues(train_crop_X, train_crop_y);
    end
    save p_values_cross_val.mat p_values_cross_val
end 

% generate pictures for analysis using LDA as model and various thresholds
thresholds = [0.001, 0.005, 0.01, 0.02, 0.035];
for threshold = thresholds
    analyzeForThreshold(train_X, train_y, test_X, p_values_cross_val, p_values_no_cross_val, threshold, 'LDA', true);
end

% generate pictures for analysis using SVM as model and various thresholds
thresholds = [0.001, 0.005, 0.01, 0.02, 0.035];
for threshold = thresholds
    analyzeForThreshold(train_X, train_y, test_X, p_values_cross_val, p_values_no_cross_val, threshold, 'SVM', true);
end

% Predict test data using LDA
lda_chosen_threshold = 0.035;
Predicted_Label = analyzeForThreshold(train_X, train_y, test_X, p_values_cross_val, p_values_no_cross_val, lda_chosen_threshold, 'LDA', false);

% Predict test data using SVM
svm_chosen_threshold = 0.020;
Predicted_Label2 = analyzeForThreshold(train_X, train_y, test_X, p_values_cross_val, p_values_no_cross_val, svm_chosen_threshold, 'SVM', false);

% Compare LDA and SVM
heatmap(unique(Predicted_Label2),unique(Predicted_Label2), confusionmat(Predicted_Label, Predicted_Label2, 'order', unique(Predicted_Label2)), 'colormap', jet);
saveas(gcf, 'output/svm_vs_lda_predictions.png');

% Save result of SVM to output
save Predicted_Label.mat Predicted_Label2
