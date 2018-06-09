function p_values = extractPValues(train_X, train_y)
    nonzero_features = any(train_X);
    train_X = train_X(:, nonzero_features);
    
    features_cnt = size(train_X, 2);
    p_values = ones(1, features_cnt);
    for i = 1:features_cnt
        if (mod(i, 10000) == 1)
            disp(i);
        end
        [p_values(i), ~, ~] = anova1(train_X(:, i), train_y, 'off');
    end
end