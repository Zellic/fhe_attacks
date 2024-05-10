import random

# dimension
n = 64
# ciphertext modulus
q = 2**16+1
# message scaling factor
delta = round(q/2)
# Error variance
sigma = 3.0
#Gaussian error
def normal(): return round(random.gauss(0, sigma))

R = Zmod(q)

def keygen(verbose=False):
    s = vector([R.random_element() for _ in range(n)])
    if verbose:
        print("s = ", s, "\n")
    return s

def encrypt(m, s, verbose=False):
    a = vector([R.random_element() for _ in range(n)])
    e = normal()

    b = int(a * s) + m * delta + e
    if verbose:
        print(f"e = {e}")
        print(f"e = {abs(e):>016b}")
    return (a, b), e

def decrypt(c, s, verbose=False):
    a, b = c
    #m = 0 if abs(b - int(a*s)) <= q//4 else 1
    m = round(2*(b - int(a*s)) / q) % 2
    e = int(b - a*s)
    if verbose:
        print(e)
        print(f"e = {e:>016b}")
        print("m = ", m)
    return m

def enc_add(c1, c2):
    a1, b1 = c1
    a2, b2 = c2
    return ((a1+a2) % q, (b1+b2) % q)

def test_encrypt():
    for _ in range(1000):
        m = randint(0,1)
        s = keygen()
        c, _ = encrypt(m, s)
        assert(m == decrypt(c,s))

def test_add():
    for _ in range(1000):
        m1 = randint(0,1)
        m2 = randint(0,1)
        s = keygen()
        c1, _ = encrypt(m1, s)
        c2, _ = encrypt(m2, s)
        assert((m1 + m2) % 2 == (decrypt(c1,s) + decrypt(c2,s)) % 2)
