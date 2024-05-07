import random

# dimension
n = 64
# ciphertext modulus
q = 2**16
# message scaling factor
delta = q//2
# Error variance
sigma = 40.0
#Gaussian error
def normal(): return abs(round(random.gauss(0, sigma)))
# Verbosity
verbose=False

R = Zmod(q)

def keygen():
    s = vector([R.random_element() for _ in range(n)])
    if verbose:
        print("s = ", s, "\n")
    return s

def encrypt(m, s):
    a = vector([R.random_element() for _ in range(n)])
    e = normal()
    print(e)
    b = a * s + m * delta + e
    if verbose:
        print(f"e = {e:>016b}")
    return (a, b)

def decrypt(c, s):
    a, b = c
    m = 0 if int(b - a*s) <= q//4 else 1
    e = int(b - a*s)
    if verbose:
        print(f"e = {e:>016b}")
        print("m = ", m & 1)
    return m & 1

def enc_add(c1, c2):
    a1, b1 = c1
    a2, b2 = c2
    return ((a1+a2) % q, (b1+b2) % q)

def test_encrypt():
    for _ in range(1000):
        m = randint(0,1)
        s = keygen()
        c = encrypt(m, s)
        assert(m == decrypt(c,s))

def test_add():
    for _ in range(1000):
        m1 = randint(0,1)
        m2 = randint(0,1)
        s = keygen()
        c1 = encrypt(m1, s)
        c2 = encrypt(m2, s)
        assert((m1 + m2) % 2 == (decrypt(c1,s) + decrypt(c2,s)) % 2)
    
def main():
    s = keygen()