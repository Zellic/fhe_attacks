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

    def encrypt(self, m, s, verbose=False, return_e=False):
        a = vector([self.R.random_element() for _ in range(self.n)])
        e = self.normal()

        # message scaling factor
        delta = round(self.q/2)

        b = int(a * s) + m * delta + e
        if verbose:
            print(f"e = {e} ({e:016b})")
        if return_e:
            return (a, b), e
        return (a, b)

    def decrypt(self, c, s, verbose=False):
        a, b = c
        m = round(2*(b - int(a*s)) / self.q) % 2
        e = int(b - a*s)
        if verbose:
            print(f"e = {e} ({e:016b})")
        return m

    def enc_add(self, c1, c2):
        a1, b1 = c1
        a2, b2 = c2
        return ((a1+a2) % self.q, (b1+b2) % self.q)

    def test_encrypt(self):
        for _ in range(1000):
            m = random.randint(0,1)
            s = self.keygen()
            c = self.encrypt(m, s)
            assert(m == self.decrypt(c,s))

    def test_add(self):
        for _ in range(1000):
            m1 = random.randint(0,1)
            m2 = random.randint(0,1)
            s = self.keygen()
            c1 = self.encrypt(m1, s)
            c2 = self.encrypt(m2, s)
            assert((m1 + m2) % 2 == (self.decrypt(c1,s) + self.decrypt(c2,s)) % 2)
