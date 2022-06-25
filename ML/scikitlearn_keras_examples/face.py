# library import
from sklearn.datasets import fetch_lfw_people
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
import matplotlib
import numpy as np
from sklearn.decomposition import NMF
from sklearn.decomposition import PCA
from sklearn.cluster import KMeans
# matplotlib 설정
matplotlib.rc('font', family='AppleGothic')
plt.rcParams['axes.unicode_minus'] = False
# people객체 생성
people = fetch_lfw_people(min_faces_per_person=20, resize=0.7, color=False)
image_shape = people.images[0].shape 
# 특성 50개 추출(True)
idx = np.zeros(people.target.shape, dtype=np.bool) # 3023개의 False생성
for target in np.unique(people.target): 
    idx[np.where(people.target == target)[0][:50]] = 1 
# 데이터 추출
x_people = people.data[idx]
y_people = people.target[idx]
# 데이터 분할
x_train, x_test, y_train, y_test = train_test_split( x_people, y_people, stratify=y_people, random_state=0)
# 모델생성 및 학습
nmf = NMF(n_components=100, random_state=0).fit(x_train) 
pca = PCA(n_components=100, random_state=0).fit(x_train)
kmeans = KMeans(n_clusters=100, random_state=0).fit(x_train)
### pca.transform(x_test): 
### pca.inverse_transform(pca.transform(x_test)):
### kmeans.cluster_centers_[kmeans.predict(x_test)] 
x_reconst_nmf = np.dot(nmf.transform(x_test), nmf.components_) # nmf.inverse_transform(nmf.transform(x_test)) 와 동일
x_reconst_pca = pca.inverse_transform(pca.transform(x_test))
x_reconst_kmeans = kmeans.cluster_centers_[kmeans.predict(x_test)]
# visualization
fig, axes = plt.subplots(3, 5, subplot_kw={'xticks':(), 'yticks':()})
for ax, comp_nmf, comp_pca, comp_kmeans in zip(axes.T, nmf.components_, pca.components_, kmeans.cluster_centers_): 
    ax[0].imshow(comp_nmf.reshape(image_shape))
    ax[1].imshow(comp_pca.reshape(image_shape))
    ax[2].imshow(comp_kmeans.reshape(image_shape))
axes[0, 0].set_ylabel('nmf')
axes[1, 0].set_ylabel('pca')
axes[2, 0].set_ylabel('kmeans')
plt.gray()
plt.show()
