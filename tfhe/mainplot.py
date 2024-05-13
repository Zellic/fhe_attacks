import py_stdin
import KRD
import math
import numpy as np
import matplotlib.pyplot as plt
# Read from the standard input
(samples, debug_sk) = py_stdin.recover_lists(py_stdin.read_stdin())

lwe_dimension = 600
f = len(samples)
scores = []
x = []
for k in range(0, 1+int(np.log(f)/np.log(2))):
    i=2**k
    x.append(i)
    guessed_sk = KRD.KRD(samples[:i])
    scores.append(lwe_dimension-np.sum(abs(np.array(debug_sk)-np.array(guessed_sk))))

print(scores)
print(f)
plt.title('CRASH')
plt.grid()
plt.plot(x, scores)
plt.ylabel('Number of key coefficient recovered')
plt.xlabel('Number of decryption failures collected')
plt.gcf().axes[0].set_xscale('log')
plt.title("Performances of the attack depending on the number of samples")

plt.show()