from sklearn.cluster import MeanShift
from sklearn.datasets.samples_generator import make_blobs
import matplotlib.pyplot as plt
import numpy as np

np.random.seed(1)
x, _ = make_blobs(n_samples=300, centers=5, cluster_std=.8)
plt.scatter(x[:,0], x[:,1])
plt.show()

mshclust=MeanShift(bandwidth=2).fit(x)
print(mshclust) 
 
labels = mshclust.labels_
centers = mshclust.cluster_centers_

plt.scatter(x[:,0], x[:,1], c=labels)
plt.scatter(centers[:,0],centers[:,1], marker='*', color="r",s=80 )
plt.show()

