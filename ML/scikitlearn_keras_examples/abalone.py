import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from keras.models import Sequential
from keras.layers import Dense
import keras

# Load the data from the CSV file
abalone_df = pd.read_csv('abalone.csv',names=['Sex','Length','Diameter','Height',
                                             'Whole Weight','Shucked Weight',
                                             'Viscera Weight','Shell Weight',
                                             'Rings'])

# Transform sex into a dummy variable using one-hot encoding
abalone_df['Male'] = (abalone_df['Sex']=='M').astype(int)
abalone_df['Female'] = (abalone_df['Sex']=='F').astype(int)
abalone_df['Infant'] = (abalone_df['Sex']=='I').astype(int)
abalone_df = abalone_df[abalone_df['Height']>0]

# Split the data into training and testing
# Don't make the mistake I did and try a pandas DataFrame here; it must be a
# numpy array
train, test = train_test_split(abalone_df, train_size=0.7)
x_train = train.drop(['Rings','Sex'], axis=1).values
y_train = pd.DataFrame(train['Rings']).values
x_test = test.drop(['Rings','Sex'], axis=1).values
y_test = pd.DataFrame(test['Rings']).values


#abalone_model = Sequential([Dense(20, input_dim=10, activation='tanh'), Dense(5, activation='tanh'), Dense(1), ])
abalone_model = Sequential([Dense(20, input_dim=10, activation='relu'), 
Dense(10, activation='relu'), 
Dense(5, activation='relu'), 
Dense(1), ])

abalone_model.compile(optimizer='rmsprop',loss='mse', metrics=['mean_absolute_error'])

tb = keras.callbacks.TensorBoard(log_dir='./logs', histogram_freq=0, write_graph=True, write_images=False)
results = abalone_model.fit(x_train, y_train, nb_epoch=200, verbose=2, callbacks=[tb])
score = abalone_model.evaluate(x_test, y_test)
# The second entry in the array is the MAE
print("\nTesting MAE: {}".format(score[1]))

