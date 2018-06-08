function test_y = trainModel(train_X, train_y, test_X, p_values, threshold)
    nonzero_features = any(train_X);
    train_X = train_X(:, nonzero_features);
    test_X = test_X(:, nonzero_features);
    model = fitcdiscr(train_X(:, p_values < threshold), train_y);
    test_y = model.predict(test_X(:, p_values < threshold));
    assert(strcmp(model.ClassNames{1}, 'ambient') == 1);
    assert(strcmp(model.ClassNames{2}, 'country') == 1);
    assert(strcmp(model.ClassNames{3}, 'metal') == 1);
    assert(strcmp(model.ClassNames{4}, 'rocknroll') == 1);
    assert(strcmp(model.ClassNames{5}, 'symphonic') == 1);
end
