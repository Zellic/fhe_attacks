# Verbosity

def check_same_sign(c1, c2, s):
    c = enc_add(c1, c2)
    if decrypt(c,s) == 1:
        return True
    else:
        return False

def amplitude_search(ctxt, s, verbose=False):
    k = 0
    c_list = []
    c_list.append(ctxt)
    if verbose:
        print("---- Amplitude search ----")
    while True:
        k += 1
        c_list.append(enc_add(c_list[-1], c_list[-1]))
        m = decrypt(c_list[-1], s, verbose=verbose)
        
        if m != 0:
            break
        if 2**k > q/4:
            if verbose:
                print(f"Recovered abs(e) = 0")
            return 0, ctxt
    if verbose:
        print("---- End of amplitude search ----")
        print(f"k = {k}")
    return k, c_list

def recover_abs_e(ctxt, s, verbose=False):
    m = 0
    k, c_list = amplitude_search(ctxt, s, verbose)
    alpha_star = 2**(k)
    alpha = 2**(k-1)
    ctxt = c_list[-2]
    
    for i in range(len(c_list)-2):
        if verbose:
            print(f"{round(q/(4*alpha_star))} <= e <= {round(q/(4*alpha))}")
        m = decrypt(ctxt, s)
        while m == 0:
            tmp = enc_add(ctxt, c_list[len(c_list)-i-3])
            m = decrypt(tmp, s)
            if m == 0:
                ctxt = tmp
                alpha += 2**(k-i-2)
        alpha_star = alpha + 2**(k-i-2)
        
        if ceil(q/(4*alpha_star)) == floor(q/(4*alpha)):
            if verbose:
                print(f"Recovered abs(e) = {ceil(q/(4*alpha_star))}")
            return ceil(q/(4*alpha_star)), ctxt
    return None, None
                
def binary_attack(s):
    win = 0
    total =  0
    for i in range(512):
        ctxt, e = encrypt(0, s, verbose=False)
        print("-----------------------------")
        print(e)
        abs_e, c = recover_abs_e(ctxt, s, True)
        if c == None:
            continue
        print(abs_e)
        if abs(e) == abs_e:
            win +=1
        total += 1
    print(f"{win} / {total}")

def main():
    s = keygen()
    binary_attack(s)