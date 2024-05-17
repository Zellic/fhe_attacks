import sys
import json
import KRD
import numpy as np

def load_samples(f):
    
    lines = f.readlines()
    samples = []
    for l in lines[:-1]:
        d = json.loads(l)
        # We keep only the mask of the ciphertext, not the body
        samples.append(d["data"][:-1])

    d = json.loads(lines[-1])
    debug_sk = d["lwe_secret_key"]["data"]
    return samples, debug_sk

# Read from argument
with open(sys.argv[1], "r") as f:
     samples, debug_sk = load_samples(f)

guessed_sk = KRD.KRD(samples)

h = np.sum(np.abs(np.array(guessed_sk) - np.array(debug_sk)))

print(h)