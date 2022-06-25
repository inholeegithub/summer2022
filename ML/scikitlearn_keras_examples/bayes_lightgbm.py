from bayes_opt import BayesianOptimization

def learning_rate_005_decay_power_099(current_iter):
    base_learning_rate = 0.05
    lr = base_learning_rate  * np.power(.99, current_iter)
    return lr if lr > 1e-3 else 1e-3

def lgb_f1_score(y_hat, data):
    y_true = data.get_label().astype(int)
    y_hat = np.round(y_hat).astype(int) # scikits f1 doesn't like probabilities
    return 'f1', f1_score(y_true, y_hat, average='weighted'), True


n_folds = 5
random_seed=6

def lgb_eval(num_leaves, feature_fraction, bagging_fraction, max_depth, lambda_l1, lambda_l2, min_split_gain, min_child_weight):
    params = {'application':'binary',
              'num_iterations': 500 , 
              'learning_rate':0.05, 
              'early_stopping_round':100,
              "objective" : "binary",
              "num_threads" : 20 ,
             }
    params["num_leaves"] = int(round(num_leaves))
    params['feature_fraction'] = max(min(feature_fraction, 1), 0)
    params['bagging_fraction'] = max(min(bagging_fraction, 1), 0)
    params['max_depth'] = int(round(max_depth))
    params['lambda_l1'] = max(lambda_l1, 0)
    params['lambda_l2'] = max(lambda_l2, 0)
    params['min_split_gain'] = min_split_gain
    params['min_child_weight'] = min_child_weight
    cv_result = lgb.cv(params, d_train,
                       nfold=n_folds, seed=random_seed, 
                       stratified=True, verbose_eval =200, 
                       metrics=["None"], 
                       feval=lgb_f1_score
                      )
    return max(cv_result['f1-mean'])
lgbBO = BayesianOptimization(lgb_eval, {'num_leaves': (24, 45),
                                        'feature_fraction': (0.1, 0.9),
                                        'bagging_fraction': (0.8, 1),
                                        'max_depth': (5, 8.99),
                                        'lambda_l1': (0, 5),
                                        'lambda_l2': (0, 3),
                                        'min_split_gain': (0.001, 0.1),
                                        'min_child_weight': (5, 50)}, random_state=0)
init_round=5
opt_round = 10
lgbBO.maximize(init_points=init_round, n_iter=opt_round)
lgbBO.points_to_csv("lgb_bayes_opt_result.csv")
params = lgbBO.res['max']['max_params']
lgb2 = lgb.train(params, d_train , 100)
#lgb2 = lgb.train(params, d_train, 100)
lgb_prob = lgb2.predict( lgb_test.values )

##
lgb.plot_importance(lgb2)
plt.show()
feature_importance = pd.DataFrame([lgb2.feature_name() , lgb2.feature_importance()]).T
feature_importance.columns = ["feature", "varimp"]
feature_importance = feature_importance.sort_values(["varimp"], ascending = False)
sns.barplot(y="feature", x="varimp",data = feature_importance)
plt.show()
