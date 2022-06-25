# Written by In-Ho Lee, KRISS, May 10, (2019).
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.collections import EventCollection
import numpy as np
import matplotlib
from matplotlib.ticker import (MultipleLocator, FormatStrFormatter, AutoMinorLocator)

majorLocator= MultipleLocator(100)
majorFormatter= FormatStrFormatter('%d')
minorLocator= MultipleLocator(50)
minorLocator= AutoMinorLocator()
aarray=[]
barray=[]
with open('output','r') as afile:
     for line in afile:
         for j in range(len(line.strip().split())):
             if line.strip().split()[j] == 'loss:' :
#                 print(line.strip().split()[j+1])
                  aarray.append(float( line.strip().split()[j+1]))
             if line.strip().split()[j] == 'val_loss:' :
#                 print(line.strip().split()[j+1])
                  barray.append(float( line.strip().split()[j+1]))
na=len(aarray)
nb=len(barray)
aarray=np.array(aarray)
barray=np.array(barray)
#print(na)
#print(nb)
x=np.zeros(na)
for i in range(na):
    x[i]=i

#fig, ax = plt.subplots()
fig, ax = plt.subplots(subplot_kw={'facecolor': "#ebf5ff"})
#plt.annotate('(a)', xy=(0, 0.001), xytext=(0, 0.001), arrowprops=dict(facecolor='black', shrink=0.05),)
#plt.annotate('(a)', xy=(-2.00, 0.001), xytext=(-2.00, 0.001))
# Using set_dashes() to modify dashing of an existing line
#line1, = ax.plot(x, aarray, label='training')
line1, = ax.plot(x, aarray, label='training', ms=1, lw=2, alpha=0.7 , mfc='orange')
line1.set_dashes([2, 2, 10, 2])  # 2pt line, 2pt break, 10pt line, 2pt break
plt.setp(line1,linewidth=1)

# Using plot(..., dashes=...) to set the dashing when creating a line
#line2, = ax.plot(x, barray, dashes=[6, 2], label='test')
line2, = ax.plot(x, barray, dashes=[6, 2], label='validation', ms=2, lw=2, alpha=0.7 , mfc='orange')
line2.set_dashes([3, 0, 10, 0])  # 2pt line, 2pt break, 10pt line, 2pt break
plt.setp(line2,linewidth=1)

#ax.set(xlabel='epoch', ylabel='loss function', title='')
#ax.set_ylabel('title',fontsize=20)
ax.set_xlabel('epoch',fontsize=20)
ax.set_ylabel('loss function',fontsize=20)
ax.legend(fancybox=True, shadow=True, fontsize=15, framealpha=0.8)
ax.xaxis.set_major_locator(majorLocator)
ax.xaxis.set_major_formatter(majorFormatter)
ax.xaxis.set_minor_locator(minorLocator)
minorLocator= AutoMinorLocator()
ax.yaxis.set_minor_locator(minorLocator)
ax.tick_params(which='minor', length=4, color='c')
ax.tick_params(which='major', length=2, color='k')
fig.tight_layout()
#fig.savefig("test.eps")
fig.savefig("loss.pdf")
plt.show()



