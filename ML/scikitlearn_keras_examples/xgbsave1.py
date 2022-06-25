# Train XGBoost model, save to file using joblib, load and make predictions
from numpy import loadtxt
from xgboost import XGBClassifier
import xgboost as xgb
#from joblib import dump
#from joblib import load
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.preprocessing import LabelEncoder
# load data
dataset = loadtxt('pima-indians-diabetes.csv', delimiter=",")
# split data into X and y
X = dataset[:,0:8]
Y = dataset[:,8]
# split data into train and test sets
seed = 7
test_size = 0.33
X_train, X_test, y_train, y_test = train_test_split(X, Y, test_size=test_size, random_state=seed)
# fit model on training data
model = XGBClassifier()
model.fit(X_train, y_train)
# save model to file
#dump(model, "pima.joblib.dat")
#print("Saved model to: pima.joblib.dat")
model.save_model("my_model.model")

# some time later...

# load model from file
#loaded_model = load("pima.joblib.dat")
#print("Loaded model from: pima.joblib.dat")
#loaded_model = xgb.Booster()
#loaded_model = XGBClassifier()
#loaded_model.load_model("my_model.model")
# make predictions for test data
clf=XGBClassifier()
loaded_model = xgb.Booster()
loaded_model.load_model('my_model.model')
clf._Booster = loaded_model
clf._le = LabelEncoder().fit(y_test)
y_pred_proba = clf.predict_proba(X_test)
predictions = clf.predict(X_test)
#predictions = loaded_model.predict(X_test)
# evaluate predictions
accuracy = accuracy_score(y_test, predictions)
print("Accuracy: %.2f%%" % (accuracy * 100.0))



