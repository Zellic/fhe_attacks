from lwe_binary import LWE

lwe = LWE()

def check_same_sign(c1, c2, s):
    c = lwe.enc_add(c1, c2)
    if lwe.decrypt(c,s) == 1:
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
        c_list.append(lwe.enc_add(c_list[-1], c_list[-1]))
        m = lwe.decrypt(c_list[-1], s, verbose=verbose)
        
        if m != 0:
            break
        if 2**k > lwe.q/4:
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
            print(f"{round(q/(4*alpha_star))} <= e < {round(q/(4*alpha))}")
        m = lwe.decrypt(ctxt, s)
        while m == 0:
            tmp = lwe.enc_add(ctxt, c_list[len(c_list)-i-3])
            m = lwe.decrypt(tmp, s)
            if m == 0:
                ctxt = tmp
                alpha += 2**(k-i-2)
        alpha_star = alpha + 2**(k-i-2)
        
        if ceil(lwe.q/(4*alpha_star)) == floor(lwe.q/(4*alpha)):
            if verbose:
                print(f"Recovered abs(e) = {ceil(lwe.q/(4*alpha_star))}")
            return ceil(lwe.q/(4*alpha_star)), ctxt
    return None, None

def test_abs_recovery(s):
    win = 0
    total = 0
    for i in range(200):
        ctxt, e = lwe.encrypt(0, s, verbose=False, return_e=True)
        abs_e, _ = recover_abs_e(ctxt, s, verbose=False)
        if abs_e == None:
            continue
        if abs_e == abs(e):
            win +=1
        total+=1
    print(f"{win}/{total}")
        
def binary_attack():
    s = lwe.keygen()
    print(s)
    M_p = matrix(GF(lwe.q), lwe.n)
    M_n = matrix(GF(lwe.q), lwe.n)
    V = VectorSpace(GF(lwe.q), lwe.n)
    ctxt_p = []
    ctxt_n = []
    abs_e_list_p = []
    abs_e_list_n = []
    index_p = 0
    index_n = 0
    b_p = []
    b_n = []
    total = 0
    
    # First recovery
    abs_e = None
    while abs_e == None:
        ctxt = lwe.encrypt(0, s, verbose=False)
        total += 1
        abs_e, c_init = recover_abs_e(ctxt, s, False)
    ctxt_p.append(ctxt)
    a, b = ctxt
    M_p[0] = a
    b_p.append(b)
    abs_e_list_p.append(abs_e)
    index_p+=1
    
    while True:
        ctxt = lwe.encrypt(0, s, verbose=False)
        total += 1
        abs_e, c = recover_abs_e(ctxt, s, verbose=False)
        if abs_e == None:
            continue
        a, b = ctxt
        if abs_e == 0:
            ctxt_p.append(ctxt)
            ctxt_n.append(ctxt)
            M_p[index_p] = a
            M_n[index_n] = a
            b_p.append(b)
            b_n.append(b)
            abs_e_list_p.append(abs_e)
            abs_e_list_n.append(abs_e)
            index_p += 1
            index_n += 1
        elif check_same_sign(c_init, c, s):
            ctxt_p.append(ctxt)
            M_p[index_p] = a
            b_p.append(b)
            abs_e_list_p.append(abs_e)
            index_p += 1
        else:
            ctxt_n.append(ctxt)
            M_n[index_n] = a
            b_n.append(b)
            abs_e_list_n.append(abs_e)
            index_n += 1
        if index_p >= 64:
            break
        if index_n >= 64:
            break
    
    print(f"Got s:")
    if index_p == 64:
        s_recovered = M_p.solve_right(V(b_p) + V(abs_e_list_p))
        for i in range(12):
            ctxt = lwe.encrypt(0, s)
            m = lwe.decrypt(ctxt, s_recovered)
            if m != 0:
                break
        if i != 11:
            s_recovered = M_p.solve_right(V(b_p)  - V(abs_e_list_p))
    else:
        s_recovered = M_n.solve_right(V(b_n) + V(abs_e_list_n))
        for i in range(12):
            ctxt = lwe.encrypt(0, s)
            m = lwe.decrypt(ctxt, s_recovered)
            if m != 0:
                break
        if i != 11:
            s_recovered = M_n.solve_right(V(b_n) - V(abs_e_list_n))
    print(s_recovered == s)
    print(f"Total encryption: {total}")

def main():
    binary_attack()