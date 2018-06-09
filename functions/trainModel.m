function test_y = trainModel(train_X, train_y, test_X, p_values, threshold, model_type)
    nonzero_features = any(train_X);
    train_X = train_X(:, nonzero_features);
    test_X = test_X(:, nonzero_features);
    train_X = train_X(:, p_values < threshold);
    test_X = test_X(:, p_values < threshold);
    if strcmp(model_type, 'LDA') == 1
        model = fitcdiscr(train_X, train_y);
        test_y = model.predict(test_X);
        assert(strcmp(model.ClassNames{1}, 'ambient') == 1);
        assert(strcmp(model.ClassNames{2}, 'country') == 1);
        assert(strcmp(model.ClassNames{3}, 'metal') == 1);
        assert(strcmp(model.ClassNames{4}, 'rocknroll') == 1);
        assert(strcmp(model.ClassNames{5}, 'symphonic') == 1);
    else
        labels = {'ambient', 'country', 'metal', 'rocknroll', 'symphonic'};
        predict_score = zeros(size(test_X, 1), size(labels, 2));
        for i = 1:size(labels, 2)
            model = fitcsvm(train_X, strcmp(train_y, labels{i}));
            [~, tmp] = model.predict(test_X);
            predict_score(:, i) = tmp(:, 2);
        end
        [~, idx] = max(predict_score, [], 2);
        test_y = cell(size(test_X, 1), 1);
        for i = 1:size(test_X, 1)
            test_y{i} = labels{idx(i)};
        end
    end
end
