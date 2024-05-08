# Verbosity
verbose=False

def recover_abs_e(ctxt, s):
    m = 0
    k = 0
    c = []
    c.append(ctxt)
    
    print("---- Amplitude search ----")
    while True:
        k += 1
        c.append(enc_add(c[-1],c[-1]))
        m = decrypt(c[-1], s)
        
        if m != 0:
            break
    if verbose:
        print("---- End of amplitude search ----")
        print(f"k = {k}")
    alpha_star = 2**k
    alpha = 2**(k-1)
    ctxt = c[-2]
    
    for i in range(len(c)-2):
        if verbose:
            print(f"{round(q/(4*alpha_star))} <= e <= {round(q/(4*alpha))}")
        m = decrypt(ctxt, s)
        while m == 0:
            tmp = enc_add(ctxt, c[len(c)-i-3])
            m = decrypt(tmp, s)
            if m == 0:
                ctxt = tmp
                alpha += 2**(k-i-2)
        alpha_star = alpha + 2**(k-i-2)
        
        if ceil(q/(4*alpha_star)) == floor(q/(4*alpha)):
            if verbose:
                print(f"Recovered abs(e) = {ceil(q/(4*alpha_star))}")
            return ceil(q/(4*alpha_star))
    return None
                
def binary_attack(s):
    c1 = encrypt(0, s)
    abs_e = recover_abs_e(c1, s)
    print(abs_e)
    c2 = encrypt(0, s)
    abs_e = recover_abs_e(c2, s)
    print(abs_e)
  
def main():
    s = keygen()
    binary_attack(s)