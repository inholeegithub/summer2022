import numpy as np
from keras.datasets import fashion_mnist

from image_helper_old import ImageHelper
from aae import AAE

(X, _), (_, _) = fashion_mnist.load_data()
X_train = X / 127.5 - 1.
X_train = np.expand_dims(X_train, axis=3)

image_helper = ImageHelper()
aae = AAE(X_train[0].shape, image_helper)
aae.train(30001, X_train, batch_size=32)
