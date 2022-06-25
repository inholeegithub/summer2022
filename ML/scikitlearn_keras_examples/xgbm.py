

iter_ = 0 
best_error = 0
best_iter = 0
best_model = None

col_sample_rates = [0.1, 0.5, 0.9]
subsamples = [0.1, 0.5, 0.9]
etas = [0.01, 0.001]
max_depths = [3, 6, 12, 15, 18]
reg_alphas = [0.01, 0.001]
reg_lambdas = [0.01, 0.001]
ntrees = [200, 400]

total_models = len(col_sample_rates)*len(subsamples)*len(etas)*len(max_depths)*len(reg_alphas)*len(reg_lambdas)*len(ntrees)

# determine mean y value in training
y_mean = train[y].mean()

for col_sample_rate in col_sample_rates:
    for subsample in subsamples:
        for eta in etas:
            for max_depth in max_depths:
                for reg_alpha in reg_alphas:
                    for reg_lambda in reg_lambdas:
                        for ntree in ntrees:

                            tic = time.time()

                            print('---------- ---------')

                            print('Training model %d of %d ...' % (iter_ + 1, total_models))
                            print('col_sample_rate =', col_sample_rate)
                            print('subsample =', subsample)
                            print('eta =', eta)
                            print('max_depth =', max_depth)
                            print('reg_alpha =', reg_alpha)
                            print('reg_lambda =', reg_lambda)
                            print('ntree =', ntree)

                            params = {
                                 'base_score': y_mean,
                                 'booster': 'gbtree',
                                 'colsample_bytree': col_sample_rate,
                                 'eta': eta,
                                 'eval_metric': 'auc',
                                 'max_depth': max_depth,
                                 'nthread': 4,
                                 'objective': 'binary:logistic',
                                 'reg_alpha': reg_alpha,
                                 'reg_lambda': reg_lambda,
                                 'monotone_constraints': mono_constraints,
                                 'seed': 12345,
                                 'silent': 0,
                                 'subsample': subsample}

                            watchlist = [(dtrain, 'train'), (dtest, 'eval')]

                            model = xgb.train(
                                            params, 
                                            dtrain, 
                                            ntree,
                                            early_stopping_rounds=100,
                                            evals=watchlist, 
                                            verbose_eval=False)

                            print('Model %d trained in %.2f s.'  % (iter_, time.time()-tic))
                            print('Model %d best score = %.4f' % (iter_, model.best_score))

                            if model.best_score > best_error:
                                best_error = model.best_score
                                best_iter = iter_
                                best_model = model 
                                print('Best so far!!!')
                                print('Best error =', best_error)


                            iter_ += 1

print('Best model found at iteration: %d, with error: %.4f.' % (best_iter + 1, best_error))  
