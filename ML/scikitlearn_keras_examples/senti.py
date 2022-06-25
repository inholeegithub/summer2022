import pandas as pd
import nltk
import random
from nltk.tokenize import word_tokenize

poss = pd.read_csv('pos_sentiment.csv')
negs = pd.read_csv('neg_sentiment.csv')
poss.columns = ["text"]
negs.columns = ["text"]

data=([(pos['text'], 'positive') for index, pos in poss.iterrows()]+
    [(neg['text'], 'negative') for index, neg in negs.iterrows()])

tokens=set(word.lower() for words in data for word in word_tokenize(words[0]))
train=[({word:(word in word_tokenize(x[0])) \
         for word in tokens}, x[1]) for x in data]

print(tokens)
print(train[0])

random.shuffle(train)
train_x=train[0:50]
test_x=train[51:55]

model = nltk.NaiveBayesClassifier.train(train_x)
acc=nltk.classify.accuracy(model, test_x)
print("Accuracy:", acc)

model.show_most_informative_features()

tests=['I really like it', 
    'I do not think this is good one', 
    'this is good one',
    'I hate the show!']

for test in tests:
 t_features = {word: (word in word_tokenize(test.lower())) for word in tokens}
 print(test," : ", model.classify(t_features)) 

