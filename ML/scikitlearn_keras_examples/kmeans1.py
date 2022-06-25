from sklearn.datasets.samples_generator import make_blobs
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
import numpy as np

x, _ = make_blobs(n_samples=300, centers=5, cluster_std=1.1, random_state=1)
plt.scatter(x[:,0], x[:,1])
plt.show()

kmeans = KMeans().fit(x)
print(kmeans)

centers =kmeans.cluster_centers_
labels = kmeans.labels_
print(centers)
print(labels)

plt.scatter(x[:,0], x[:,1], c=labels)
plt.scatter(centers[:,0],centers[:,1], marker='*', color="r",s=80 )
plt.show() 
 
kmeans = KMeans(n_clusters=5).fit(x)
centers =np.array(kmeans.cluster_centers_)
labels = kmeans.labels_

plt.scatter(x[:,0], x[:,1], c=labels)
plt.scatter(centers[:,0],centers[:,1], marker='*', color="r",s=80 )
plt.show()

