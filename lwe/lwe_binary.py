from sage.all import Zmod, vector

import random

class LWE:
    def __init__(self, q=2**16+1, n=64, sigma=3.0):
        # dimension
        self.n = n
        # ciphertext modulus
        self.q = q
         # Error variance
        self.sigma = sigma
        # Ring
        self.R = Zmod(q)

    #Gaussian error
    def normal(self): return round(random.gauss(0, self.sigma))

    def keygen(self, verbose=False):
        s = vector([self.R.random_element() for _ in range(self.n)])
        if verbose:
            print("s = ", s, "\n")
        return s

    def encrypt(self, m, s, verbose=False):
        a = vector([self.R.random_element() for _ in range(self.n)])
        e = self.normal()

        # message scaling factor
        delta = round(self.q/2)

        b = int(a * s) + m * delta + e
        if verbose:
            print(f"e = {e}")
            print(f"e = {abs(e):>016b}")
        return (a, b), e

    def decrypt(self, c, s, verbose=False):
        a, b = c
        #m = 0 if abs(b - int(a*s)) <= q//4 else 1
        m = round(2*(b - int(a*s)) / self.q) % 2
        e = int(b - a*s)
        if verbose:
            print(e)
            print(f"e = {e:>016b}")
            print("m = ", m)
        return m

    def enc_add(self, c1, c2):
        a1, b1 = c1
        a2, b2 = c2
        return ((a1+a2) % self.q, (b1+b2) % self.q)

    def test_encrypt(self):
        for _ in range(1000):
            m = random.randint(0,1)
            s = self.keygen()
            c, _ = self.encrypt(m, s)
            assert(m == self.decrypt(c,s))

    def test_add(self):
        for _ in range(1000):
            m1 = random.randint(0,1)
            m2 = random.randint(0,1)
            s = self.keygen()
            c1, _ = self.encrypt(m1, s)
            c2, _ = self.encrypt(m2, s)
            assert((m1 + m2) % 2 == (self.decrypt(c1,s) + self.decrypt(c2,s)) % 2)
