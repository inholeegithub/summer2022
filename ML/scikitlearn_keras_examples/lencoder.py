from sklearn.preprocessing import LabelEncoder
from sklearn.preprocessing import OneHotEncoder
from keras.utils import to_categorical
from sklearn import datasets

labels=['dog','cat','cat','mouse','dog','dog']
label_encoder=LabelEncoder()
label_ids=label_encoder.fit_transform(labels)
print(labels)
print(label_ids)

onehot_encoder=OneHotEncoder(sparse=False)
reshaped=label_ids.reshape(len(label_ids), 1)
onehot=onehot_encoder.fit_transform(reshaped)
print(onehot)

to_cat=to_categorical(label_ids)
print(to_cat)

iris= datasets.load_iris()
X = iris.data
Y = iris.target

onehot_encoder=OneHotEncoder(sparse=False)
reshaped=Y.reshape(len(Y), 1)
y_onehot=onehot_encoder.fit_transform(reshaped)
print(Y.shape)
print(y_onehot.shape)

print(Y[0:10])
print(y_onehot[1:10])

