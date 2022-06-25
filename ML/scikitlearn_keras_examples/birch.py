from sklearn.cluster import Birch
import numpy as np
import matplotlib.pyplot as plt
np.random.seed(12)
p1 = np.random.randint(5,21,110) 
p2 = np.random.randint(20,30,120)
p3 = np.random.randint(8,21,90)
data = np.array(np.concatenate([p1, p2, p3]))
x_range = range(len(data))
x = np.array(list(zip(x_range, data))).reshape(len(x_range), 2)
plt.scatter(x[:,0], x[:,1])
plt.show()
bclust=Birch(branching_factor=100, threshold=.5).fit(x)
print(bclust)
labels = bclust.predict(x)
plt.scatter(x[:,0], x[:,1], c=labels)
plt.show()
