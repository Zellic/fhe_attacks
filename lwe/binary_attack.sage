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

def test_abs_recovery(s):
    win = 0
    total = 0
    for i in range(200):
        ctxt, e = encrypt(0, s, verbose=False)
        abs_e, _ = recover_abs_e(ctxt, s, verbose=False)
        if abs_e == None:
            continue
        if abs_e == abs(e):
            win +=1
        total+=1
    print(f"{win}/{total}")
        
def binary_attack():
    s = keygen()
    print(s)
    M_p = matrix(GF(q), n)
    M_n = matrix(GF(q), n)
    V = VectorSpace(GF(q), n)
    ctxt_p = []
    ctxt_n = []
    abs_e_list_p = []
    abs_e_list_n = []
    index_p = 0
    index_n = 0
    b_p = []
    b_n = []
    
    # First recovery
    abs_e = None
    while abs_e == None:
        ctxt, e = encrypt(0, s, verbose=False)
        abs_e, c_init = recover_abs_e(ctxt, s, False)
    ctxt_p.append(ctxt)
    a, b = ctxt
    M_p[0] = a
    b_p.append(b)
    abs_e_list_p.append(abs_e)
    index_p+=1
    
    while True:
        ctxt, e = encrypt(0, s, verbose=False)
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
            ctxt, _ = encrypt(0, s)
            m = decrypt(ctxt, s_recovered)
            if m != 0:
                break
        if i != 11:
            s_recovered = M_p.solve_right(V(b_p)  - V(abs_e_list_p))
    else:
        s_recovered = M_n.solve_right(V(b_n) + V(abs_e_list_n))
        for i in range(12):
            ctxt, _ = encrypt(0, s)
            m = decrypt(ctxt, s_recovered)
            if m != 0:
                break
        if i != 11:
            s_recovered = M_n.solve_right(V(b_n) - V(abs_e_list_n))
    print(s_recovered == s)

def main():
    s = keygen()
    binary_attack(s)