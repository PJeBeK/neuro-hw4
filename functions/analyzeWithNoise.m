function [Predicted_Label, train_accr, val_accr] = analyzeWithNoise(...
    train_X, ...
    train_y, ...
    test_X, ...
    p_values_cross_val, ...
    p_values_no_cross_val, ...
    threshold, ...
    model_type, ...
    generate_pic)

    %load root
    [folder, ~, ~] = fileparts(which('analyzeForThreshold'));
    root = strcat(folder, '/../');
    %create file for output
    [status, ~, ~] = mkdir(strcat(root,'output'));
    assert(status == 1, 'output directory creation failed');
    [status, ~, ~] = mkdir(strcat(root,'output/', model_type));
    assert(status == 1, 'output directory creation failed');
    
    labels = {'ambient', 'country', 'metal', 'rocknroll', 'symphonic'};
    
    % Train model with full data

    predict_y = trainModel(train_X, train_y, train_X, p_values_no_cross_val, threshold, model_type);
    confusion_matrix_no_cross_val = confusionmat(train_y, predict_y, 'order', labels);
    
    % Perform cross-validation

    confusion_matrix = zeros(5, 5);
    accuracies = zeros(1, 5);
    for i = 1:7
        out_data = zeros(1, 14 * 25);
        out_data(i * 25 - 24:i * 25) = 1;
        out_data((i + 7) * 25 - 24:(i + 7) * 25) = 1;
        out_data = logical(out_data);
        train_crop_X = train_X(~out_data,:);
        train_crop_y = train_y(~out_data);
        val_X = train_X(out_data,:);
        val_y = train_y(out_data);
        predict_y = trainModel(train_crop_X, train_crop_y, val_X, p_values_cross_val{i}, threshold, model_type);
        cur_conf_mat = confusionmat(val_y, predict_y, 'order', labels);
        accuracies(i) = trace(cur_conf_mat) / 50;
        confusion_matrix = confusion_matrix + cur_conf_mat;
    end
    confusion_matrix = confusion_matrix / 14;
    
    train_accr = trace(confusion_matrix_no_cross_val) / (14 * 25);
    val_accr = mean(accuracies);

    avg_features = 0;
    for i = 1:7
        avg_features = avg_features + sum(p_values_cross_val{i} < threshold);
    end
    avg_features = avg_features / 7;
    
    Predicted_Label = trainModel(train_X, train_y, test_X, p_values_no_cross_val, threshold, model_type);
    
    % If required, generate a picture
    
    if ~generate_pic
        return
    end
    f1 = figure('visible', 'off');
    
    % Draw confusion matrix for full train
    
    subplot(5, 2, [1 3 5 7]);
    heatmap(labels, labels, confusion_matrix_no_cross_val / 70 * 100, 'colormap', jet, 'ColorLimits', [0 100]);
    title('Confusion matrix with full train');

    % Draw confusion matrix for CV
    
    subplot(5, 2, [2 4 6 8]);
    heatmap(labels, labels, confusion_matrix / 5 * 100, 'colormap', jet, 'ColorLimits', [0 100]);
    title('Cross validated confusion matrix');
    
    % Print accuracy and features average

    subplot(5, 2, [9 10]);
    xlim = get(gca, 'XLim');
    ylim = get(gca, 'YLim');
    set(gca, 'Visible', 'off');
    descr = {
        "Accruacy: avg:" + round(mean(accuracies), 2) * 100 + "%" + ...
        " std: " + round(std(accuracies), 2) * 100 + "%",...
        "Average number of features:" + round(avg_features)};
    text((xlim(1) + xlim(2)) / 10, (ylim(1) + ylim(2)) / 2, descr);

    f1.Position(3) = 1400;
    f1.Position(4) = 600;
    saveas(f1, strcat(root,'output/', model_type, '/', strrep(num2str(threshold, '%.3f'), '.', '_'), '.png'));
    close(f1);
end