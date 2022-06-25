from sklearn.cluster import AgglomerativeClustering
from sklearn.datasets.samples_generator import make_blobs
import matplotlib.pyplot as plt
import numpy as np

np.random.seed(1)
x, _ = make_blobs(n_samples=300, centers=5, cluster_std=.8)
plt.scatter(x[:,0], x[:,1])
plt.show()

aggloclust=AgglomerativeClustering(n_clusters=5).fit(x)
print(aggloclust)
labels = aggloclust.labels_

plt.scatter(x[:,0], x[:,1], c=labels)
plt.show()

f = plt.figure()
f.add_subplot(2, 2, 1)
for i in range(2, 6):
 aggloclust=AgglomerativeClustering(n_clusters=i).fit(x)
 f.add_subplot(2, 2, i-1)
 plt.scatter(x[:,0], x[:,1], s=5, 
    c=aggloclust.labels_, label="n_cluster-"+str(i))
 plt.legend()
plt.show()
