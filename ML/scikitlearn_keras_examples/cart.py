import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.datasets import load_iris
from sklearn.tree import DecisionTreeClassifier
from sklearn.tree import DecisionTreeRegressor
from sklearn.utils import shuffle
np.random.seed(123)
#rn.seed(1234)
#tf.set_random_seed(210)
iris = load_iris()
#X = iris.data[:, 2:] # petal length and width
#y = iris.target
X = iris.data[:,:4]
y = iris.target
X, y = shuffle(X,y,random_state=0)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
tree_reg = DecisionTreeRegressor(max_depth=4)
tree_reg.fit(X_train, y_train)

from sklearn.tree import export_graphviz
export_graphviz( tree_reg, out_file="iris_tree.dot", feature_names=iris.feature_names[:4],class_names=iris.target_names, rounded=True, filled=True)

print(tree_reg.predict([[4., 3., 5., 4.]]))

# dot -Tpng iris_tree.dot -o iris_tree.png
# display iris_tree.png
